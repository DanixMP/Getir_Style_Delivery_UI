import uuid

from django.conf import settings
from django.db import models


class CallLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey('orders.Order', on_delete=models.SET_NULL, null=True, blank=True)
    caller = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='calls_initiated')
    receiver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='calls_received', null=True, blank=True)
    channel_name = models.CharField(max_length=200)  # order_{order_id} or op_{operator_id}_{peyk_id}
    livekit_room_name = models.CharField(max_length=200)
    egress_id = models.CharField(max_length=200, blank=True)
    recording_path = models.CharField(max_length=500, blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    duration_seconds = models.IntegerField(default=0)
    initiated_by_operator = models.BooleanField(default=False)
    consent_acknowledged = models.BooleanField(default=False)

    class Meta:
        ordering = ['-started_at']

    def __str__(self):
        return f'Call {self.id} ({self.channel_name})'


class FCMDevice(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='fcm_devices')
    fcm_token = models.TextField(unique=True)
    device_type = models.CharField(max_length=10, choices=[('android', 'Android'), ('ios', 'iOS')])
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.device_type} device for {self.user_id}'
