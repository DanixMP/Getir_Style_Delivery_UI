from django.urls import path

from .views import (
    CallEndView,
    CallInitiateView,
    DeviceDeleteView,
    DeviceRegisterView,
    OperatorCallInitiateView,
)

urlpatterns = [
    path('call/initiate/', CallInitiateView.as_view(), name='call-initiate'),
    path('call/end/', CallEndView.as_view(), name='call-end'),
    path('call/operator-initiate/', OperatorCallInitiateView.as_view(), name='call-operator-initiate'),
    path('devices/register/', DeviceRegisterView.as_view(), name='device-register'),
    path('devices/<str:fcm_token>/', DeviceDeleteView.as_view(), name='device-delete'),
]
