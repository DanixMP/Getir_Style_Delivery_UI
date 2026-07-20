from rest_framework import serializers

from .models import ZarinpalTransaction


class PaymentInitiateSerializer(serializers.Serializer):
    order_id = serializers.UUIDField()


class ZarinpalTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ZarinpalTransaction
        fields = [
            'id', 'order', 'amount', 'authority', 'status',
            'ref_id', 'payment_method', 'created_at', 'verified_at',
        ]
        read_only_fields = fields
