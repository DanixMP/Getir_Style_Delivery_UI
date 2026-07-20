from django.contrib import admin
from unfold.admin import ModelAdmin

from .models import PeykAssignment, TaxiRide, TipaxShipment


@admin.register(PeykAssignment)
class PeykAssignmentAdmin(ModelAdmin):
    list_display = ('order', 'peyk', 'assigned_at', 'picked_up_at', 'delivered_at')
    search_fields = ('order__id', 'peyk__phone')


@admin.register(TipaxShipment)
class TipaxShipmentAdmin(ModelAdmin):
    list_display = ('order', 'peyk', 'tipax_branch_name', 'tipax_tracking_code', 'dropped_at')
    search_fields = ('tipax_tracking_code', 'order__id')


@admin.register(TaxiRide)
class TaxiRideAdmin(ModelAdmin):
    list_display = ('order', 'ride_type', 'estimated_fare', 'created_at')
