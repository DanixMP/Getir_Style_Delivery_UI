"""
Base settings shared by all environments — GetirStyleDeliveryUi Backend.

Environment values are read via python-decouple (`env`). Never import .env
values directly in app code: always `from django.conf import settings`.
"""
from datetime import timedelta
from pathlib import Path
from urllib.parse import urlparse

from decouple import config as env

# config/settings/base.py -> config/settings -> config -> project root
BASE_DIR = Path(__file__).resolve().parent.parent.parent

SECRET_KEY = env('SECRET_KEY', default='insecure-dev-key-change-me')
DEBUG = env('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = env(
    'ALLOWED_HOSTS',
    default='localhost,127.0.0.1',
    cast=lambda v: [s.strip() for s in v.split(',') if s.strip()],
)

# --------------------------------------------------------------------------
# Applications
# --------------------------------------------------------------------------
INSTALLED_APPS = [
    # admin theme (must precede django.contrib.admin)
    'unfold',
    'unfold.contrib.filters',
    'unfold.contrib.forms',
    # django core
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'channels',
    'django_celery_beat',
    'corsheaders',
    'django_filters',
    'storages',
    # apps
    'apps.accounts',
    'apps.catalog',
    'apps.orders',
    'apps.delivery',
    'apps.tracking',
    'apps.payments',
    'apps.communications',
    'apps.reports',
    'apps.ai_services',
    'apps.operators',
    'apps.notifications',
    'apps.developer',
    'apps.wallet',
]

AUTH_USER_MODEL = 'accounts.CustomUser'

MIDDLEWARE = [
    'apps.developer.middleware.KillSwitchMiddleware',   # must be first
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'
WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]


# --------------------------------------------------------------------------
# Database
# --------------------------------------------------------------------------
def _database_from_url(url: str) -> dict:
    """Parse a postgres:// DATABASE_URL into a Django DATABASES entry."""
    parsed = urlparse(url)
    return {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': parsed.path.lstrip('/'),
        'USER': parsed.username or '',
        'PASSWORD': parsed.password or '',
        'HOST': parsed.hostname or '',
        'PORT': str(parsed.port or ''),
    }


DATABASE_URL = env('DATABASE_URL', default='')
if DATABASE_URL:
    DATABASES = {'default': _database_from_url(DATABASE_URL)}
else:
    # Overridden in development.py (sqlite) / required in production.py.
    DATABASES = {}

# --------------------------------------------------------------------------
# Redis / Channels / Celery
# --------------------------------------------------------------------------
REDIS_URL = env('REDIS_URL', default='redis://localhost:6379/0')

CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {"hosts": [REDIS_URL]},
    }
}

CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'
CELERY_TIMEZONE = 'Asia/Tehran'

# --------------------------------------------------------------------------
# DRF / JWT
# --------------------------------------------------------------------------
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
    ),
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=2),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}

# --------------------------------------------------------------------------
# Password validation
# --------------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# --------------------------------------------------------------------------
# i18n / tz
# --------------------------------------------------------------------------
LANGUAGE_CODE = 'fa'
LANGUAGES = (
    ('fa', 'Persian'),
    ('en', 'English'),
    ('ar', 'Arabic'),
    ('tr', 'Turkish'),
)
CONTENT_DEFAULT_LANGUAGE = 'fa'
TIME_ZONE = 'Asia/Tehran'
USE_I18N = True
USE_TZ = True

# --------------------------------------------------------------------------
# Static / Media
# --------------------------------------------------------------------------
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

MEDIA_URL = 'media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# --------------------------------------------------------------------------
# CORS (consumed by Flutter clients)
# --------------------------------------------------------------------------
CORS_ALLOW_ALL_ORIGINS = env('CORS_ALLOW_ALL_ORIGINS', default=True, cast=bool)

# --------------------------------------------------------------------------
# LiveKit
# --------------------------------------------------------------------------
LIVEKIT_URL = env('LIVEKIT_URL', default='ws://localhost:7880')
LIVEKIT_API_KEY = env('LIVEKIT_API_KEY', default='devkey')
LIVEKIT_API_SECRET = env('LIVEKIT_API_SECRET', default='secret')
LIVEKIT_RECORDING_ENABLED = env('LIVEKIT_RECORDING_ENABLED', default=False, cast=bool)

# --------------------------------------------------------------------------
# Zarinpal
# --------------------------------------------------------------------------
ZARINPAL_MERCHANT_ID = env('ZARINPAL_MERCHANT_ID', default='')
ZARINPAL_SANDBOX = env('ZARINPAL_SANDBOX', default=True, cast=bool)
ZARINPAL_CALLBACK_URL = env('ZARINPAL_CALLBACK_URL', default='http://localhost:8000/api/v1/payments/verify/')
ZARINPAL_WALLET_CALLBACK_URL = env('ZARINPAL_WALLET_CALLBACK_URL', default='http://localhost:8000/api/v1/wallet/topup/verify/')

# --------------------------------------------------------------------------
# Firebase / Arvan / Neshan
# --------------------------------------------------------------------------
FIREBASE_CREDENTIALS_PATH = env('FIREBASE_CREDENTIALS_PATH', default='')

