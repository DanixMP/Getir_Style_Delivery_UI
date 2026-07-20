"""
Developer kill-switch endpoints.

Auth: header `X-Developer-Key: <DEVELOPER_SECRET_KEY>`. No JWT, no session.
"""
from django.conf import settings
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .redis_client import is_kill_switch_active, set_kill_switch


class _DeveloperKeyMixin:
    """Validates the X-Developer-Key header before doing anything."""
    permission_classes = [AllowAny]

    def _check_key(self, request):
        provided = request.headers.get('X-Developer-Key', '')
        expected = settings.DEVELOPER_SECRET_KEY
        # Constant-time compare to avoid timing leaks.
        from hmac import compare_digest
        if not provided or not compare_digest(str(provided), str(expected)):
            return False
        return True

    def _denied(self):
        return Response({'detail': 'Invalid developer key.'},
                        status=status.HTTP_403_FORBIDDEN)


class KillSwitchActivateView(_DeveloperKeyMixin, APIView):
    def post(self, request):
        if not self._check_key(request):
            return self._denied()
        written = set_kill_switch(True)
        return Response({
            'active': True,
            'redis_written': written,
        })


class KillSwitchDeactivateView(_DeveloperKeyMixin, APIView):
    def post(self, request):
        if not self._check_key(request):
            return self._denied()
        written = set_kill_switch(False)
        return Response({
            'active': False,
            'redis_written': written,
        })


class KillSwitchStatusView(_DeveloperKeyMixin, APIView):
    def post(self, request):
        if not self._check_key(request):
            return self._denied()
        return Response({'active': is_kill_switch_active()})
