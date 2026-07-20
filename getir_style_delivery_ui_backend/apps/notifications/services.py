"""
FCM push wrapper. Called by other apps — never exposed via the API.

All functions are best-effort: failures are logged, never raised to the caller.
"""
import logging

logger = logging.getLogger(__name__)


def _get_active_tokens(user_id: str):
    """Return active FCM tokens for a user, or [] if unavailable."""
    try:
        from apps.communications.models import FCMDevice
    except Exception:  # communications not migrated yet / app loading
        return []
    return list(
        FCMDevice.objects.filter(user_id=user_id, is_active=True)
        .values_list('fcm_token', flat=True)
    )


def send_push(user_id: str, title: str, body: str, data: dict = None) -> None:
    """
    Send an FCM push to all active devices registered for user_id.
    Silently logs failures — never raises to the caller.
    """
    tokens = _get_active_tokens(user_id)
    if not tokens:
        logger.debug('No active FCM tokens for user %s', user_id)
        return
    try:
        from firebase_admin import messaging
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=tokens,
        )
        messaging.send_each_for_multicast(message)
    except Exception as exc:
        logger.warning('FCM push to user %s failed: %s', user_id, exc)


# --- Named convenience functions (prefer these over send_push directly) -----

def notify_peyk_new_order(peyk_id: str, order_id: str) -> None:
    send_push(peyk_id, 'سفارش جدید', 'یک سفارش جدید به شما اختصاص یافت.',
              {'type': 'new_order', 'order_id': order_id})


def notify_customer_status_change(customer_id: str, order_id: str, new_status: str) -> None:
    send_push(customer_id, 'وضعیت سفارش', f'وضعیت سفارش شما: {new_status}',
              {'type': 'order_status', 'order_id': order_id, 'status': new_status})


def notify_peyk_incoming_call(peyk_id: str, channel_name: str, livekit_url: str, token: str) -> None:
    send_push(peyk_id, 'تماس ورودی', 'یک تماس برای شما برقرار شده است.',
              {'type': 'incoming_call', 'channel_name': channel_name,
               'livekit_url': livekit_url, 'token': token})


def notify_vendor_new_order(vendor_user_id: str, order_id: str) -> None:
    send_push(vendor_user_id, 'سفارش جدید', 'یک سفارش جدید ثبت شد.',
              {'type': 'new_order', 'order_id': order_id})
