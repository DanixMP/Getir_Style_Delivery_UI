from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from unfold.admin import ModelAdmin

from .models import CustomUser, OperatorProfile, PeykProfile, PhoneOtp, VendorProfile


@admin.register(CustomUser)
class CustomUserAdmin(BaseUserAdmin, ModelAdmin):
    ordering = ('phone',)
    list_display = ('phone', 'full_name', 'role', 'city', 'is_active', 'is_staff')
    list_filter = ('role', 'is_active', 'is_staff')
    search_fields = ('phone', 'full_name', 'email')
    readonly_fields = ('id', 'date_joined', 'updated_at', 'last_login')
    fieldsets = (
        (None, {'fields': ('phone', 'password')}),
        ('Personal', {'fields': ('full_name', 'email', 'city', 'role')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Dates', {'fields': ('last_login', 'date_joined', 'updated_at')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone', 'full_name', 'role', 'password1', 'password2'),
        }),
    )


@admin.register(PeykProfile)
class PeykProfileAdmin(ModelAdmin):
    list_display = ('peyk_code', 'user', 'vehicle_type', 'is_verified', 'is_available', 'rating')
    list_filter = ('vehicle_type', 'is_verified', 'is_available')
    search_fields = ('peyk_code', 'user__full_name', 'user__phone')


@admin.register(VendorProfile)
class VendorProfileAdmin(ModelAdmin):
    list_display = ('business_name', 'city', 'supports_dine_in', 'is_active', 'rating')
    list_filter = ('is_active', 'city', 'supports_dine_in')
    search_fields = ('business_name', 'business_name_translations', 'user__phone')
    fields = (
        'user', 'business_name', 'business_name_translations', 'category',
        'is_active', 'rating', 'rating_count', 'address', 'address_translations',
        'city', 'phone', 'logo', 'description', 'description_translations',
        'cover_image_url', 'supports_dine_in', 'latitude', 'longitude',
    )


@admin.register(OperatorProfile)
class OperatorProfileAdmin(ModelAdmin):
    list_display = ('employee_id', 'user', 'assigned_city')
    search_fields = ('employee_id', 'user__full_name')


@admin.register(PhoneOtp)
class PhoneOtpAdmin(ModelAdmin):
    list_display = ('phone', 'code', 'is_used', 'created_at', 'expires_at')
    list_filter = ('is_used',)
    search_fields = ('phone', 'code')
    readonly_fields = ('id', 'phone', 'code', 'created_at', 'expires_at', 'is_used')
    ordering = ('-created_at',)
