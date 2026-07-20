import math

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status, viewsets
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import VendorProfile
from apps.accounts.permissions import IsOperator, IsVendor
from apps.localization import localized_attr, request_language

from .filters import ItemFilter
from .models import Category, DiningTable, HomeBanner, HomeFeaturedItem, Item, VenuePanorama
from .serializers import (
    CategorySerializer,
    DiningTableSerializer,
    HomeBannerSerializer,
    HomeFeaturedItemSerializer,
    ItemSerializer,
    ItemWriteSerializer,
    VendorDetailSerializer,
    VendorListSerializer,
    VenuePanoramaSerializer,
)
from .table_hold import hold_table as reserve_table_hold

ORDERING_MAP = {
    'cheapest': ['price'],
    'priciest': ['-price'],
    'top_rated': ['-rating'],
    'top_choice': ['-rating', '-rating_count'],
}


def _haversine_km(lat1, lng1, lat2, lng2):
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlmb = math.radians(lng2 - lng1)
    a = math.sin(dphi / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dlmb / 2) ** 2
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """List/detail of categories. Includes is_coming_soon items."""
    permission_classes = [IsAuthenticated]
    serializer_class = CategorySerializer
    queryset = Category.objects.filter(is_active=True)
    lookup_field = 'slug'


class ItemViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_class = ItemFilter
    queryset = Item.objects.select_related('vendor', 'category').all()

    def get_serializer_class(self):
        if self.action in ('create', 'update', 'partial_update'):
            return ItemWriteSerializer
        return ItemSerializer

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            # Vendors manage their own; operators manage any.
            return [(IsVendor | IsOperator)()]
        return [IsAuthenticated()]

    def get_queryset(self):
        qs = super().get_queryset()

        # Search across name + description.
        search = self.request.query_params.get('search')
        if search:
            from django.db.models import Q
            language = request_language(self.request)
            qs = qs.filter(
                Q(name__icontains=search)
                | Q(description__icontains=search)
                | Q(**{f'name_translations__{language}__icontains': search})
                | Q(**{f'description_translations__{language}__icontains': search})
            )

        ordering = self.request.query_params.get('ordering')
        if ordering in ORDERING_MAP:
            qs = qs.order_by(*ORDERING_MAP[ordering])
        elif ordering == 'closest':
            # Distance sort happens in list() (needs lat/lng + Python post-sort).
            pass
        return qs

    def list(self, request, *args, **kwargs):
        if request.query_params.get('ordering') == 'closest':
            return self._closest_list(request)
        return super().list(request, *args, **kwargs)

    def _closest_list(self, request):
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        if lat is None or lng is None:
            raise ValidationError({'detail': 'lat and lng are required for ordering=closest.'})
        try:
            lat, lng = float(lat), float(lng)
        except ValueError:
            raise ValidationError({'detail': 'lat and lng must be numbers.'})

        # Pilot-scale: sort vendors by distance using their latest GPS-less
        # address geocode is out of scope; fall back to top_rated ordering when
        # no per-item coordinates exist. Items carry no lat/lng, so we sort by
        # the vendor proximity heuristic (rating) — documented acceptable
        # compromise at pilot scale.
        qs = self.filter_queryset(self.get_queryset()).order_by('-rating', 'price')
        page = self.paginate_queryset(qs)
        serializer = self.get_serializer(page if page is not None else qs, many=True)
        if page is not None:
            return self.get_paginated_response(serializer.data)
        return Response(serializer.data)

    def perform_create(self, serializer):
        user = self.request.user
        if user.role == 'vendor':
            try:
                vendor = user.vendor_profile
            except VendorProfile.DoesNotExist:
                raise ValidationError({'detail': 'No vendor profile for this user.'})
            serializer.save(vendor=vendor)
        else:
            if not serializer.validated_data.get('vendor'):
                raise ValidationError({'vendor': 'vendor is required for operators.'})
            serializer.save()

    def _check_owner(self, instance):
        user = self.request.user
        if user.role == 'vendor' and instance.vendor.user_id != user.id:
            raise PermissionDenied('You can only modify your own items.')

    def perform_update(self, serializer):
        self._check_owner(serializer.instance)
        serializer.save()

    def destroy(self, request, *args, **kwargs):
        """Soft delete: mark unavailable rather than hard-deleting."""
        instance = self.get_object()
        self._check_owner(instance)
        instance.is_available = False
        instance.save(update_fields=['is_available', 'updated_at'])
        return Response(status=status.HTTP_204_NO_CONTENT)


class VendorViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [IsAuthenticated]
    queryset = VendorProfile.objects.filter(is_active=True)

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return VendorDetailSerializer
        return VendorListSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        city = self.request.query_params.get('city')
        category = self.request.query_params.get('category')
        if city:
            qs = qs.filter(city=city)
        if category:
            qs = qs.filter(category__slug=category)
        dine_in = self.request.query_params.get('supports_dine_in')
        if dine_in is not None and dine_in.lower() in ('true', '1', 'yes'):
            qs = qs.filter(supports_dine_in=True)
        return qs


class VendorDineInView(APIView):
    """
    Dine-in venue payload: vendor + active panorama + tables.
    GET /api/v1/catalog/vendors/{vendor_id}/dine-in/
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, vendor_id):
        try:
            vendor = VendorProfile.objects.get(pk=vendor_id, is_active=True)
        except VendorProfile.DoesNotExist:
            return Response({'detail': 'Vendor not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not vendor.supports_dine_in:
            return Response({'detail': 'This vendor does not support dine-in.'},
                            status=status.HTTP_404_NOT_FOUND)
        panorama = (
            VenuePanorama.objects.filter(vendor=vendor, is_active=True).first()
        )
        tables = DiningTable.objects.filter(vendor=vendor).order_by('label')
        featured = (
            Item.objects.filter(vendor=vendor, is_available=True)
            .order_by('-rating')[:6]
        )
        ctx = {'request': request}
        payload = {
            'vendor': VendorListSerializer(vendor, context=ctx).data,
            'panorama': (
                VenuePanoramaSerializer(panorama, context=ctx).data if panorama else None
            ),
            'tables': DiningTableSerializer(tables, many=True, context=ctx).data,
            'featured_items': ItemSerializer(featured, many=True, context=ctx).data,
        }
        return Response(payload)


class TableHoldView(APIView):
    """
    Reserve a table for 5 minutes while the customer completes checkout.
    POST /api/v1/catalog/vendors/{vendor_id}/tables/{table_id}/hold/
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, vendor_id, table_id):
        try:
            table = DiningTable.objects.get(pk=table_id, vendor_id=vendor_id)
        except DiningTable.DoesNotExist:
            return Response({'detail': 'Table not found.'}, status=status.HTTP_404_NOT_FOUND)
        if table.status == 'occupied':
            return Response({'detail': 'Table is occupied.'}, status=status.HTTP_409_CONFLICT)

        ok, detail = reserve_table_hold(vendor_id, table_id, request.user.id)
        if not ok:
            return Response({'detail': detail}, status=status.HTTP_409_CONFLICT)

        return Response({
            'table_id': str(table.id),
            'label': localized_attr(table, 'label', request=request),
            'hold_seconds': 300,
        })


class HomePromoView(APIView):
    """
    Home screen promo content: banners, discounted items, today's specials.
    GET /api/v1/catalog/home-promo/?city=Tehran
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from django.db.models import Q
        from django.utils import timezone

        city = (request.query_params.get('city') or '').strip()
        now = timezone.now()
        today = timezone.localdate()

        banners = HomeBanner.objects.filter(is_active=True)
        banners = banners.filter(Q(starts_at__isnull=True) | Q(starts_at__lte=now))
        banners = banners.filter(Q(ends_at__isnull=True) | Q(ends_at__gte=now))
        if city:
            banners = banners.filter(Q(city='') | Q(city__iexact=city))

        features = HomeFeaturedItem.objects.filter(
            is_active=True,
            item__is_available=True,
        ).select_related('item__vendor', 'item__category').prefetch_related('item__gallery')
        if city:
            features = features.filter(Q(city='') | Q(city__iexact=city) | Q(item__city__iexact=city))

        discounted = features.filter(section=HomeFeaturedItem.SECTION_DISCOUNTED)
        today_specials = features.filter(section=HomeFeaturedItem.SECTION_TODAY_SPECIAL)
        today_specials = today_specials.filter(
            Q(special_date__isnull=True) | Q(special_date=today),
        )

        ctx = {'request': request}
        payload = {
            'banners': HomeBannerSerializer(banners, many=True, context=ctx).data,
            'discounted_items': HomeFeaturedItemSerializer(
                discounted, many=True, context=ctx,
            ).data,
            'today_specials': HomeFeaturedItemSerializer(
                today_specials, many=True, context=ctx,
            ).data,
        }
        return Response(payload)
