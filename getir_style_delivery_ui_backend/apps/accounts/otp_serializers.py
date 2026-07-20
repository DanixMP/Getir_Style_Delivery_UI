from rest_framework import serializers

from .otp_service import normalize_phone


class OtpRequestSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)

    def validate_phone(self, value):
        phone = normalize_phone(value)
        if len(phone) < 10:
            raise serializers.ValidationError('Enter a valid phone number.')
        return phone


class OtpVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    code = serializers.CharField(min_length=6, max_length=6)

    def validate_phone(self, value):
        return normalize_phone(value)

    def validate_code(self, value):
        code = value.strip()
        if not code.isdigit():
            raise serializers.ValidationError('OTP must be 6 digits.')
        return code
