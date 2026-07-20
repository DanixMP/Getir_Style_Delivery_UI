from django.conf import settings
from django.utils import timezone
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsCustomer
from apps.orders.models import Order
from apps.payments import zarinpal

from . import services
from .models import WalletTopUp, WalletTransaction
from .serializers import (
    PayOrderSerializer,
    TopUpInitiateSerializer,
    WalletSerializer,
    WalletTransactionSerializer,
)


class WalletDetailView(APIView):
    """Current user's wallet (created on first access)."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        wallet = services.get_or_create_wallet(request.user)
        return Response(WalletSerializer(wallet).data)


class WalletTransactionListView(ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = WalletTransactionSerializer

    def get_queryset(self):
        wallet = services.get_or_create_wallet(self.request.user)
        return WalletTransaction.objects.filter(wallet=wallet)


class TopUpInitiateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = TopUpInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        amount = serializer.validated_data['amount']
        wallet = services.get_or_create_wallet(request.user)

        try:
            result = zarinpal.request_payment(
                amount_toman=amount,
                description=f'Wallet top-up for {request.user.phone}',
                callback_url=settings.ZARINPAL_WALLET_CALLBACK_URL,
            )
        except ValueError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        WalletTopUp.objects.create(wallet=wallet, amount=amount, authority=result['authority'])
        return Response({'payment_url': zarinpal.start_pay_url(result['authority'])})


class TopUpVerifyView(APIView):
    """Zarinpal callback for wallet top-ups. Credits the wallet on success."""
    permission_classes = [AllowAny]

    def get(self, request):
        authority = request.query_params.get('Authority')
        pay_status = request.query_params.get('Status')
        if not authority:
            return Response({'detail': 'Missing Authority.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            topup = WalletTopUp.objects.select_related('wallet').get(authority=authority)
        except WalletTopUp.DoesNotExist:
            return Response({'detail': 'Top-up not found.'}, status=status.HTTP_404_NOT_FOUND)

        if topup.status == 'verified':
            return Response({'detail': 'already verified', 'ref_id': topup.ref_id})

        if pay_status != 'OK':
            topup.status = 'failed'
            topup.save(update_fields=['status'])
            return Response({'detail': 'Payment cancelled or failed.'}, status=status.HTTP_400_BAD_REQUEST)

        result = zarinpal.verify_payment(amount_toman=topup.amount, authority=authority)
        if not result['verified']:
            topup.status = 'failed'
            topup.save(update_fields=['status'])
            return Response({'detail': 'verification failed'}, status=status.HTTP_400_BAD_REQUEST)

        services.credit(
            topup.wallet, topup.amount, 'topup',
            description=f'Top-up ref {result["ref_id"]}',
        )
        topup.status = 'verified'
        topup.ref_id = result['ref_id']
        topup.verified_at = timezone.now()
        topup.save(update_fields=['status', 'ref_id', 'verified_at'])
        return Response({'detail': 'top-up verified', 'ref_id': topup.ref_id})


class PayOrderView(APIView):
    """Pay for one of the customer's own orders from wallet balance."""
    permission_classes = [IsCustomer]

    def post(self, request):
        serializer = PayOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            order = Order.objects.get(id=serializer.validated_data['order_id'], customer=request.user)
        except Order.DoesNotExist:
            return Response({'detail': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        if order.payment_method != 'wallet':
            return Response({'detail': 'Order payment method is not wallet.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if order.is_paid:
            return Response({'detail': 'Order is already paid.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            txn = services.pay_order(request.user, order)
        except services.InsufficientFunds:
            return Response({'detail': 'Insufficient wallet balance.'},
                            status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'detail': 'order paid',
            'balance_after': txn.balance_after,
            'transaction_id': str(txn.id),
        })
