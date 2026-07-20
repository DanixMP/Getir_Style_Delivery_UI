"""Short-lived table holds before checkout (Redis with in-process fallback)."""
import logging
import time

from django.conf import settings

logger = logging.getLogger(__name__)

TABLE_HOLD_TTL = 300  # 5 minutes
_KEY_PREFIX = 'getir_style_delivery_ui:table_hold:'
_local_holds: dict[str, tuple[str, float]] = {}


def _hold_key(vendor_id, table_id) -> str:
    return f'{_KEY_PREFIX}{vendor_id}:{table_id}'


def _get_redis():
    try:
        from apps.developer.redis_client import get_redis
        return get_redis()
    except Exception as exc:  # pragma: no cover
        logger.warning('Table hold redis unavailable: %s', exc)
        return None


def hold_table(vendor_id, table_id, customer_id) -> tuple[bool, str | None]:
    """
    Reserve a table for the customer. Returns (success, error_message).
    When held by another customer, returns (False, detail).
    """
    key = _hold_key(vendor_id, table_id)
    customer = str(customer_id)
    client = _get_redis()
    if client is not None:
        try:
            existing = client.get(key)
            if existing is not None and existing.decode() != customer:
                return False, 'Table is temporarily held by another customer.'
            client.setex(key, TABLE_HOLD_TTL, customer)
            return True, None
        except Exception as exc:  # pragma: no cover
            logger.warning('Table hold redis write failed: %s', exc)

    expires = time.time() + TABLE_HOLD_TTL
    existing = _local_holds.get(key)
    if existing and existing[1] > time.time() and existing[0] != customer:
        return False, 'Table is temporarily held by another customer.'
    _local_holds[key] = (customer, expires)
    return True, None


def clear_expired_local_holds() -> None:
    """Drop expired in-process holds (tests/dev without Redis)."""
    now = time.time()
    expired = [k for k, (_, exp) in _local_holds.items() if exp <= now]
    for key in expired:
        _local_holds.pop(key, None)
