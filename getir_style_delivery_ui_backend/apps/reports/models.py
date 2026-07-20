import uuid

from django.db import models

PERIOD_CHOICES = [
    ('daily', 'Daily'),
    ('weekly', 'Weekly'),
    ('monthly', 'Monthly'),
    ('yearly', 'Yearly'),
]


class VendorReport(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vendor = models.ForeignKey('accounts.VendorProfile', on_delete=models.CASCADE, related_name='reports')
    period = models.CharField(max_length=10, choices=PERIOD_CHOICES)
    period_start = models.DateField()
    period_end = models.DateField()
    total_orders = models.IntegerField(default=0)
    total_revenue = models.BigIntegerField(default=0)  # Tomans
    avg_order_value = models.BigIntegerField(default=0)  # Tomans
    generated_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [['vendor', 'period', 'period_start']]
        ordering = ['-period_start']

    def __str__(self):
        return f'{self.vendor.business_name} {self.period} {self.period_start}'