ARVAN_ACCESS_KEY = env('ARVAN_ACCESS_KEY', default='')
ARVAN_SECRET_KEY = env('ARVAN_SECRET_KEY', default='')
ARVAN_BUCKET_NAME = env('ARVAN_BUCKET_NAME', default='getir_style_delivery_ui-media')
ARVAN_ENDPOINT_URL = env('ARVAN_ENDPOINT_URL', default='')
ARVAN_REGION = env('ARVAN_REGION', default='ir-thr-at1')

# Neshan maps/routing key. Falls back to the provided service key when the
# env value is empty or still the placeholder (move a real key into .env).
_NESHAN_DEFAULT = 'service.fb041db1b85f4b7aa01eceefef0708f8'
NESHAN_API_KEY = env('NESHAN_API_KEY', default=_NESHAN_DEFAULT)
if NESHAN_API_KEY in ('', 'your-neshan-key'):
    NESHAN_API_KEY = _NESHAN_DEFAULT

# --------------------------------------------------------------------------
# Developer kill switch
# --------------------------------------------------------------------------
DEVELOPER_SECRET_KEY = env('DEVELOPER_SECRET_KEY', default='dev-only-secret-change-me')
KILL_SWITCH_ACTIVE = env('KILL_SWITCH_ACTIVE', default=False, cast=bool)
# Use the Redis fast-path for the kill switch. Disabled in development so the
# project runs without a Redis server (falls back to KILL_SWITCH_ACTIVE).
KILL_SWITCH_USE_REDIS = env('KILL_SWITCH_USE_REDIS', default=True, cast=bool)


# --------------------------------------------------------------------------
# Django admin theme (django-unfold) — branded to GetirStyleDeliveryUi's soft-purple
# --------------------------------------------------------------------------
from django.templatetags.static import static  # noqa: E402
from django.urls import reverse_lazy  # noqa: E402

UNFOLD = {
    'SITE_TITLE': 'GetirStyleDeliveryUi Admin',
    'SITE_HEADER': 'GetirStyleDeliveryUi',
    'SITE_SUBHEADER': 'Operations Console',
    'SITE_URL': '/',
    'SITE_SYMBOL': 'local_shipping',
    'SHOW_HISTORY': True,
    'SHOW_VIEW_ON_SITE': False,
    'COLORS': {
        'primary': {
            '50': '244 241 254',
            '100': '231 222 255',
            '200': '204 189 255',
            '300': '173 151 255',
            '400': '139 107 240',
            '500': '109 71 214',
            '600': '93 62 189',
            '700': '69 32 165',
            '800': '54 25 127',
            '900': '42 19 102',
            '950': '31 0 96',
        },
    },
    'SIDEBAR': {
        'show_search': True,
        'show_all_applications': True,
        'navigation': [
            {
                'title': 'Operations',
                'separator': True,
                'items': [
                    {
                        'title': 'Dashboard',
                        'icon': 'dashboard',
                        'link': reverse_lazy('admin:index'),
                    },
                    {
                        'title': 'Orders',
                        'icon': 'receipt_long',
                        'link': reverse_lazy('admin:orders_order_changelist'),
                    },
                    {
                        'title': 'Offline orders',
                        'icon': 'storefront',
                        'link': reverse_lazy('admin:orders_offlineorder_changelist'),
                    },
                    {
                        'title': 'Peyk assignments',
                        'icon': 'two_wheeler',
                        'link': reverse_lazy('admin:delivery_peykassignment_changelist'),
                    },
                ],
            },
            {
                'title': 'People',
                'separator': True,
                'items': [
                    {
                        'title': 'Users',
                        'icon': 'group',
                        'link': reverse_lazy('admin:accounts_customuser_changelist'),
                    },
                    {
                        'title': 'Vendors',
                        'icon': 'restaurant',
                        'link': reverse_lazy('admin:accounts_vendorprofile_changelist'),
                    },
                    {
                        'title': 'Peyks',
                        'icon': 'sports_motorsports',
                        'link': reverse_lazy('admin:accounts_peykprofile_changelist'),
                    },
                    {
                        'title': 'Operators',
                        'icon': 'support_agent',
                        'link': reverse_lazy('admin:accounts_operatorprofile_changelist'),
                    },
                ],
            },
            {
                'title': 'Catalog',
                'separator': True,
                'items': [
                    {
                        'title': 'Categories',
                        'icon': 'category',
                        'link': reverse_lazy('admin:catalog_category_changelist'),
                    },
                    {
                        'title': 'Items',
                        'icon': 'lunch_dining',
                        'link': reverse_lazy('admin:catalog_item_changelist'),
                    },
                    {
                        'title': 'Home banners',
                        'icon': 'ad_units',
                        'link': reverse_lazy('admin:catalog_homebanner_changelist'),
                    },
                ],
            },
            {
                'title': 'Money',
                'separator': True,
                'items': [
                    {
                        'title': 'Wallets',
                        'icon': 'account_balance_wallet',
                        'link': reverse_lazy('admin:wallet_wallet_changelist'),
                    },
                    {
                        'title': 'Payments',
                        'icon': 'payments',
                        'link': reverse_lazy('admin:payments_zarinpaltransaction_changelist'),
                    },
                    {
                        'title': 'Vendor reports',
                        'icon': 'analytics',
                        'link': reverse_lazy('admin:reports_vendorreport_changelist'),
                    },
                ],
            },
        ],
    },
}
