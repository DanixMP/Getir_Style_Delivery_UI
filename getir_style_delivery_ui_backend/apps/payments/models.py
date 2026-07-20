import uuid

from django.db import models

PAYMENT_STATUS = [
    ('pending', 'Pending'),
    ('verified', 'Verified'),
    ('failed', 'Failed'),
]


class ZarinpalTransaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey('orders.Order', on_delete=models.PROTECT, related_name='transactions')
    amount = models.BigIntegerField()  # Tomans
    authority = models.CharField(max_length=100, unique=True, blank=True)
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    ref_id = models.CharField(max_length=100, blank=True)  # from Zarinpal on success
    payment_method = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)
    verified_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Txn {self.id} ({self.status})'
