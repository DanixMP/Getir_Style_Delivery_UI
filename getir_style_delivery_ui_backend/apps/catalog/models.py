import uuid

from django.db import models


class Category(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    name_translations = models.JSONField(default=dict, blank=True)
    slug = models.SlugField(max_length=100, unique=True)
    icon_url = models.CharField(max_length=255, blank=True)
    display_order = models.PositiveSmallIntegerField(default=0)
    is_coming_soon = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['display_order', 'name']
        verbose_name_plural = 'categories'

    def __str__(self):
        return self.name


class Item(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vendor = models.ForeignKey('accounts.VendorProfile', on_delete=models.CASCADE, related_name='items')
    category = models.ForeignKey(Category, on_delete=models.PROTECT, related_name='items')
    name = models.CharField(max_length=200)
    name_translations = models.JSONField(default=dict, blank=True)
    description = models.TextField(blank=True)
    description_translations = models.JSONField(default=dict, blank=True)
    price = models.BigIntegerField()  # Tomans
    is_available = models.BooleanField(default=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    rating_count = models.IntegerField(default=0)
    city = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['city', 'is_available']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return self.name


class ItemGallery(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='gallery')
    image = models.ImageField(upload_to='item_gallery/')
    is_primary = models.BooleanField(default=False)
    order = models.PositiveSmallIntegerField(default=0)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', 'uploaded_at']


class VendorGallery(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vendor = models.ForeignKey('accounts.VendorProfile', on_delete=models.CASCADE, related_name='gallery')
    image = models.ImageField(upload_to='vendor_gallery/')
    caption = models.CharField(max_length=200, blank=True)
    caption_translations = models.JSONField(default=dict, blank=True)
    order = models.PositiveSmallIntegerField(default=0)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', 'uploaded_at']


class HomeBanner(models.Model):
    """Carousel banners on the customer home screen (editable in Django admin)."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=120)
    title_translations = models.JSONField(default=dict, blank=True)
    subtitle = models.CharField(max_length=200, blank=True)
    subtitle_translations = models.JSONField(default=dict, blank=True)
    image = models.ImageField(upload_to='home_banners/', blank=True)
    image_url = models.CharField(
        max_length=500, blank=True,
        help_text='Optional external image URL when no upload is set.',
    )
    city = models.CharField(
        max_length=100, blank=True,
        help_text='Leave blank to show in all cities.',
    )
    category_slug = models.SlugField(
        max_length=100, blank=True,
        help_text='Optional category to open when the banner is tapped.',
    )
    display_order = models.PositiveSmallIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    starts_at = models.DateTimeField(null=True, blank=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['display_order', '-created_at']

    def __str__(self):
        return self.title


class HomeFeaturedItem(models.Model):
    """Discounted items and today's specials on the home screen."""
    SECTION_DISCOUNTED = 'discounted'
    SECTION_TODAY_SPECIAL = 'today_special'
    SECTION_CHOICES = [
        (SECTION_DISCOUNTED, 'Discounted'),
        (SECTION_TODAY_SPECIAL, "Today's special"),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='home_features')
    section = models.CharField(max_length=20, choices=SECTION_CHOICES)
    sale_price = models.BigIntegerField(
        null=True, blank=True,
        help_text='Promo price in Tomans (required for discounted items).',
    )
    badge_text = models.CharField(max_length=40, blank=True)
    badge_text_translations = models.JSONField(default=dict, blank=True)
    city = models.CharField(max_length=100, blank=True)
    display_order = models.PositiveSmallIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    special_date = models.DateField(
        null=True, blank=True,
        help_text="For today's specials: show only on this date (blank = every day).",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['display_order', '-created_at']
        indexes = [models.Index(fields=['section', 'is_active'])]

    def __str__(self):
        return f'{self.get_section_display()}: {self.item.name}'


class VenuePanorama(models.Model):
    """Equirectangular 360° photo for dine-in table picking."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vendor = models.ForeignKey(
        'accounts.VendorProfile', on_delete=models.CASCADE, related_name='panoramas',
    )
    title = models.CharField(max_length=120, default='Main hall')
    title_translations = models.JSONField(default=dict, blank=True)
    image = models.ImageField(upload_to='venue_panoramas/', blank=True)
    image_url = models.CharField(
        max_length=500, blank=True,
        help_text='External 360 image URL when no upload is set.',
    )
    initial_yaw = models.FloatField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.vendor.business_name} — {self.title}'


TABLE_STATUS = [
    ('available', 'Available'),
    ('occupied', 'Occupied'),
    ('reserved', 'Reserved'),
]


class DiningTable(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vendor = models.ForeignKey(
        'accounts.VendorProfile', on_delete=models.CASCADE, related_name='dining_tables',
    )
    panorama = models.ForeignKey(
        VenuePanorama, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='tables',
    )
    label = models.CharField(max_length=40)
    label_translations = models.JSONField(default=dict, blank=True)
    hotspot_yaw = models.FloatField(default=0)
    hotspot_pitch = models.FloatField(default=0)
    capacity = models.PositiveSmallIntegerField(default=2)
    status = models.CharField(max_length=20, choices=TABLE_STATUS, default='available')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['label']
        unique_together = [('vendor', 'label')]

    def __str__(self):
        return f'{self.vendor.business_name} — {self.label}'
