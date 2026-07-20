from rest_framework import serializers

from .models import PeykAssignment, TipaxShipment


class PeykAssignmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = PeykAssignment
        fields = [
            'id', 'order', 'peyk', 'assigned_at', 'picked_up_at',
            'delivered_at', 'estimated_delivery',
        ]
        read_only_fields = ['id', 'assigned_at', 'picked_up_at', 'delivered_at']


class TipaxShipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipaxShipment
        fields = [
            'id', 'order', 'peyk', 'tipax_branch_name', 'tipax_tracking_code',
            'dropped_at', 'code_entered_by', 'code_entered_at',
            'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'code_entered_by', 'code_entered_at', 'dropped_at',
            'created_at', 'updated_at',
        ]


class TipaxCodeEntrySerializer(serializers.Serializer):
    tipax_tracking_code = serializers.CharField(max_length=100)
    tipax_branch_name = serializers.CharField(max_length=200)
    peyk = serializers.UUIDField(required=False)
