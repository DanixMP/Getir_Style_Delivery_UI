from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.accounts.permissions import IsCustomer, IsOperator

from .models import OfflineOrder, Order
from .serializers import (
    OfflineOrderSerializer,
    OrderCreateSerializer,
    OrderSerializer,
    StatusUpdateSerializer,
)
from .services import broadcast_order_status

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class OrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_serializer_class(self):
        if self.action == 'create':
            return OrderCreateSerializer
        return OrderSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [(IsCustomer | IsOperator)()]
        return [IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        qs = Order.objects.select_related(
            'vendor', 'assignment__peyk',
        ).prefetch_related('items__item')
        if user.role in _OPERATOR_ROLES:
            return qs
        if user.role == 'vendor':
            return qs.filter(vendor__user=user)
        if user.role == 'peyk':
            return qs.filter(assignment__peyk=user)
        # customer
        return qs.filter(customer=user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = serializer.save()
        return Response(
            OrderSerializer(order, context=self.get_serializer_context()).data,
            status=status.HTTP_201_CREATED,
        )

    @action(detail=True, methods=['patch'], url_path='status')
    def update_status(self, request, pk=None):
        order = self.get_object()
        payload = StatusUpdateSerializer(data=request.data)
        payload.is_valid(raise_exception=True)
        new_status = payload.validated_data['status']

        if not order.can_transition_to(new_status, request.user.role):
            return Response(
                {'detail': 'Invalid status transition.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Peyk transitions require the actor to be the assigned peyk.
        if request.user.role == 'peyk':
            assignment = getattr(order, 'assignment', None)
            if assignment is None or assignment.peyk_id != request.user.id:
                raise PermissionDenied('You are not assigned to this order.')

            # Handoff PIN: completing delivery requires the 6-digit code the
            # customer reads to the peyk (delivery orders only).
            if new_status == 'delivered' and order.fulfillment_type == 'delivery':
                code = str(request.data.get('delivery_code', '')).strip()
                if code != order.delivery_code:
                    return Response(
                        {'detail': 'Invalid delivery code.'},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

        order.status = new_status
        order.save(update_fields=['status', 'updated_at'])

        assignment = getattr(order, 'assignment', None)
        if assignment is not None and new_status in ('picked_up', 'delivered'):
            update_fields = []
            if new_status == 'picked_up' and assignment.picked_up_at is None:
                assignment.picked_up_at = timezone.now()
                update_fields.append('picked_up_at')
            if new_status == 'delivered' and assignment.delivered_at is None:
                assignment.delivered_at = timezone.now()
                update_fields.append('delivered_at')
            if update_fields:
                assignment.save(update_fields=update_fields)

        # Auto-refund wallet-paid orders on cancellation.
        if new_status == 'cancelled':
            self._refund_if_wallet_paid(order)

        broadcast_order_status(order)
        self._notify_status(order)
        return Response(
            OrderSerializer(order, context=self.get_serializer_context()).data,
        )

    def _refund_if_wallet_paid(self, order):
        try:
            from apps.wallet.services import refund_order
            refund_order(order)
        except Exception:  # a refund failure must not block cancellation
            pass

    def _notify_status(self, order):
        try:
            from apps.notifications.services import notify_customer_status_change
            notify_customer_status_change(str(order.customer_id), str(order.id), order.status)
        except Exception:  # notifications must never break the request
            pass


class OfflineOrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsOperator]
    serializer_class = OfflineOrderSerializer
    queryset = OfflineOrder.objects.select_related('vendor').all()
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def perform_create(self, serializer):
        serializer.save(operator=self.request.user)
