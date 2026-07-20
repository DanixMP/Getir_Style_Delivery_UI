from rest_framework.routers import DefaultRouter

from .views import OfflineOrderViewSet, OrderViewSet

router = DefaultRouter()
# Register 'offline' first so /orders/offline/ resolves before the order
# detail route (which would otherwise capture "offline" as a pk).
router.register('offline', OfflineOrderViewSet, basename='offline-order')
router.register('', OrderViewSet, basename='order')

urlpatterns = router.urls
