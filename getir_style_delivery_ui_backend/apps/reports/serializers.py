from rest_framework import serializers

from .models import VendorReport


class VendorReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = VendorReport
        fields = [
            'id', 'vendor', 'period', 'period_start', 'period_end',
            'total_orders', 'total_revenue', 'avg_order_value', 'generated_at',
        ]
        read_only_fields = fields
