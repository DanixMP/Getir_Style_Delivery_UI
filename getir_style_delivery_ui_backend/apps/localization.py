from django.conf import settings
from django.utils.translation import get_language_from_request
from rest_framework import serializers


def _supported_language_codes():
    languages = getattr(settings, 'LANGUAGES', ())
    return {code.split('-')[0].lower() for code, _ in languages}


def normalize_language_code(value):
    default = getattr(settings, 'CONTENT_DEFAULT_LANGUAGE', settings.LANGUAGE_CODE)
    default = default.split('-')[0].lower()
    if not value:
        return default

    code = str(value).replace('_', '-').split('-')[0].lower()
    return code if code in _supported_language_codes() else default


def request_language(request):
    if request is None:
        return normalize_language_code(None)

    requested = getattr(request, 'query_params', {}).get('lang')
    if requested:
        return normalize_language_code(requested)

    return normalize_language_code(get_language_from_request(request, check_path=False))


def clean_translation_map(value):
    if value in (None, ''):
        return {}
    if not isinstance(value, dict):
        raise ValueError('Expected an object keyed by language code.')

    cleaned = {}
    for raw_code, raw_text in value.items():
        code = normalize_language_code(raw_code)
        if code != str(raw_code).replace('_', '-').split('-')[0].lower():
            raise ValueError(f'Unsupported language code: {raw_code}.')
        if not isinstance(raw_text, str):
            raise ValueError(f'Translation for {raw_code} must be a string.')
        text = raw_text.strip()
        if text:
            cleaned[code] = text
    return cleaned


def localized_attr(instance, field_name, request=None, language=None):
    base_value = getattr(instance, field_name, '') or ''
    translations = getattr(instance, f'{field_name}_translations', None) or {}
    code = normalize_language_code(language or request_language(request))
    default = normalize_language_code(None)

    for candidate in (code, default):
        value = translations.get(candidate)
        if isinstance(value, str) and value.strip():
            return value
    return base_value


class TranslationMapField(serializers.JSONField):
    def to_internal_value(self, data):
        value = super().to_internal_value(data)
        try:
            return clean_translation_map(value)
        except ValueError as exc:
            raise serializers.ValidationError(str(exc))


class LocalizedFieldsMixin:
    localized_fields = ()

    def to_representation(self, instance):
        data = super().to_representation(instance)
        request = self.context.get('request')
        for field_name in self.localized_fields:
            if field_name in data:
                data[field_name] = localized_attr(instance, field_name, request=request)
        return data
