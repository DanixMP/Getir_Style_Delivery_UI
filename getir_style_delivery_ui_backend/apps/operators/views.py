from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import PeykProfile, VendorProfile
from apps.accounts.permissions import IsOperator
from apps.catalog.models import Item
from apps.communications.call_service import operator_initiate_call
from apps.delivery.views import TipaxCodeEntryView
from apps.localization import localized_attr


def _operator_city(user):
    profile = getattr(user, 'operator_profile', None)
    return getattr(profile, 'assigned_city', None) or user.city


class VendorChecklistView(APIView):
    """All vendors in the operator's city with their items."""
    permission_classes = [IsOperator]

    def get(self, request):
        city = _operator_city(request.user)
        vendors = (
            VendorProfile.objects.filter(city=city, is_active=True)
            .prefetch_related('items')
        )
        data = []
        for vendor in vendors:
            data.append({
                'vendor_id': str(vendor.id),
                'business_name': localized_attr(vendor, 'business_name', request=request),
                'items': [
                    {
                        'id': str(i.id),
                        'name': localized_attr(i, 'name', request=request),
                        'price': i.price,
                        'is_available': i.is_available,
                    }
                    for i in vendor.items.all()
                ],
            })
        return Response(data)


class ItemAvailabilityView(APIView):
    permission_classes = [IsOperator]

    def patch(self, request, item_id):
        is_available = request.data.get('is_available')
        if is_available is None:
            return Response({'detail': 'is_available is required.'}, status=status.HTTP_400_BAD_REQUEST)
        updated = Item.objects.filter(id=item_id).update(is_available=bool(is_available))
        if not updated:
            return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response({'id': str(item_id), 'is_available': bool(is_available)})


class ItemPriceView(APIView):
    permission_classes = [IsOperator]

    def patch(self, request, item_id):
        price = request.data.get('price')
        if price is None:
            return Response({'detail': 'price is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            price = int(price)
            if price < 0:
                raise ValueError
        except (TypeError, ValueError):
            return Response({'detail': 'price must be a non-negative integer.'},
                            status=status.HTTP_400_BAD_REQUEST)
        updated = Item.objects.filter(id=item_id).update(price=price)
        if not updated:
            return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response({'id': str(item_id), 'price': price})


class PeykBoardView(APIView):
    """All peyks in the operator's city."""
    permission_classes = [IsOperator]

    def get(self, request):
        city = _operator_city(request.user)
        peyks = PeykProfile.objects.select_related('user').all()
        # Admins/developers oversee everything; operators are scoped to their
        # city (but if no city is set, don't hide every peyk).
        if request.user.role not in ('admin', 'developer') and city:
            peyks = peyks.filter(user__city=city)
        data = [{
            'id': str(p.id),
            'user_id': str(p.user_id),  # needed to create a PeykAssignment
            'peyk_code': p.peyk_code,
            'full_name': p.user.full_name,
            'is_available': p.is_available,
            'vehicle_type': p.vehicle_type,
            'rating': str(p.rating),
        } for p in peyks]
        return Response(data)


class PeykAvailabilityView(APIView):
    permission_classes = [IsOperator]

    def patch(self, request, id):
        is_available = request.data.get('is_available')
        if is_available is None:
            return Response({'detail': 'is_available is required.'}, status=status.HTTP_400_BAD_REQUEST)
        updated = PeykProfile.objects.filter(id=id).update(is_available=bool(is_available))
        if not updated:
            return Response({'detail': 'Peyk not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response({'id': str(id), 'is_available': bool(is_available)})


class PeykCallView(APIView):
    """Operator-initiated call to a Peyk — delegates to communications."""
    permission_classes = [IsOperator]

    def post(self, request, id):
        consent = bool(request.data.get('consent_acknowledged', False))
        payload, code = operator_initiate_call(request.user, str(id), consent)
        return Response(payload, status=code)


class VendorCallView(APIView):
    """Operator -> vendor call (ask about availability / readiness)."""
    permission_classes = [IsOperator]

    def post(self, request, id):
        vendor = VendorProfile.objects.select_related('user').filter(id=id).first()
        if vendor is None:
            return Response({'detail': 'Vendor not found.'},
                            status=status.HTTP_404_NOT_FOUND)
        consent = bool(request.data.get('consent_acknowledged', False))
        payload, code = operator_initiate_call(
            request.user, str(vendor.user_id), consent)
        return Response(payload, status=code)


class OperatorTipaxCodeView(TipaxCodeEntryView):
    """Operator enters the Tipax tracking code (same contract as delivery)."""
    pass
