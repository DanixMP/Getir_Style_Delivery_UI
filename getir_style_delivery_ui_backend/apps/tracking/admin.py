from django.contrib import admin
from unfold.admin import ModelAdmin

from .models import GPSSnapshot


@admin.register(GPSSnapshot)
class GPSSnapshotAdmin(ModelAdmin):
    list_display = ('peyk', 'order', 'latitude', 'longitude', 'timestamp')
    list_filter = ('timestamp',)
    search_fields = ('peyk__phone',)
