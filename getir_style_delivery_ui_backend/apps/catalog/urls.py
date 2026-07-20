from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    CategoryViewSet,
    HomePromoView,
    ItemViewSet,
    TableHoldView,
    VendorDineInView,
    VendorViewSet,
)

router = DefaultRouter()
router.register('categories', CategoryViewSet, basename='category')
router.register('items', ItemViewSet, basename='item')
router.register('vendors', VendorViewSet, basename='vendor')

urlpatterns = [
    path('home-promo/', HomePromoView.as_view(), name='catalog-home-promo'),
    path(
        'vendors/<uuid:vendor_id>/dine-in/',
        VendorDineInView.as_view(),
        name='catalog-vendor-dine-in',
    ),
    path(
        'vendors/<uuid:vendor_id>/tables/<uuid:table_id>/hold/',
        TableHoldView.as_view(),
        name='catalog-table-hold',
    ),
] + router.urls
