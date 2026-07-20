"""
VOIP abstraction. Views must use get_voip_adapter() — never instantiate
LiveKitAdapter directly. This keeps the provider swappable.
"""
import logging
import time
from abc import ABC, abstractmethod

import jwt
from django.conf import settings

logger = logging.getLogger(__name__)


class VOIPAdapter(ABC):
    @abstractmethod
    def generate_token(self, channel: str, user_id: str, user_name: str, expiry_seconds: int) -> str:
        """Return a signed JWT token the client uses to join the room."""

    @abstractmethod
    def start_recording(self, channel: str, order_id: str) -> str | None:
        """Start Egress recording. Returns egress_id, or None if disabled."""

    @abstractmethod
    def stop_recording(self, egress_id: str) -> None:
        """Stop a running Egress recording by egress_id."""


class LiveKitAdapter(VOIPAdapter):
    """Concrete LiveKit implementation.

    Beta deployments keep recording disabled, so token minting uses LiveKit's
    standard HS256 JWT shape directly and does not require livekit-api at
    runtime.
    """

    def generate_token(self, channel: str, user_id: str, user_name: str, expiry_seconds: int) -> str:
        now = int(time.time())
        payload = {
            'iss': settings.LIVEKIT_API_KEY,
            'sub': user_id,
            'name': user_name,
            'nbf': now,
            'exp': now + expiry_seconds,
            'video': {
                'roomJoin': True,
                'room': channel,
                'canPublish': True,
                'canSubscribe': True,
                'canPublishData': True,
            },
        }
        return jwt.encode(payload, settings.LIVEKIT_API_SECRET, algorithm='HS256')

    def start_recording(self, channel: str, order_id: str) -> str | None:
        if not settings.LIVEKIT_RECORDING_ENABLED:
            return None
        try:
            from livekit import api
            lkapi = api.LiveKitAPI(
                settings.LIVEKIT_URL, settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET,
            )
            from asgiref.sync import async_to_sync
            request = api.RoomCompositeEgressRequest(
                room_name=channel,
                file_outputs=[api.EncodedFileOutput(
                    filepath=f'recordings/order_{order_id}_{channel}.mp4',
                    s3=api.S3Upload(
                        access_key=settings.ARVAN_ACCESS_KEY,
                        secret=settings.ARVAN_SECRET_KEY,
                        bucket=settings.ARVAN_BUCKET_NAME,
                        endpoint=settings.ARVAN_ENDPOINT_URL,
                        region=settings.ARVAN_REGION,
                    ),
                )],
            )
            response = async_to_sync(lkapi.egress.start_room_composite_egress)(request)
            return getattr(response, 'egress_id', None)
        except Exception as exc:  # pragma: no cover - depends on live Egress
            logger.warning('start_recording failed: %s', exc)
            return None

    def stop_recording(self, egress_id: str) -> None:
        if not egress_id:
            return
        try:
            from livekit import api
            from asgiref.sync import async_to_sync
            lkapi = api.LiveKitAPI(
                settings.LIVEKIT_URL, settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET,
            )
            async_to_sync(lkapi.egress.stop_egress)(api.StopEgressRequest(egress_id=egress_id))
        except Exception as exc:  # pragma: no cover - depends on live Egress
            logger.warning('stop_recording failed: %s', exc)


def get_voip_adapter() -> VOIPAdapter:
    """Factory. Future: read VOIP_BACKEND from settings to swap provider."""
    return LiveKitAdapter()
