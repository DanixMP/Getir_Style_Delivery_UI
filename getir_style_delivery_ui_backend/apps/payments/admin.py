from django.contrib import admin
from unfold.admin import ModelAdmin

from .models import ZarinpalTransaction


@admin.register(ZarinpalTransaction)
class ZarinpalTransactionAdmin(ModelAdmin):
    list_display = ('id', 'order', 'amount', 'status', 'ref_id', 'created_at', 'verified_at')
    list_filter = ('status', 'payment_method')
    search_fields = ('authority', 'ref_id', 'order__id')
    readonly_fields = ('created_at',)
