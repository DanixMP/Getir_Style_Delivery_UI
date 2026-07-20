from rest_framework import serializers

from .models import Wallet, WalletTopUp, WalletTransaction


class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wallet
        fields = ['id', 'balance', 'is_active', 'created_at', 'updated_at']
        read_only_fields = fields


class WalletTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = WalletTransaction
        fields = [
            'id', 'direction', 'txn_type', 'amount', 'balance_after',
            'order', 'description', 'created_at',
        ]
        read_only_fields = fields


class TopUpInitiateSerializer(serializers.Serializer):
    amount = serializers.IntegerField(min_value=1000)  # min 1,000 Tomans


class TopUpSerializer(serializers.ModelSerializer):
    class Meta:
        model = WalletTopUp
        fields = ['id', 'amount', 'authority', 'status', 'ref_id', 'created_at', 'verified_at']
        read_only_fields = fields


class PayOrderSerializer(serializers.Serializer):
    order_id = serializers.UUIDField()
