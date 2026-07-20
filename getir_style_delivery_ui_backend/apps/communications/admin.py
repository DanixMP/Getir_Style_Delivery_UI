from django.contrib import admin
from unfold.admin import ModelAdmin

from .models import CallLog, FCMDevice


@admin.register(CallLog)
class CallLogAdmin(ModelAdmin):
    list_display = ('id', 'caller', 'receiver', 'channel_name', 'started_at', 'ended_at', 'duration_seconds')
    list_filter = ('initiated_by_operator',)
    search_fields = ('channel_name', 'caller__phone', 'receiver__phone')
    readonly_fields = ('started_at',)


@admin.register(FCMDevice)
class FCMDeviceAdmin(ModelAdmin):
    list_display = ('user', 'device_type', 'is_active', 'created_at')
    list_filter = ('device_type', 'is_active')
