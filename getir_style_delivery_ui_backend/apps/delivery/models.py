import uuid

from django.conf import settings
from django.db import models


class PeykAssignment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='assignment')
    peyk = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='assignments')
    assigned_at = models.DateTimeField(auto_now_add=True)
    picked_up_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    estimated_delivery = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-assigned_at']

    def __str__(self):
        return f'Assignment {self.order_id} -> {self.peyk_id}'


class TipaxShipment(models.Model):
    """
    Only created when order.delivery_type == 'inter_city'. The Peyk physically
    delivers the package to a Tipax branch; the operator manually enters the
    tracking code after the Peyk confirms drop-off. No Tipax API integration.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='tipax_shipment')
    peyk = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='tipax_deliveries')
    tipax_branch_name = models.CharField(max_length=200, blank=True)
    tipax_tracking_code = models.CharField(max_length=100, blank=True)  # entered by operator
    dropped_at = models.DateTimeField(null=True, blank=True)  # when Peyk confirms drop
    code_entered_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='tipax_codes_entered',
    )
    code_entered_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'Tipax {self.order_id} ({self.tipax_tracking_code or "pending"})'


# COMING SOON — No serializer, no view, no URL for this model yet.
# Created now so the migration exists when the taxi feature is implemented.
class TaxiRide(models.Model):
    """
    Extends an Order of type taxi. Only relevant when
    order.category == Category(slug='getir_style_delivery_ui-taxi').
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='taxi_ride')
    pickup_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    pickup_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    pickup_address = models.TextField()
    destination_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    destination_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    destination_address = models.TextField()
    estimated_fare = models.BigIntegerField(default=0)  # Tomans
    ride_type = models.CharField(
        max_length=20,
        choices=[('standard', 'Standard'), ('comfort', 'Comfort')],
        default='standard',
    )
    distance_km = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Taxi Ride (Coming Soon)'
