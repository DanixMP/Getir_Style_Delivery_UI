from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsOperator, IsPeyk

from .models import PeykAssignment, TipaxShipment
from .serializers import (
    PeykAssignmentSerializer,
    TipaxCodeEntrySerializer,
    TipaxShipmentSerializer,
)

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class PeykAssignmentViewSet(viewsets.ModelViewSet):
    serializer_class = PeykAssignmentSerializer
    queryset = PeykAssignment.objects.select_related('order', 'peyk').all()
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update'):
            return [IsOperator()]
        return [IsAuthenticated()]

    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if user.role in _OPERATOR_ROLES:
            return qs
        if user.role == 'peyk':
            return qs.filter(peyk=user)
        # Customers may see the assignment for their own orders.
        return qs.filter(order__customer=user)

    def perform_create(self, serializer):
        assignment = serializer.save()
        # Inter-city orders ship via Tipax: create a pending shipment so the
        # Peyk can confirm drop-off and the operator can later enter the code.
        order = assignment.order
        if order.delivery_type == 'inter_city':
            TipaxShipment.objects.get_or_create(
                order=order, defaults={'peyk': assignment.peyk},
            )
        self._notify_peyk(assignment)
        self._broadcast_assignment(assignment)

    def _notify_peyk(self, assignment):
        try:
            from apps.notifications.services import notify_peyk_new_order
            notify_peyk_new_order(str(assignment.peyk_id), str(assignment.order_id))
        except Exception:  # notifications must never break the request
            pass

    def _broadcast_assignment(self, assignment):
        try:
            from .services import broadcast_peyk_assignment
            broadcast_peyk_assignment(assignment)
        except Exception:  # broadcast must never break the request
            pass


class TipaxCodeEntryView(APIView):
    """Operator enters the Tipax tracking code for an inter-city order."""
    permission_classes = [IsOperator]

    def patch(self, request, order_id):
        serializer = TipaxCodeEntrySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        defaults = {
            'tipax_branch_name': data['tipax_branch_name'],
            'tipax_tracking_code': data['tipax_tracking_code'],
            'code_entered_by': request.user,
            'code_entered_at': timezone.now(),
        }
        peyk_id = data.get('peyk')
        if peyk_id:
            defaults['peyk_id'] = peyk_id

        shipment = TipaxShipment.objects.filter(order_id=order_id).first()
        if shipment is None:
            if not peyk_id:
                return Response(
                    {'detail': 'peyk is required to create a new Tipax shipment.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            shipment = TipaxShipment.objects.create(order_id=order_id, **defaults)
        else:
            for field, value in defaults.items():
                setattr(shipment, field, value)
            shipment.save()
        return Response(TipaxShipmentSerializer(shipment).data)


class TipaxConfirmDropView(APIView):
    """Peyk confirms they dropped the package at the Tipax branch."""
    permission_classes = [IsPeyk]

    def patch(self, request, order_id):
        shipment = TipaxShipment.objects.filter(order_id=order_id).first()
        if shipment is None:
            return Response({'detail': 'Tipax shipment not found.'},
                            status=status.HTTP_404_NOT_FOUND)
        if shipment.peyk_id != request.user.id:
            return Response({'detail': 'You are not assigned to this shipment.'},
                            status=status.HTTP_403_FORBIDDEN)
        shipment.dropped_at = timezone.now()
        shipment.save(update_fields=['dropped_at', 'updated_at'])
        return Response(TipaxShipmentSerializer(shipment).data)
