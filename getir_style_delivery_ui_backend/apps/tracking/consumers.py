"""WebSocket consumer streaming a peyk's location for one order."""
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class TrackingConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.group_name = f'tracking_order_{self.order_id}'
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
        pass

    async def location_update(self, event):
        await self.send_json({
            'type': 'location.update',
            'peyk_id': event['peyk_id'],
            'latitude': event['latitude'],
            'longitude': event['longitude'],
            'timestamp': event['timestamp'],
        })

    @database_sync_to_async
    def _may_access(self, user, order_id):
        from apps.orders.models import Order
        if user.role in _OPERATOR_ROLES:
            return Order.objects.filter(id=order_id).exists()
        # Only the customer who placed the order may watch it.
        return Order.objects.filter(id=order_id, customer=user).exists()
