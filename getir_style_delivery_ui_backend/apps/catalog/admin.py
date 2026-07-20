from django.contrib import admin
from unfold.admin import ModelAdmin, TabularInline

from .models import Category, DiningTable, HomeBanner, HomeFeaturedItem, Item, ItemGallery, VenuePanorama, VendorGallery


class ItemGalleryInline(TabularInline):
    model = ItemGallery
    extra = 1


@admin.register(Category)
class CategoryAdmin(ModelAdmin):
    list_display = ('name', 'slug', 'display_order', 'is_coming_soon', 'is_active')
    list_filter = ('is_coming_soon', 'is_active')
    prepopulated_fields = {'slug': ('name',)}
    fields = (
        'name', 'name_translations', 'slug', 'icon_url', 'display_order',
        'is_coming_soon', 'is_active',
    )


@admin.register(Item)
class ItemAdmin(ModelAdmin):
    list_display = ('name', 'vendor', 'category', 'price', 'is_available', 'city', 'rating')
    list_filter = ('is_available', 'category', 'city')
    search_fields = ('name', 'description', 'name_translations', 'description_translations')
    fields = (
        'vendor', 'category', 'name', 'name_translations',
        'description', 'description_translations',
        'price', 'is_available', 'city', 'rating', 'rating_count',
    )
    inlines = [ItemGalleryInline]


@admin.register(ItemGallery)
class ItemGalleryAdmin(ModelAdmin):
    list_display = ('item', 'is_primary', 'order')


@admin.register(VendorGallery)
class VendorGalleryAdmin(ModelAdmin):
    list_display = ('vendor', 'caption', 'order')
    fields = ('vendor', 'image', 'caption', 'caption_translations', 'order')


@admin.register(HomeBanner)
class HomeBannerAdmin(ModelAdmin):
    list_display = ('title', 'city', 'display_order', 'is_active', 'starts_at', 'ends_at')
    list_filter = ('is_active', 'city')
    search_fields = ('title', 'subtitle', 'title_translations', 'subtitle_translations')
    fields = (
        'title', 'title_translations', 'subtitle', 'subtitle_translations',
        'image', 'image_url', 'city', 'category_slug', 'display_order',
        'is_active', 'starts_at', 'ends_at',
    )
    ordering = ('display_order', '-created_at')


@admin.register(HomeFeaturedItem)
class HomeFeaturedItemAdmin(ModelAdmin):
    list_display = ('item', 'section', 'sale_price', 'city', 'special_date', 'display_order', 'is_active')
    list_filter = ('section', 'is_active', 'city')
    search_fields = ('item__name', 'badge_text', 'badge_text_translations')
    fields = (
        'item', 'section', 'sale_price', 'badge_text', 'badge_text_translations',
        'city', 'display_order', 'is_active', 'special_date',
    )
    autocomplete_fields = ('item',)
    ordering = ('section', 'display_order')


class DiningTableInline(TabularInline):
    model = DiningTable
    extra = 1
    fields = (
        'label', 'label_translations', 'hotspot_yaw', 'hotspot_pitch',
        'capacity', 'status', 'panorama',
    )


@admin.register(VenuePanorama)
class VenuePanoramaAdmin(ModelAdmin):
    list_display = ('vendor', 'title', 'is_active', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('vendor__business_name', 'title', 'title_translations')
    fields = (
        'vendor', 'title', 'title_translations', 'image', 'image_url',
        'initial_yaw', 'is_active',
    )
    inlines = [DiningTableInline]


@admin.register(DiningTable)
class DiningTableAdmin(ModelAdmin):
    list_display = ('label', 'vendor', 'capacity', 'status', 'hotspot_yaw', 'hotspot_pitch')
    list_filter = ('status', 'vendor')
    search_fields = ('label', 'label_translations', 'vendor__business_name')
    fields = (
        'vendor', 'panorama', 'label', 'label_translations',
        'hotspot_yaw', 'hotspot_pitch', 'capacity', 'status',
    )
