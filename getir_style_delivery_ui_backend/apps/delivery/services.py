"""Delivery-side helpers: WebSocket broadcast when a peyk is assigned."""
import logging

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)


def broadcast_peyk_assignment(assignment) -> None:
    """Push a new assignment to the assigned peyk's WebSocket group."""
    layer = get_channel_layer()
    if layer is None:  # pragma: no cover - misconfigured channel layer
        return
    try:
        async_to_sync(layer.group_send)(
            f'peyk_{assignment.peyk_id}',
            {
                'type': 'assignment.created',
                'order_id': str(assignment.order_id),
                'assigned_at': assignment.assigned_at.isoformat(),
            },
        )
    except Exception as exc:  # pragma: no cover - never block the request
        logger.warning('Peyk assignment broadcast failed: %s', exc)
