from django.urls import path

from .views import PaymentInitiateView, PaymentStatusView, PaymentVerifyView

urlpatterns = [
    path('initiate/', PaymentInitiateView.as_view(), name='payment-initiate'),
    path('verify/', PaymentVerifyView.as_view(), name='payment-verify'),
    path('<uuid:order_id>/status/', PaymentStatusView.as_view(), name='payment-status'),
]
