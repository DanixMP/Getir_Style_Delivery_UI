"""Beta VPS settings — PostgreSQL + Redis, local media, no Arvan required."""
from decouple import config as env

from .base import *  # noqa: F401,F403
from .base import DATABASES, INSTALLED_APPS

DEBUG = env('DEBUG', default=False, cast=bool)

# Local filesystem storage only — no django-storages / S3 on beta VPS.
INSTALLED_APPS = [app for app in INSTALLED_APPS if app != 'storages']

ALLOWED_HOSTS = env(
    'ALLOWED_HOSTS',
    default='getir_style_delivery_ui.parinox.ir,localhost,127.0.0.1',
    cast=lambda v: [s.strip() for s in v.split(',') if s.strip()],
)

CSRF_TRUSTED_ORIGINS = env(
    'CSRF_TRUSTED_ORIGINS',
    default='https://getir_style_delivery_ui.parinox.ir,http://getir_style_delivery_ui.parinox.ir',
    cast=lambda v: [s.strip() for s in v.split(',') if s.strip()],
)

if not DATABASES:
    raise RuntimeError('DATABASE_URL must be set for beta deployment.')

try:
    del STATICFILES_STORAGE
except NameError:
    pass

STORAGES = {
    'default': {'BACKEND': 'django.core.files.storage.FileSystemStorage'},
    'staticfiles': {
        'BACKEND': 'whitenoise.storage.CompressedManifestStaticFilesStorage',
    },
}

CELERY_TASK_ALWAYS_EAGER = env('CELERY_TASK_ALWAYS_EAGER', default=True, cast=bool)
KILL_SWITCH_USE_REDIS = env('KILL_SWITCH_USE_REDIS', default=False, cast=bool)

# Beta has no SMS provider yet — return OTP in API so the app can show it.
OTP_RETURN_DEBUG_CODE = env('OTP_RETURN_DEBUG_CODE', default=True, cast=bool)

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_CONTENT_TYPE_NOSNIFF = True

CORS_ALLOW_ALL_ORIGINS = env('CORS_ALLOW_ALL_ORIGINS', default=False, cast=bool)
CORS_ALLOWED_ORIGINS = env(
    'CORS_ALLOWED_ORIGINS',
    default='https://getir_style_delivery_ui.parinox.ir,http://getir_style_delivery_ui.parinox.ir',
    cast=lambda v: [s.strip() for s in v.split(',') if s.strip()],
)
