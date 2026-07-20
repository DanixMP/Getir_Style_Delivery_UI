from django.contrib import admin
from unfold.admin import ModelAdmin, TabularInline

from .models import Wallet, WalletTopUp, WalletTransaction


class WalletTransactionInline(TabularInline):
    model = WalletTransaction
    extra = 0
    can_delete = False
    readonly_fields = ('direction', 'txn_type', 'amount', 'balance_after', 'order', 'description', 'created_at')
    ordering = ('-created_at',)

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(Wallet)
class WalletAdmin(ModelAdmin):
    list_display = ('user', 'balance', 'is_active', 'updated_at')
    list_filter = ('is_active',)
    search_fields = ('user__phone', 'user__full_name')
    readonly_fields = ('balance', 'created_at', 'updated_at')
    inlines = [WalletTransactionInline]


@admin.register(WalletTransaction)
class WalletTransactionAdmin(ModelAdmin):
    list_display = ('wallet', 'direction', 'txn_type', 'amount', 'balance_after', 'created_at')
    list_filter = ('direction', 'txn_type')
    search_fields = ('wallet__user__phone',)
    readonly_fields = ('wallet', 'direction', 'txn_type', 'amount', 'balance_after', 'order', 'description', 'created_at')


@admin.register(WalletTopUp)
class WalletTopUpAdmin(ModelAdmin):
    list_display = ('wallet', 'amount', 'status', 'ref_id', 'created_at', 'verified_at')
    list_filter = ('status',)
    search_fields = ('authority', 'ref_id', 'wallet__user__phone')
