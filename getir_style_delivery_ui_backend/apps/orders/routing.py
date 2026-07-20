from django.urls import re_path

from .consumers import OrderStatusConsumer

websocket_urlpatterns = [
    re_path(r'ws/orders/(?P<order_id>[0-9a-f-]+)/$', OrderStatusConsumer.as_asgi()),
]
