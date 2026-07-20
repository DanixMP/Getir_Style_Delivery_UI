"""
Thin Zarinpal REST client (v4). Sandbox vs production is switched by the
ZARINPAL_SANDBOX setting. Amounts are passed in as Tomans and converted to
Rials (x10) for the Zarinpal API, which operates in Rials.
"""
import logging

import requests
from django.conf import settings

logger = logging.getLogger(__name__)

_TIMEOUT = 15
TOMAN_TO_RIAL = 10


def _base_url() -> str:
    if settings.ZARINPAL_SANDBOX:
        return 'https://sandbox.zarinpal.com/pg/v4/payment'
    return 'https://payment.zarinpal.com/pg/v4/payment'


def start_pay_url(authority: str) -> str:
    host = 'https://sandbox.zarinpal.com' if settings.ZARINPAL_SANDBOX else 'https://payment.zarinpal.com'
    return f'{host}/pg/StartPay/{authority}'


def request_payment(amount_toman: int, description: str, callback_url: str) -> dict:
    """Returns {'authority': str} on success; raises ValueError on failure."""
    payload = {
        'merchant_id': settings.ZARINPAL_MERCHANT_ID,
        'amount': amount_toman * TOMAN_TO_RIAL,
        'callback_url': callback_url,
        'description': description,
    }
    resp = requests.post(f'{_base_url()}/request.json', json=payload, timeout=_TIMEOUT)
    body = resp.json()
    data = body.get('data') or {}
    if data.get('code') == 100 and data.get('authority'):
        return {'authority': data['authority']}
    errors = body.get('errors')
    logger.warning('Zarinpal request failed: %s', errors)
    raise ValueError(f'Zarinpal request failed: {errors}')


def verify_payment(amount_toman: int, authority: str) -> dict:
    """Returns {'ref_id': str, 'verified': bool}."""
    payload = {
        'merchant_id': settings.ZARINPAL_MERCHANT_ID,
        'amount': amount_toman * TOMAN_TO_RIAL,
        'authority': authority,
    }
    resp = requests.post(f'{_base_url()}/verify.json', json=payload, timeout=_TIMEOUT)
    body = resp.json()
    data = body.get('data') or {}
    # 100 = verified now, 101 = already verified.
    if data.get('code') in (100, 101):
        return {'ref_id': str(data.get('ref_id', '')), 'verified': True}
    return {'ref_id': '', 'verified': False}
