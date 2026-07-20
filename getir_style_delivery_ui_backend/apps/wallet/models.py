import uuid

from django.conf import settings
from django.db import models

# Ledger entry kinds.
TXN_TYPE = [
    ('topup', 'Top-up'),            # credit, funded via Zarinpal
    ('order_payment', 'Order Payment'),  # debit, paying for an order
    ('refund', 'Refund'),           # credit, refund of a cancelled order
    ('adjustment', 'Adjustment'),   # credit/debit, manual correction
]

# Direction: credit increases balance, debit decreases it.
DIRECTION = [
    ('credit', 'Credit'),
    ('debit', 'Debit'),
]

TOPUP_STATUS = [
    ('pending', 'Pending'),
    ('verified', 'Verified'),
    ('failed', 'Failed'),
]


class Wallet(models.Model):
    """One wallet per user. Balance is stored in Tomans (never negative)."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wallet')
    balance = models.BigIntegerField(default=0)  # Tomans
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'Wallet({self.user_id}) = {self.balance}'


class WalletTransaction(models.Model):
    """
    Immutable ledger entry. `balance_after` snapshots the wallet balance
    once the entry is applied, giving a tamper-evident running history.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='transactions')
    direction = models.CharField(max_length=10, choices=DIRECTION)
    txn_type = models.CharField(max_length=20, choices=TXN_TYPE)
    amount = models.BigIntegerField()  # Tomans, always positive
    balance_after = models.BigIntegerField()
    order = models.ForeignKey('orders.Order', on_delete=models.SET_NULL, null=True, blank=True, related_name='wallet_transactions')
    description = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['wallet', '-created_at']),
        ]

    def __str__(self):
        sign = '+' if self.direction == 'credit' else '-'
        return f'{sign}{self.amount} ({self.txn_type})'


class WalletTopUp(models.Model):
    """A Zarinpal-funded top-up. Mirrors ZarinpalTransaction but for wallets."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet = models.ForeignKey(Wallet, on_delete=models.PROTECT, related_name='topups')
    amount = models.BigIntegerField()  # Tomans
    authority = models.CharField(max_length=100, unique=True, blank=True)
    status = models.CharField(max_length=20, choices=TOPUP_STATUS, default='pending')
    ref_id = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    verified_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'TopUp {self.amount} ({self.status})'
