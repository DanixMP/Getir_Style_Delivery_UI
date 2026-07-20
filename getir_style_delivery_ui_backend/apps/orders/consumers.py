"""WebSocket consumer broadcasting order status changes."""
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class OrderStatusConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.group_name = f'order_{self.order_id}'
        user = self.scope.get('user')

        if user is None or not user.is_authenticated:
            await self.close(code=4001)
            return
        if not await self._may_access(user, self.order_id):
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        # Clients are read-only listeners; ignore inbound messages.
        pass

    async def order_status(self, event):
        await self.send_json({
            'type': 'order.status',
            'order_id': event['order_id'],
            'status': event['status'],
            'updated_at': event['updated_at'],
        })

    @database_sync_to_async
    def _may_access(self, user, order_id):
        from .models import Order
        if user.role in _OPERATOR_ROLES:
            return Order.objects.filter(id=order_id).exists()
        try:
            order = Order.objects.select_related('assignment').get(id=order_id)
        except Order.DoesNotExist:
            return False
        if order.customer_id == user.id:
            return True
        assignment = getattr(order, 'assignment', None)
        return bool(assignment and assignment.peyk_id == user.id)
