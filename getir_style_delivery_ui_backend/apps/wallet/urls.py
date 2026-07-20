from django.urls import path

from .views import (
    PayOrderView,
    TopUpInitiateView,
    TopUpVerifyView,
    WalletDetailView,
    WalletTransactionListView,
)

urlpatterns = [
    path('', WalletDetailView.as_view(), name='wallet-detail'),
    path('transactions/', WalletTransactionListView.as_view(), name='wallet-transactions'),
    path('topup/initiate/', TopUpInitiateView.as_view(), name='wallet-topup-initiate'),
    path('topup/verify/', TopUpVerifyView.as_view(), name='wallet-topup-verify'),
    path('pay-order/', PayOrderView.as_view(), name='wallet-pay-order'),
]
