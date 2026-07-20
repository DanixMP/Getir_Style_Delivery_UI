from django.urls import path
from rest_framework.routers import DefaultRouter

from apps.orders.views import OfflineOrderViewSet

from .views import (
    ItemAvailabilityView,
    ItemPriceView,
    OperatorTipaxCodeView,
    PeykAvailabilityView,
    PeykBoardView,
    PeykCallView,
    VendorCallView,
    VendorChecklistView,
)

router = DefaultRouter()
router.register('offline-orders', OfflineOrderViewSet, basename='operator-offline-order')

urlpatterns = [
    path('vendors/checklist/', VendorChecklistView.as_view(), name='operator-vendor-checklist'),
    path('vendors/<uuid:id>/call/', VendorCallView.as_view(), name='operator-vendor-call'),
    path('items/<uuid:item_id>/availability/', ItemAvailabilityView.as_view(), name='operator-item-availability'),
    path('items/<uuid:item_id>/price/', ItemPriceView.as_view(), name='operator-item-price'),
    path('peyks/', PeykBoardView.as_view(), name='operator-peyk-board'),
    path('peyks/<uuid:id>/availability/', PeykAvailabilityView.as_view(), name='operator-peyk-availability'),
    path('peyks/<uuid:id>/call/', PeykCallView.as_view(), name='operator-peyk-call'),
    path('orders/<uuid:order_id>/tipax-code/', OperatorTipaxCodeView.as_view(), name='operator-tipax-code'),
]

urlpatterns += router.urls
