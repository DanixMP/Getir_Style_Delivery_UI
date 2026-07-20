"""WebSocket consumer notifying a peyk when a new order is assigned."""
from channels.generic.websocket import AsyncJsonWebsocketConsumer


class PeykAssignmentConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        user = self.scope.get('user')
        if user is None or not user.is_authenticated or user.role != 'peyk':
            await self.close(code=4001)
            return

        self.group_name = f'peyk_{user.id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        # Peyks only listen; inbound messages are ignored.
        pass

    async def assignment_created(self, event):
        await self.send_json({
            'type': 'assignment.created',
            'order_id': event['order_id'],
            'assigned_at': event['assigned_at'],
        })
