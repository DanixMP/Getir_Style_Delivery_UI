"""Development settings — laptop / home-server testing."""
from .base import *  # noqa: F401,F403
from .base import BASE_DIR, DATABASES, REDIS_URL

DEBUG = True
ALLOWED_HOSTS = ['*']

# Fall back to SQLite when no Postgres DATABASE_URL is configured, so the
# project runs out-of-the-box for local verification. Production requires
# PostgreSQL (see production.py).
if not DATABASES:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# In-memory channel layer avoids requiring a Redis server during local dev.
# Set USE_REDIS_CHANNELS=true to test the real channels-redis backend.
from decouple import config as env  # noqa: E402

if not env('USE_REDIS_CHANNELS', default=False, cast=bool):
    CHANNEL_LAYERS = {
        "default": {"BACKEND": "channels.layers.InMemoryChannelLayer"}
    }

# Local filesystem media storage (Arvan S3 is production-only).
try:
    del STATICFILES_STORAGE
except NameError:
    pass

STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {"BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"},
}

# Run Celery tasks synchronously in dev unless a worker is explicitly used.
CELERY_TASK_ALWAYS_EAGER = env('CELERY_TASK_ALWAYS_EAGER', default=True, cast=bool)

# Skip the kill-switch Redis fast-path locally (fall back to KILL_SWITCH_ACTIVE).
KILL_SWITCH_USE_REDIS = env('KILL_SWITCH_USE_REDIS', default=False, cast=bool)

# Flutter web debug page calls developer endpoints with this header.
from corsheaders.defaults import default_headers  # noqa: E402

CORS_ALLOW_HEADERS = (*default_headers, 'x-developer-key')
