import uuid

from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)
from django.db import models

ROLE_CHOICES = [
    ('customer', 'Customer'),
    ('peyk', 'Peyk'),
    ('vendor', 'Vendor'),
    ('operator', 'Operator'),
    ('admin', 'Admin'),
    ('developer', 'Developer'),
]

VEHICLE_CHOICES = [
    ('car', 'Car'),
    ('motor', 'Motor'),
]


class CustomUserManager(BaseUserManager):
    """Manager keyed on phone (the USERNAME_FIELD)."""

    def create_user(self, phone, password=None, **extra_fields):
        if not phone:
            raise ValueError('Users must have a phone number.')
        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password=None, **extra_fields):
        extra_fields.setdefault('role', 'developer')
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('full_name', 'Superuser')
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        return self.create_user(phone, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone = models.CharField(max_length=15, unique=True)  # login identifier
    email = models.EmailField(blank=True)
    full_name = models.CharField(max_length=100)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    city = models.CharField(max_length=100, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = CustomUserManager()

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['full_name', 'role']

    def __str__(self):
        return f'{self.full_name} ({self.phone})'


class PeykProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='peyk_profile')
    peyk_code = models.CharField(max_length=10, unique=True, blank=True)  # YLK-XXXXX, auto on save
    vehicle_type = models.CharField(max_length=10, choices=VEHICLE_CHOICES)
    is_verified = models.BooleanField(default=False)
    is_available = models.BooleanField(default=False)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    rating_count = models.IntegerField(default=0)
    complaint_count = models.IntegerField(default=0)
    photo = models.ImageField(upload_to='peyk_photos/', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.peyk_code} ({self.user.full_name})'


class VendorProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='vendor_profile')
    business_name = models.CharField(max_length=200)
    business_name_translations = models.JSONField(default=dict, blank=True)
    category = models.ForeignKey('catalog.Category', on_delete=models.PROTECT, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    rating_count = models.IntegerField(default=0)
    address = models.TextField()
    address_translations = models.JSONField(default=dict, blank=True)
    city = models.CharField(max_length=100)
    phone = models.CharField(max_length=15)
    logo = models.ImageField(upload_to='vendor_logos/', blank=True)
    description = models.TextField(blank=True)
    description_translations = models.JSONField(default=dict, blank=True)
    cover_image_url = models.URLField(blank=True, max_length=500)
    supports_dine_in = models.BooleanField(default=False)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.business_name


class OperatorProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='operator_profile')
    assigned_city = models.CharField(max_length=100)
    employee_id = models.CharField(max_length=20, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.employee_id} ({self.assigned_city})'


class PhoneOtp(models.Model):
    """One-time login code. Printed to the runserver console and visible in Admin."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone = models.CharField(max_length=15, db_index=True)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['phone', 'is_used', 'expires_at']),
        ]

    def __str__(self):
        return f'{self.phone} ({self.code})'
