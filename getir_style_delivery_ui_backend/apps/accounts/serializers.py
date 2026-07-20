from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from apps.localization import LocalizedFieldsMixin, TranslationMapField

from .models import OperatorProfile, PeykProfile, VendorProfile

User = get_user_model()


class PeykProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = PeykProfile
        fields = [
            'id', 'peyk_code', 'vehicle_type', 'is_verified', 'is_available',
            'rating', 'rating_count', 'complaint_count', 'photo',
            'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'peyk_code', 'is_verified', 'rating', 'rating_count',
            'complaint_count', 'created_at', 'updated_at',
        ]


class VendorProfileSerializer(LocalizedFieldsMixin, serializers.ModelSerializer):
    localized_fields = ('business_name', 'address', 'description')
    business_name_translations = TranslationMapField(required=False)
    address_translations = TranslationMapField(required=False)
    description_translations = TranslationMapField(required=False)

    class Meta:
        model = VendorProfile
        fields = [
            'id', 'business_name', 'business_name_translations',
            'category', 'is_active', 'rating', 'rating_count',
            'address', 'address_translations', 'city', 'phone', 'logo',
            'description', 'description_translations',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'rating', 'rating_count', 'created_at', 'updated_at']


class OperatorProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = OperatorProfile
        fields = ['id', 'assigned_city', 'employee_id', 'created_at']
        read_only_fields = ['id', 'created_at']


class PublicPeykSerializer(serializers.ModelSerializer):
    """Customer-facing Peyk profile (no sensitive fields)."""
    full_name = serializers.CharField(source='user.full_name', read_only=True)

    class Meta:
        model = PeykProfile
        fields = [
            'id', 'peyk_code', 'full_name', 'vehicle_type',
            'is_available', 'rating', 'rating_count', 'photo',
        ]


class UserSerializer(serializers.ModelSerializer):
    """Role-aware representation used by /accounts/me/."""
    profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'phone', 'email', 'full_name', 'role', 'city',
            'is_active', 'date_joined', 'updated_at', 'profile',
        ]
        read_only_fields = ['id', 'phone', 'role', 'is_active', 'date_joined', 'updated_at']

    def get_profile(self, obj):
        if obj.role == 'peyk' and hasattr(obj, 'peyk_profile'):
            return PeykProfileSerializer(obj.peyk_profile).data
        if obj.role == 'vendor' and hasattr(obj, 'vendor_profile'):
            return VendorProfileSerializer(obj.vendor_profile, context=self.context).data
        if obj.role in ('operator', 'admin', 'developer') and hasattr(obj, 'operator_profile'):
            return OperatorProfileSerializer(obj.operator_profile).data
        return None


class RegisterSerializer(serializers.Serializer):
    """Self-registration for customers and peyks only."""
    phone = serializers.CharField(max_length=15)
    password = serializers.CharField(write_only=True, min_length=6)
    full_name = serializers.CharField(max_length=100)
    role = serializers.ChoiceField(choices=[('customer', 'Customer'), ('peyk', 'Peyk')])
    city = serializers.CharField(max_length=100, required=False, allow_blank=True)
    # Peyk-only
    vehicle_type = serializers.ChoiceField(
        choices=[('car', 'Car'), ('motor', 'Motor')], required=False
    )

    def validate_phone(self, value):
        value = value.strip()
        if not value.isdigit():
            raise serializers.ValidationError('Phone must contain digits only.')
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError('A user with this phone already exists.')
        return value

    def validate(self, attrs):
        if attrs['role'] == 'peyk' and not attrs.get('vehicle_type'):
            raise serializers.ValidationError(
                {'vehicle_type': 'vehicle_type is required for peyk registration.'}
            )
        return attrs

    def create(self, validated_data):
        vehicle_type = validated_data.pop('vehicle_type', None)
        password = validated_data.pop('password')
        user = User.objects.create_user(password=password, **validated_data)
        if user.role == 'peyk':
            PeykProfile.objects.create(user=user, vehicle_type=vehicle_type)
        return user


class PhoneTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Login with phone + password (USERNAME_FIELD is already 'phone')."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['role'] = user.role
        token['full_name'] = user.full_name
        return token


class AdminUserSerializer(serializers.ModelSerializer):
    """Used by operators/admins to create vendor/operator users."""
    password = serializers.CharField(write_only=True, min_length=6, required=False)

    class Meta:
        model = User
        fields = [
            'id', 'phone', 'email', 'full_name', 'role', 'city',
            'is_active', 'is_staff', 'password', 'date_joined',
        ]
        read_only_fields = ['id', 'date_joined']

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = User.objects.create_user(password=password, **validated_data)
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        for field, value in validated_data.items():
            setattr(instance, field, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance
