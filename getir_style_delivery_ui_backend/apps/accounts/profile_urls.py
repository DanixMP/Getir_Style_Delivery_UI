"""Account/profile endpoints — mounted at /api/v1/accounts/."""
from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AdminUserViewSet,
    MeView,
    PeykSelfAvailabilityView,
    PublicPeykView,
)

router = DefaultRouter()
router.register('users', AdminUserViewSet, basename='users')

urlpatterns = [
    path('me/', MeView.as_view(), name='accounts-me'),
    path('peyk/availability/', PeykSelfAvailabilityView.as_view(), name='peyk-self-availability'),
    path('peyks/<uuid:id>/', PublicPeykView.as_view(), name='accounts-peyk-detail'),
]

urlpatterns += router.urls
