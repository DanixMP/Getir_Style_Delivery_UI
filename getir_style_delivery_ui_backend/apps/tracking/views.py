from django.http import HttpResponse
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsOperator, IsPeyk

from .models import GPSSnapshot
from .neshan import (
    get_distance_matrix,
    get_map_tile,
    get_route,
    reverse_geocode,
    search_places,
)
from .serializers import GPSSnapshotSerializer, LocationPostSerializer
from .services import broadcast_location


class LocationPostView(APIView):
    """Peyk posts a GPS update; broadcasts to the order's tracking group."""
    permission_classes = [IsPeyk]

    def post(self, request):
        serializer = LocationPostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        snapshot = GPSSnapshot.objects.create(
            peyk=request.user,
            order_id=data.get('order_id'),
            latitude=data['latitude'],
            longitude=data['longitude'],
        )
        broadcast_location(snapshot)
        return Response(GPSSnapshotSerializer(snapshot).data, status=status.HTTP_201_CREATED)


class PeykLatestLocationView(APIView):
    """Operator reads a peyk's last known position."""
    permission_classes = [IsOperator]

    def get(self, request, peyk_id):
        snapshot = GPSSnapshot.objects.filter(peyk_id=peyk_id).order_by('-timestamp').first()
        if snapshot is None:
            return Response({'detail': 'No location data for this peyk.'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response(GPSSnapshotSerializer(snapshot).data)


def _parse_route_coords(request):
    try:
        return (
            float(request.query_params['olat']),
            float(request.query_params['olng']),
            float(request.query_params['dlat']),
            float(request.query_params['dlng']),
        )
    except (KeyError, ValueError, TypeError):
        return None


def _parse_point_coords(request):
    try:
        return (
            float(request.query_params['lat']),
            float(request.query_params['lng']),
        )
    except (KeyError, ValueError, TypeError):
        return None


class RouteView(APIView):
    """
    Proxy to Neshan Direction (routing with live traffic).
    GET /api/v1/tracking/route/?olat=&olng=&dlat=&dlng=&type=motorcycle
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        coords = _parse_route_coords(request)
        if coords is None:
            return Response(
                {'detail': 'olat, olng, dlat, dlng are required numbers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        olat, olng, dlat, dlng = coords
        vehicle = request.query_params.get('type', 'motorcycle')
        result = get_route(olat, olng, dlat, dlng, vehicle=vehicle)
        if result is None:
            return Response({'detail': 'Routing unavailable.'},
                            status=status.HTTP_502_BAD_GATEWAY)
        return Response(result)


class DistanceMatrixView(APIView):
    """
    Proxy to Neshan Distance Matrix (live traffic ETA).
    GET /api/v1/tracking/distance/?olat=&olng=&dlat=&dlng=&type=motorcycle
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        coords = _parse_route_coords(request)
        if coords is None:
            return Response(
                {'detail': 'olat, olng, dlat, dlng are required numbers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        olat, olng, dlat, dlng = coords
        vehicle = request.query_params.get('type', 'motorcycle')
        result = get_distance_matrix(olat, olng, dlat, dlng, vehicle=vehicle)
        if result is None:
            return Response({'detail': 'Distance matrix unavailable.'},
                            status=status.HTTP_502_BAD_GATEWAY)
        return Response(result)


class SearchView(APIView):
    """
    Proxy to Neshan location-based search.
    GET /api/v1/tracking/search/?term=&lat=&lng=
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        term = request.query_params.get('term', '').strip()
        coords = _parse_point_coords(request)
        if not term:
            return Response({'detail': 'term is required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        if coords is None:
            return Response(
                {'detail': 'lat and lng are required numbers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        lat, lng = coords
        return Response({'results': search_places(term, lat, lng)})


class ReverseGeocodeView(APIView):
    """
    Proxy to Neshan Reverse Geocoding (coordinates → address).
    GET /api/v1/tracking/reverse/?lat=&lng=
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        coords = _parse_point_coords(request)
        if coords is None:
            return Response(
                {'detail': 'lat and lng are required numbers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        lat, lng = coords
        result = reverse_geocode(lat, lng)
        if result is None:
            return Response({'detail': 'Reverse geocoding unavailable.'},
                            status=status.HTTP_502_BAD_GATEWAY)
        return Response(result)


class MapTileView(APIView):
    """
    Proxy Neshan map tiles for native clients.
    GET /api/v1/tracking/tiles/{z}/{x}/{y}.png
    """
    permission_classes = [AllowAny]

    def get(self, request, z, x, y):
        try:
            z_i, x_i, y_i = int(z), int(x), int(y)
        except (TypeError, ValueError):
            return Response(
                {'detail': 'z, x, y must be integers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not (0 <= z_i <= 19):
            return Response(
                {'detail': 'zoom must be between 0 and 19.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        data = get_map_tile(z_i, x_i, y_i)
        if data is None:
            return HttpResponse(status=502)
        return HttpResponse(data, content_type='image/png')
