"""Order-side helpers: WebSocket broadcast on status change."""
import logging

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)


def broadcast_order_status(order) -> None:
    """Push the new status to the order's WebSocket group."""
    layer = get_channel_layer()
    if layer is None:  # pragma: no cover - misconfigured channel layer
        return
    try:
        async_to_sync(layer.group_send)(
            f'order_{order.id}',
            {
                'type': 'order.status',
                'order_id': str(order.id),
                'status': order.status,
                'updated_at': order.updated_at.isoformat(),
            },
        )
    except Exception as exc:  # pragma: no cover - never block the request
        logger.warning('Order status broadcast failed: %s', exc)
