from django.urls import path

from .views import (
    DistanceMatrixView,
    LocationPostView,
    MapTileView,
    PeykLatestLocationView,
    ReverseGeocodeView,
    RouteView,
    SearchView,
)

urlpatterns = [
    path('location/', LocationPostView.as_view(), name='tracking-location-post'),
    path('location/<uuid:peyk_id>/latest/', PeykLatestLocationView.as_view(), name='tracking-location-latest'),
    path('route/', RouteView.as_view(), name='tracking-route'),
    path('distance/', DistanceMatrixView.as_view(), name='tracking-distance'),
    path('search/', SearchView.as_view(), name='tracking-search'),
    path('reverse/', ReverseGeocodeView.as_view(), name='tracking-reverse'),
    path('tiles/<int:z>/<int:x>/<int:y>.png', MapTileView.as_view(), name='tracking-map-tile'),
]
