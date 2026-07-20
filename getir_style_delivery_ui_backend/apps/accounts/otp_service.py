"""Phone OTP generation and verification (dev: codes print to runserver console)."""
import logging
import random
import re
import sys

from django.contrib.auth import get_user_model
from django.utils import timezone

from .models import PhoneOtp

User = get_user_model()
logger = logging.getLogger(__name__)

OTP_TTL_MINUTES = 5
OTP_LENGTH = 6


def normalize_phone(phone: str) -> str:
    digits = re.sub(r'\D', '', phone or '')
    if digits.startswith('98') and len(digits) == 12:
        digits = '0' + digits[2:]
    if len(digits) == 10 and not digits.startswith('0'):
        digits = '0' + digits
    return digits


def request_otp(phone: str) -> PhoneOtp:
    phone = normalize_phone(phone)
    if len(phone) < 10:
        raise ValueError('Invalid phone number.')

    PhoneOtp.objects.filter(phone=phone, is_used=False).update(is_used=True)

    code = ''.join(str(random.randint(0, 9)) for _ in range(OTP_LENGTH))
    expires_at = timezone.now() + timezone.timedelta(minutes=OTP_TTL_MINUTES)
    otp = PhoneOtp.objects.create(phone=phone, code=code, expires_at=expires_at)

    banner = (
        f'\n{"=" * 50}\n'
        f'GETIR_STYLE_DELIVERY_UI OTP for {phone}: {code}\n'
        f'Expires: {expires_at:%Y-%m-%d %H:%M:%S %Z}\n'
        f'{"=" * 50}\n'
    )
    print(banner, flush=True)
    sys.stderr.write(banner)
    sys.stderr.flush()
    logger.warning('OTP for %s: %s (expires %s)', phone, code, expires_at.isoformat())
    return otp


def verify_otp(phone: str, code: str) -> User:
    phone = normalize_phone(phone)
    code = (code or '').strip()
    if len(code) != OTP_LENGTH:
        raise ValueError('Invalid OTP code.')

    otp = (
        PhoneOtp.objects.filter(phone=phone, code=code, is_used=False)
        .order_by('-created_at')
        .first()
    )
    if not otp:
        raise ValueError('OTP not found or already used.')
    if otp.expires_at < timezone.now():
        raise ValueError('OTP expired.')

    otp.is_used = True
    otp.save(update_fields=['is_used'])

    user, created = User.objects.get_or_create(
        phone=phone,
        defaults={
            'full_name': f'User {phone[-4:]}',
            'role': 'customer',
            'city': 'Tehran',
        },
    )
    if created:
        user.set_unusable_password()
        user.save(update_fields=['password'])
    return user
