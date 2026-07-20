"""Auto-generate PeykProfile.peyk_code as YLK-XXXXX before save."""
import random
import string

from django.db.models.signals import pre_save
from django.dispatch import receiver

from .models import PeykProfile

_ALPHABET = string.ascii_uppercase + string.digits
_MAX_RETRIES = 5


def _generate_code() -> str:
    return 'YLK-' + ''.join(random.choices(_ALPHABET, k=5))


@receiver(pre_save, sender=PeykProfile)
def assign_peyk_code(sender, instance, **kwargs):
    if instance.peyk_code:
        return
    for _ in range(_MAX_RETRIES):
        code = _generate_code()
        if not PeykProfile.objects.filter(peyk_code=code).exists():
            instance.peyk_code = code
            return
    raise RuntimeError('Could not generate a unique peyk_code after retries.')
