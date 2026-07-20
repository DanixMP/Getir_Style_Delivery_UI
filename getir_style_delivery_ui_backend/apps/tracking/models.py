import uuid

from django.conf import settings
from django.db import models


class GPSSnapshot(models.Model):
    """
    Peyk POSTs location every N seconds via REST. Django Channels broadcasts
    to the order's tracking group. Snapshots are stored for history/audit but
    not displayed beyond the last point.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    peyk = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='gps_snapshots')
    order = models.ForeignKey('orders.Order', on_delete=models.SET_NULL, null=True, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['peyk', '-timestamp']),
            models.Index(fields=['order', '-timestamp']),
        ]

    def __str__(self):
        return f'{self.peyk_id} @ ({self.latitude}, {self.longitude})'
