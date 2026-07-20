import uuid

from django.conf import settings
from django.db import models

ORDER_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('preparing', 'Preparing'),
    ('picked_up', 'Picked Up'),
    ('delivered', 'Delivered'),
    ('ready', 'Ready'),
    ('served', 'Served'),
    ('cancelled', 'Cancelled'),
]

FULFILLMENT_TYPE = [
    ('delivery', 'Delivery'),
    ('dine_in', 'Dine In'),
]

DELIVERY_TYPE = [
    ('in_city', 'In City'),
    ('inter_city', 'Inter City'),
]

PAYMENT_METHOD = [
    ('online', 'Online'),
    ('cash', 'Cash'),
    ('card_in_person', 'Card in Person'),
    ('wallet', 'Wallet'),
]

# Roles that act as "operator" for transition purposes.
_OPERATOR_ROLES = {'operator', 'admin', 'developer'}

# Transition matrix: from_status -> {to_status: set of permitted roles}.
# 'peyk' transitions additionally require the actor be the assigned peyk
# (enforced in the view layer).
TRANSITIONS = {
    'pending': {
        'accepted': {'vendor', 'operator'},
        'cancelled': {'customer', 'vendor', 'operator'},
    },
    'accepted': {
        'preparing': {'vendor', 'operator'},
        'cancelled': {'vendor', 'operator'},
    },
    'preparing': {
        'picked_up': {'peyk'},
    },
    'picked_up': {
        'delivered': {'peyk'},
    },
}

DINE_IN_TRANSITIONS = {
    'pending': {
        'accepted': {'vendor', 'operator'},
        'cancelled': {'customer', 'vendor', 'operator'},
    },
    'accepted': {
        'preparing': {'vendor', 'operator'},
        'cancelled': {'vendor', 'operator'},
    },
    'preparing': {
        'ready': {'vendor', 'operator'},
    },
    'ready': {
        'served': {'vendor', 'operator'},
    },
}


class Order(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    customer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='orders')
    vendor = models.ForeignKey('accounts.VendorProfile', on_delete=models.PROTECT, related_name='orders')
    status = models.CharField(max_length=20, choices=ORDER_STATUS, default='pending')
    fulfillment_type = models.CharField(
        max_length=20, choices=FULFILLMENT_TYPE, default='delivery',
    )
    dining_table = models.ForeignKey(
        'catalog.DiningTable', on_delete=models.SET_NULL,
        null=True, blank=True, related_name='orders',
    )
    delivery_type = models.CharField(max_length=20, choices=DELIVERY_TYPE)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD)
    total_amount = models.BigIntegerField(default=0)  # Tomans, computed from items
    is_paid = models.BooleanField(default=False)
    # 6-digit handoff PIN: the customer reads it to the peyk at delivery, and
    # the peyk must enter the matching code to complete the picked_up→delivered
    # transition. Auto-generated on first save.
    delivery_code = models.CharField(max_length=6, blank=True)
    delivery_address = models.TextField(blank=True)
    delivery_city = models.CharField(max_length=100, blank=True)
    customer_notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Order {self.id} ({self.status})'

    def save(self, *args, **kwargs):
        if not self.delivery_code:
            import random
            self.delivery_code = f'{random.randint(0, 999999):06d}'
        super().save(*args, **kwargs)

    def can_transition_to(self, new_status: str, actor_role: str) -> bool:
        """Returns True if the transition is valid for this actor's role."""
        role = 'operator' if actor_role in _OPERATOR_ROLES else actor_role
        matrix = (
            DINE_IN_TRANSITIONS if self.fulfillment_type == 'dine_in' else TRANSITIONS
        )
        allowed = matrix.get(self.status, {}).get(new_status)
        return bool(allowed and role in allowed)

    def recompute_total(self) -> int:
        total = sum(oi.unit_price * oi.quantity for oi in self.items.all())
        self.total_amount = total
        return total


class OrderItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    item = models.ForeignKey('catalog.Item', on_delete=models.PROTECT)
    quantity = models.PositiveIntegerField()
    unit_price = models.BigIntegerField()  # snapshot of item.price at order time

    def __str__(self):
        return f'{self.quantity} x {self.item.name}'


class OfflineOrder(models.Model):
    """Created by Operators for customers who call by phone."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    operator = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='offline_orders_created')
    customer_phone = models.CharField(max_length=15)
    customer_name = models.CharField(max_length=100)
    vendor = models.ForeignKey('accounts.VendorProfile', on_delete=models.PROTECT)
    items_description = models.TextField()  # free text, no FK to Item
    total_amount = models.BigIntegerField()
    delivery_address = models.TextField()
    status = models.CharField(max_length=20, choices=ORDER_STATUS, default='pending')
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'OfflineOrder {self.id} ({self.customer_name})'
