"""Root URL configuration for GetirStyleDeliveryUi. API prefix: /api/v1/"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/accounts/', include('apps.accounts.profile_urls')),
    path('api/v1/catalog/', include('apps.catalog.urls')),
    path('api/v1/orders/', include('apps.orders.urls')),
    path('api/v1/delivery/', include('apps.delivery.urls')),
    path('api/v1/tracking/', include('apps.tracking.urls')),
    path('api/v1/payments/', include('apps.payments.urls')),
    path('api/v1/communications/', include('apps.communications.urls')),
    path('api/v1/reports/', include('apps.reports.urls')),
    path('api/v1/ai/', include('apps.ai_services.urls')),
    path('api/v1/operator/', include('apps.operators.urls')),
    path('api/v1/developer/', include('apps.developer.urls')),
    path('api/v1/wallet/', include('apps.wallet.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
