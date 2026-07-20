from django.conf import settings
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsOperator
from apps.orders.models import Order

from .models import CallLog, FCMDevice
from .serializers import (
    CallEndSerializer,
    CallInitiateSerializer,
    FCMDeviceSerializer,
    OperatorCallInitiateSerializer,
)
from .voip_adapter import get_voip_adapter

TOKEN_TTL_SECONDS = 3600
_CALLABLE_ORDER_STATUSES = {'accepted', 'preparing', 'picked_up'}


def _resolve_receiver(order, caller):
    """Return the other party on an order, or None."""
    assignment = getattr(order, 'assignment', None)
    peyk = assignment.peyk if assignment else None
    if caller.id == order.customer_id:
        return peyk
    if peyk and caller.id == peyk.id:
        return order.customer
    return order.customer if caller.id != order.customer_id else peyk


class CallInitiateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CallInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if not data['consent_acknowledged']:
            return Response({'detail': 'Call recording consent is required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            order = Order.objects.select_related('customer', 'assignment__peyk').get(id=data['order_id'])
        except Order.DoesNotExist:
            return Response({'detail': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        assignment = getattr(order, 'assignment', None)
        if order.status not in _CALLABLE_ORDER_STATUSES or assignment is None:
            return Response({'detail': 'Calls are available only for active assigned orders.'},
                            status=status.HTTP_400_BAD_REQUEST)
        is_party = user.id == order.customer_id or assignment.peyk_id == user.id
        if not is_party:
            return Response({'detail': 'You are not a party to this order.'},
                            status=status.HTTP_403_FORBIDDEN)

        channel_name = f'order_{order.id}'
        receiver = _resolve_receiver(order, user)
        adapter = get_voip_adapter()
        token = adapter.generate_token(channel_name, str(user.id), user.full_name, TOKEN_TTL_SECONDS)

        call_log = CallLog.objects.create(
            order=order, caller=user, receiver=receiver,
            channel_name=channel_name, livekit_room_name=channel_name,
            initiated_by_operator=False, consent_acknowledged=True,
        )
        egress_id = adapter.start_recording(channel_name, str(order.id))
        if egress_id:
            call_log.egress_id = egress_id
            call_log.save(update_fields=['egress_id'])

        if receiver is not None:
            self._notify(receiver, channel_name, token)

        return Response({
            'token': token,
            'channel_name': channel_name,
            'livekit_url': settings.LIVEKIT_URL,
            'call_log_id': str(call_log.id),
        })

    def _notify(self, receiver, channel_name, token):
        try:
            from apps.notifications.services import notify_peyk_incoming_call
            notify_peyk_incoming_call(str(receiver.id), channel_name, settings.LIVEKIT_URL, token)
        except Exception:
            pass


class OperatorCallInitiateView(APIView):
    """Operator -> Peyk call, bypasses order validation."""
    permission_classes = [IsOperator]

    def post(self, request):
        serializer = OperatorCallInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        from .call_service import operator_initiate_call
        payload, code = operator_initiate_call(
            request.user, data['peyk_id'], data['consent_acknowledged'],
        )
        return Response(payload, status=code)


class CallEndView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CallEndSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            call_log = CallLog.objects.get(id=serializer.validated_data['call_log_id'])
        except CallLog.DoesNotExist:
            return Response({'detail': 'Call log not found.'}, status=status.HTTP_404_NOT_FOUND)

        call_log.ended_at = timezone.now()
        call_log.duration_seconds = int((call_log.ended_at - call_log.started_at).total_seconds())
        adapter = get_voip_adapter()
        adapter.stop_recording(call_log.egress_id)
        if call_log.egress_id:
            call_log.recording_path = f'recordings/order_{call_log.order_id}_{call_log.channel_name}.mp4'
        call_log.save(update_fields=['ended_at', 'duration_seconds', 'recording_path'])
        return Response({'detail': 'Call ended.', 'duration_seconds': call_log.duration_seconds})


class DeviceRegisterView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = FCMDeviceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        device, _ = FCMDevice.objects.update_or_create(
            fcm_token=serializer.validated_data['fcm_token'],
            defaults={
                'user': request.user,
                'device_type': serializer.validated_data['device_type'],
                'is_active': True,
            },
        )
        return Response(FCMDeviceSerializer(device).data, status=status.HTTP_201_CREATED)


class DeviceDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, fcm_token):
        deleted, _ = FCMDevice.objects.filter(user=request.user, fcm_token=fcm_token).delete()
        if not deleted:
            return Response({'detail': 'Device not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)
