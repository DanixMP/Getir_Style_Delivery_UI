from django.conf import settings
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsCustomer
from apps.orders.models import Order

from . import zarinpal
from .models import ZarinpalTransaction
from .serializers import PaymentInitiateSerializer, ZarinpalTransactionSerializer

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class PaymentInitiateView(APIView):
    permission_classes = [IsCustomer]

    def post(self, request):
        serializer = PaymentInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            order = Order.objects.get(id=serializer.validated_data['order_id'], customer=request.user)
        except Order.DoesNotExist:
            return Response({'detail': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            result = zarinpal.request_payment(
                amount_toman=order.total_amount,
                description=f'GetirStyleDeliveryUi order {order.id}',
                callback_url=settings.ZARINPAL_CALLBACK_URL,
            )
        except ValueError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        ZarinpalTransaction.objects.create(
            order=order, amount=order.total_amount,
            authority=result['authority'], payment_method='online',
        )
        return Response({'payment_url': zarinpal.start_pay_url(result['authority'])})


class PaymentVerifyView(APIView):
    """Zarinpal callback. No auth — validated by Authority + Status params."""
    permission_classes = [AllowAny]

    def get(self, request):
        authority = request.query_params.get('Authority')
        pay_status = request.query_params.get('Status')
        if not authority:
            return Response({'detail': 'Missing Authority.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            txn = ZarinpalTransaction.objects.get(authority=authority)
        except ZarinpalTransaction.DoesNotExist:
            return Response({'detail': 'Transaction not found.'}, status=status.HTTP_404_NOT_FOUND)

        if pay_status != 'OK':
            txn.status = 'failed'
            txn.save(update_fields=['status'])
            return Response({'detail': 'Payment cancelled or failed.'}, status=status.HTTP_400_BAD_REQUEST)

        result = zarinpal.verify_payment(amount_toman=txn.amount, authority=authority)
        if result['verified']:
            txn.status = 'verified'
            txn.ref_id = result['ref_id']
            txn.verified_at = timezone.now()
            txn.save(update_fields=['status', 'ref_id', 'verified_at'])
            return Response({'detail': 'payment verified', 'ref_id': txn.ref_id})

        txn.status = 'failed'
        txn.save(update_fields=['status'])
        return Response({'detail': 'verification failed'}, status=status.HTTP_400_BAD_REQUEST)


class PaymentStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, order_id):
        qs = ZarinpalTransaction.objects.filter(order_id=order_id)
        if request.user.role not in _OPERATOR_ROLES:
            qs = qs.filter(order__customer=request.user)
        txn = qs.order_by('-created_at').first()
        if txn is None:
            return Response({'detail': 'No transaction for this order.'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response({'status': txn.status, 'ref_id': txn.ref_id})
