from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import PeykAssignmentViewSet, TipaxCodeEntryView, TipaxConfirmDropView

router = DefaultRouter()
router.register('assignments', PeykAssignmentViewSet, basename='assignment')

urlpatterns = [
    path('tipax/<uuid:order_id>/confirm-drop/', TipaxConfirmDropView.as_view(), name='tipax-confirm-drop'),
    path('tipax/<uuid:order_id>/', TipaxCodeEntryView.as_view(), name='tipax-code-entry'),
]

urlpatterns += router.urls
