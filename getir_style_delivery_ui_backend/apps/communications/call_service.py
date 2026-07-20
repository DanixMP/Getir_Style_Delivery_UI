"""
Reusable call-initiation logic shared by the communications endpoint and the
operators panel proxy. Returns (payload, http_status).
"""
import time

from django.conf import settings

from .models import CallLog
from .voip_adapter import get_voip_adapter

TOKEN_TTL_SECONDS = 3600


def operator_initiate_call(operator, peyk_id, consent_acknowledged: bool):
    if not consent_acknowledged:
        return {'detail': 'Call recording consent is required.'}, 400

    channel_name = f'op_{operator.id}_{peyk_id}_{int(time.time())}'
    adapter = get_voip_adapter()
    token = adapter.generate_token(channel_name, str(operator.id), operator.full_name, TOKEN_TTL_SECONDS)

    call_log = CallLog.objects.create(
        caller=operator, receiver_id=peyk_id,
        channel_name=channel_name, livekit_room_name=channel_name,
        initiated_by_operator=True, consent_acknowledged=True,
    )
    egress_id = adapter.start_recording(channel_name, str(call_log.id))
    if egress_id:
        call_log.egress_id = egress_id
        call_log.save(update_fields=['egress_id'])

    try:
        from apps.notifications.services import notify_peyk_incoming_call
        notify_peyk_incoming_call(str(peyk_id), channel_name, settings.LIVEKIT_URL, token)
    except Exception:
        pass

    return {
        'token': token,
        'channel_name': channel_name,
        'livekit_url': settings.LIVEKIT_URL,
        'call_log_id': str(call_log.id),
    }, 200
