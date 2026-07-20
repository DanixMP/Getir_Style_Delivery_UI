"""Kill switch middleware — must be the FIRST middleware in settings."""
from django.http import JsonResponse

from .redis_client import is_kill_switch_active


class KillSwitchMiddleware:
    """
    Reads KILL_SWITCH_ACTIVE from Redis key 'getir_style_delivery_ui:kill_switch'.
    Falls back to env var KILL_SWITCH_ACTIVE if Redis is unreachable.
    If active: returns HTTP 503 JSON to all /api/ requests.
    Admin (/admin/) and the kill-switch toggle endpoint itself are exempt.
    """
    EXEMPT_PATHS = ['/admin/', '/api/v1/developer/kill-switch/']

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        path = request.path
        if path.startswith('/api/') and not self._is_exempt(path):
            if is_kill_switch_active():
                return JsonResponse(
                    {'detail': 'Service is temporarily unavailable.'},
                    status=503,
                )
        return self.get_response(request)

    def _is_exempt(self, path: str) -> bool:
        return any(path.startswith(p) for p in self.EXEMPT_PATHS)
