"""
ASGI config for GetirStyleDeliveryUi — routes HTTP to Django and WebSocket to Channels.
"""
import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

# Initialise Django before importing anything that touches the app registry
# (consumers / routing import models).
django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter  # noqa: E402

from apps.accounts.ws_auth import JWTQueryParamMiddleware  # noqa: E402
from apps.delivery.routing import websocket_urlpatterns as delivery_ws  # noqa: E402
from apps.orders.routing import websocket_urlpatterns as orders_ws  # noqa: E402
from apps.tracking.routing import websocket_urlpatterns as tracking_ws  # noqa: E402

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": JWTQueryParamMiddleware(
        URLRouter(tracking_ws + orders_ws + delivery_ws)
    ),
})
