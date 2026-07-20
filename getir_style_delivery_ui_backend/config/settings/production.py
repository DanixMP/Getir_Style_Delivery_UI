"""Production settings — single VPS, Daphne ASGI."""
from .base import *  # noqa: F401,F403
from .base import (
    ARVAN_ACCESS_KEY,
    ARVAN_BUCKET_NAME,
    ARVAN_ENDPOINT_URL,
    ARVAN_REGION,
    ARVAN_SECRET_KEY,
    DATABASES,
)

DEBUG = False

if not DATABASES:
    raise RuntimeError(
        "DATABASE_URL must be set in production (PostgreSQL is required)."
    )

# Arvan Cloud (S3-compatible) media storage.
STORAGES = {
    "default": {
        "BACKEND": "storages.backends.s3.S3Storage",
        "OPTIONS": {
            "access_key": ARVAN_ACCESS_KEY,
            "secret_key": ARVAN_SECRET_KEY,
            "bucket_name": ARVAN_BUCKET_NAME,
            "endpoint_url": ARVAN_ENDPOINT_URL,
            "region_name": ARVAN_REGION,
        },
    },
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

# Security hardening.
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_CONTENT_TYPE_NOSNIFF = True
