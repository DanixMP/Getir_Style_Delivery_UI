from rest_framework import serializers

from .models import CallLog, FCMDevice


class CallInitiateSerializer(serializers.Serializer):
    order_id = serializers.UUIDField()
    consent_acknowledged = serializers.BooleanField()


class OperatorCallInitiateSerializer(serializers.Serializer):
    peyk_id = serializers.UUIDField()
    consent_acknowledged = serializers.BooleanField()


class CallEndSerializer(serializers.Serializer):
    call_log_id = serializers.UUIDField()


class CallLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = CallLog
        fields = [
            'id', 'order', 'caller', 'receiver', 'channel_name',
            'livekit_room_name', 'recording_path', 'started_at', 'ended_at',
            'duration_seconds', 'initiated_by_operator', 'consent_acknowledged',
        ]
        read_only_fields = fields


class FCMDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = FCMDevice
        fields = ['id', 'fcm_token', 'device_type', 'is_active', 'created_at']
        read_only_fields = ['id', 'is_active', 'created_at']
