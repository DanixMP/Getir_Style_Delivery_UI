"""Broadcast GPS snapshots to the order's tracking WebSocket group."""
import logging

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)


def broadcast_location(snapshot) -> None:
    if snapshot.order_id is None:
        return
    layer = get_channel_layer()
    if layer is None:  # pragma: no cover
        return
    try:
        async_to_sync(layer.group_send)(
            f'tracking_order_{snapshot.order_id}',
            {
                'type': 'location.update',
                'peyk_id': str(snapshot.peyk_id),
                'latitude': float(snapshot.latitude),
                'longitude': float(snapshot.longitude),
                'timestamp': snapshot.timestamp.isoformat(),
            },
        )
    except Exception as exc:  # pragma: no cover - never block the request
        logger.warning('Location broadcast failed: %s', exc)
