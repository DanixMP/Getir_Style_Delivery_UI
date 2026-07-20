"""
Recommendation engine. Release 1 is pure ORM. The function signatures are
stable so Release 2 can swap in an LLM call without touching the views.
"""
from datetime import timedelta

from django.db.models import Count
from django.utils import timezone

from apps.catalog.models import Item


def get_recommendations(user, city: str, limit: int = 20):
    """
    Release 1: available items in the given city, best rated then cheapest.
    Release 2: replace body with an LLM call using the user's recent orders.
    Signature stays identical.
    """
    return (
        Item.objects.filter(city=city, is_available=True, vendor__is_active=True)
        .select_related('vendor', 'category')
        .order_by('-rating', 'price')[:limit]
    )


def get_discount_suggestions(user) -> list[dict]:
    """
    Release 1: rule-based.
      Rule A: no order in > 7 days -> 10% off most-ordered category.
      Rule B: new user (0 orders) -> welcome discount.
    Release 2: LLM-based. Signature stays identical.
    """
    from apps.orders.models import Order

    orders = Order.objects.filter(customer=user)
    if not orders.exists():
        return [{
            'type': 'welcome',
            'discount_percent': 15,
            'message': 'به GETIR_STYLE_DELIVERY_UI خوش آمدید! ۱۵٪ تخفیف برای اولین سفارش.',
            'target_category': None,
        }]

    last = orders.order_by('-created_at').first()
    suggestions: list[dict] = []
    if last and last.created_at < timezone.now() - timedelta(days=7):
        top_category = (
            Order.objects.filter(customer=user)
            .values('items__item__category__slug')
            .annotate(c=Count('id'))
            .order_by('-c')
            .first()
        )
        slug = top_category['items__item__category__slug'] if top_category else None
        suggestions.append({
            'type': 'win_back',
            'discount_percent': 10,
            'message': 'دلمان برایتان تنگ شده! ۱۰٪ تخفیف روی دسته محبوب شما.',
            'target_category': slug,
        })
    return suggestions
