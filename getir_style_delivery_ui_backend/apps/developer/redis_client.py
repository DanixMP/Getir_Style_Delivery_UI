"""
Shared helpers for the kill-switch Redis flag.

Redis is the fast path; the KILL_SWITCH_ACTIVE env var (via settings) is the
fallback when Redis is unreachable. The kill-switch is intentionally
fail-safe-open: if we cannot determine state, we do NOT block traffic.
"""
import logging

from django.conf import settings

logger = logging.getLogger(__name__)

KILL_SWITCH_KEY = 'getir_style_delivery_ui:kill_switch'

_client = None


def get_redis():
    """Return a cached redis client, or None if redis is disabled/unavailable."""
    global _client
    # Allow environments without Redis (local dev, tests) to skip the fast path.
    if not getattr(settings, 'KILL_SWITCH_USE_REDIS', True):
        return None
    if _client is not None:
        return _client
    try:
        import redis  # imported lazily; optional dependency in some envs
        _client = redis.Redis.from_url(
            settings.REDIS_URL,
            socket_connect_timeout=0.5,
            socket_timeout=0.5,
        )
    except Exception as exc:  # pragma: no cover - environment dependent
        logger.warning("Kill-switch redis unavailable: %s", exc)
        _client = None
    return _client


def is_kill_switch_active() -> bool:
    """True if traffic should be halted. Falls back to settings on failure."""
    client = get_redis()
    if client is not None:
        try:
            value = client.get(KILL_SWITCH_KEY)
            if value is not None:
                return value in (b'1', '1', 1)
        except Exception as exc:  # pragma: no cover - environment dependent
            logger.warning("Kill-switch redis read failed: %s", exc)
    return bool(getattr(settings, 'KILL_SWITCH_ACTIVE', False))


def set_kill_switch(active: bool) -> bool:
    """Set the kill-switch flag in Redis. Returns True if Redis was written."""
    client = get_redis()
    if client is None:
        return False
    try:
        client.set(KILL_SWITCH_KEY, '1' if active else '0')
        return True
    except Exception as exc:  # pragma: no cover - environment dependent
        logger.warning("Kill-switch redis write failed: %s", exc)
        return False
