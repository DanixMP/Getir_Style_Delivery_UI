from rest_framework import serializers

from apps.localization import LocalizedFieldsMixin, TranslationMapField, localized_attr
from apps.accounts.models import VendorProfile

from .models import Category, DiningTable, HomeBanner, HomeFeaturedItem, Item, ItemGallery, VenuePanorama, VendorGallery


class CategorySerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('name',)

    class Meta:
        model = Category
        fields = [
            'id', 'name', 'slug', 'icon_url', 'display_order',
            'is_coming_soon', 'is_active', 'created_at',
        ]


class ItemGallerySerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemGallery
        fields = ['id', 'image', 'is_primary', 'order', 'uploaded_at']


class VendorGallerySerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('caption',)

    class Meta:
        model = VendorGallery
        fields = ['id', 'image', 'caption', 'order', 'uploaded_at']


class ItemSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('name', 'description')
    gallery = ItemGallerySerializer(many=True, read_only=True)
    category_slug = serializers.CharField(source='category.slug', read_only=True)
    vendor_name = serializers.SerializerMethodField()

    class Meta:
        model = Item
        fields = [
            'id', 'vendor', 'vendor_name', 'category', 'category_slug',
            'name', 'description', 'price', 'is_available', 'rating',
            'rating_count', 'city', 'gallery', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'rating', 'rating_count', 'created_at', 'updated_at']

    def get_vendor_name(self, obj):
        request = self.context.get('request')
        return localized_attr(obj.vendor, 'business_name', request=request)


class ItemWriteSerializer(serializers.ModelSerializer):
    """Used for create/update; vendor is resolved server-side for vendor role."""
    name_translations = TranslationMapField(required=False)
    description_translations = TranslationMapField(required=False)

    class Meta:
        model = Item
        fields = [
            'id', 'vendor', 'category', 'name', 'name_translations',
            'description', 'description_translations',
            'price', 'is_available', 'city',
        ]
        read_only_fields = ['id']
        extra_kwargs = {
            # Vendor role: injected from the request user in perform_create.
            # Operator role: validated as required in the view.
            'vendor': {'required': False},
        }


class VendorListSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    """Lightweight vendor representation for the catalog vendor list."""
    localized_fields = ('business_name', 'address', 'description')

    class Meta:
        model = VendorProfile
        fields = [
            'id', 'business_name', 'category', 'city', 'address', 'rating',
            'rating_count', 'logo', 'description', 'cover_image_url', 'is_active',
            'supports_dine_in', 'latitude', 'longitude',
        ]


class VendorDetailSerializer(VendorListSerializer):
    """Vendor detail with gallery + active items."""
    gallery = VendorGallerySerializer(many=True, read_only=True)
    items = serializers.SerializerMethodField()

    class Meta:
        model = VendorProfile
        fields = [
            'id', 'business_name', 'category', 'city', 'address', 'phone',
            'rating', 'rating_count', 'logo', 'description', 'cover_image_url',
            'is_active', 'supports_dine_in', 'latitude', 'longitude',
            'gallery', 'items',
        ]

    def get_items(self, obj):
        active = obj.items.filter(is_available=True).select_related('category', 'vendor')
        return ItemSerializer(active, many=True, context=self.context).data


class HomeBannerSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('title', 'subtitle')
    image = serializers.SerializerMethodField()

    class Meta:
        model = HomeBanner
        fields = [
            'id', 'title', 'subtitle', 'image', 'category_slug',
            'display_order',
        ]

    def get_image(self, obj):
        if obj.image:
            request = self.context.get('request')
            url = obj.image.url
            if request is not None:
                return request.build_absolute_uri(url)
            return url
        return obj.image_url or ''


class HomeFeaturedItemSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('badge_text',)
    item = serializers.SerializerMethodField()
    original_price = serializers.IntegerField(source='item.price', read_only=True)
    effective_price = serializers.SerializerMethodField()

    class Meta:
        model = HomeFeaturedItem
        fields = [
            'id', 'section', 'item', 'sale_price', 'original_price',
            'effective_price', 'badge_text', 'display_order',
        ]

    def get_effective_price(self, obj):
        if obj.sale_price is not None and obj.sale_price > 0:
            return obj.sale_price
        return obj.item.price

    def get_item(self, obj):
        return ItemSerializer(obj.item, context=self.context).data


class DiningTableSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('label',)

    class Meta:
        model = DiningTable
        fields = [
            'id', 'label', 'hotspot_yaw', 'hotspot_pitch',
            'capacity', 'status',
        ]


class VenuePanoramaSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('title',)
    image = serializers.SerializerMethodField()

    class Meta:
        model = VenuePanorama
        fields = ['id', 'title', 'image', 'initial_yaw']

    def get_image(self, obj):
        if obj.image:
            request = self.context.get('request')
            url = obj.image.url
            if request is not None:
                return request.build_absolute_uri(url)
            return url
        return obj.image_url or ''


class DineInVenueSerializer(VendorListSerializer):
    """Vendor dine-in payload: summary, panorama, and table hotspots."""
    panorama = serializers.SerializerMethodField()
    tables = serializers.SerializerMethodField()

    class Meta:
        model = VendorProfile
        fields = [
            'id', 'business_name', 'city', 'address', 'rating', 'rating_count',
            'logo', 'description', 'latitude', 'longitude',
            'supports_dine_in', 'panorama', 'tables',
        ]

    def get_panorama(self, obj):
        pano = obj.panoramas.filter(is_active=True).first()
        if pano is None:
            return None
        return VenuePanoramaSerializer(pano, context=self.context).data

    def get_tables(self, obj):
        tables = obj.dining_tables.all()
        return DiningTableSerializer(tables, many=True, context=self.context).data


# HomePromoView returns a composite JSON object (see views.HomePromoView).
