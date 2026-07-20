from django.urls import re_path

from .consumers import PeykAssignmentConsumer

websocket_urlpatterns = [
    re_path(r'ws/peyk/assignments/$', PeykAssignmentConsumer.as_asgi()),
]
