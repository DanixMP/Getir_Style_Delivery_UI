from django.urls import re_path

from .consumers import TrackingConsumer

websocket_urlpatterns = [
    re_path(r'ws/tracking/(?P<order_id>[0-9a-f-]+)/$', TrackingConsumer.as_asgi()),
]
