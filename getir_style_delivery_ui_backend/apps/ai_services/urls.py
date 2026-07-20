from django.urls import path

from .views import DiscountSuggestionsView, RecommendationsView

urlpatterns = [
    path('recommendations/', RecommendationsView.as_view(), name='ai-recommendations'),
    path('discounts/', DiscountSuggestionsView.as_view(), name='ai-discounts'),
]
