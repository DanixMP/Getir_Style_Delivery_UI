from django.contrib import admin
from unfold.admin import ModelAdmin

from .models import VendorReport


@admin.register(VendorReport)
class VendorReportAdmin(ModelAdmin):
    list_display = ('vendor', 'period', 'period_start', 'total_orders', 'total_revenue', 'avg_order_value')
    list_filter = ('period',)
    search_fields = ('vendor__business_name',)
    readonly_fields = ('generated_at',)
