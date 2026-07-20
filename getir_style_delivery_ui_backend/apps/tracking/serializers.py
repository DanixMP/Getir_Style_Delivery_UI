from rest_framework import serializers

from .models import GPSSnapshot


class GPSSnapshotSerializer(serializers.ModelSerializer):
    class Meta:
        model = GPSSnapshot
        fields = ['id', 'peyk', 'order', 'latitude', 'longitude', 'timestamp']
        read_only_fields = ['id', 'peyk', 'timestamp']


class LocationPostSerializer(serializers.Serializer):
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    order_id = serializers.UUIDField(required=False, allow_null=True)
