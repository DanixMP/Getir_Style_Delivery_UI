from django.contrib import admin
from unfold.admin import ModelAdmin, TabularInline

from .models import OfflineOrder, Order, OrderItem


class OrderItemInline(TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('unit_price',)


@admin.register(Order)
class OrderAdmin(ModelAdmin):
    list_display = (
        'id', 'customer', 'vendor', 'status', 'fulfillment_type',
        'delivery_type', 'total_amount', 'created_at',
    )
    list_filter = ('status', 'fulfillment_type', 'delivery_type', 'payment_method')
    search_fields = ('id', 'customer__phone', 'vendor__business_name')
    inlines = [OrderItemInline]
    readonly_fields = ('total_amount',)


@admin.register(OfflineOrder)
class OfflineOrderAdmin(ModelAdmin):
    list_display = ('id', 'customer_name', 'customer_phone', 'vendor', 'status', 'total_amount', 'created_at')
    list_filter = ('status',)
    search_fields = ('customer_name', 'customer_phone')
