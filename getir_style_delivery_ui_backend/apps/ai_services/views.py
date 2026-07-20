from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.catalog.serializers import ItemSerializer

from .services import get_discount_suggestions, get_recommendations


class RecommendationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        city = request.query_params.get('city') or request.user.city
        try:
            limit = int(request.query_params.get('limit', 20))
        except ValueError:
            limit = 20
        limit = max(1, min(limit, 100))
        items = get_recommendations(request.user, city=city or '', limit=limit)
        return Response(ItemSerializer(items, many=True).data)


class DiscountSuggestionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(get_discount_suggestions(request.user))
