import logging

from django.apps import AppConfig
from django.conf import settings

logger = logging.getLogger(__name__)


class NotificationsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.notifications'

    def ready(self):
        """Initialise the Firebase Admin SDK once, if configured."""
        creds_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', '')
        if not creds_path:
            return
        try:
            import firebase_admin
            from firebase_admin import credentials
            if not firebase_admin._apps:  # initialise only once
                firebase_admin.initialize_app(credentials.Certificate(creds_path))
        except Exception as exc:  # pragma: no cover - depends on env
            logger.warning('Firebase Admin init skipped: %s', exc)
