import django_filters

from .models import Item


class ItemFilter(django_filters.FilterSet):
    city = django_filters.CharFilter(field_name='city', lookup_expr='exact')
    category = django_filters.CharFilter(field_name='category__slug', lookup_expr='exact')
    vendor = django_filters.UUIDFilter(field_name='vendor__id')
    available = django_filters.BooleanFilter(field_name='is_available')

    class Meta:
        model = Item
        fields = ['city', 'category', 'vendor', 'available']
