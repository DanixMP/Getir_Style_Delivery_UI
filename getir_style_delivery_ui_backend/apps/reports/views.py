from datetime import date

from django.db.models import Sum
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.permissions import IsOperator
from apps.orders.models import Order

from .models import VendorReport
from .serializers import VendorReportSerializer

_OPERATOR_ROLES = {'operator', 'admin', 'developer'}


class VendorReportView(APIView):
    """Vendor sees own reports; operator can query any via ?vendor_id=."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        qs = VendorReport.objects.select_related('vendor').all()

        if user.role == 'vendor':
            qs = qs.filter(vendor__user=user)
        elif user.role in _OPERATOR_ROLES:
            vendor_id = request.query_params.get('vendor_id')
            if vendor_id:
                qs = qs.filter(vendor_id=vendor_id)
        else:
            return Response([], status=200)

        period = request.query_params.get('period')
        if period:
            qs = qs.filter(period=period)
        year = request.query_params.get('year')
        if year:
            qs = qs.filter(period_start__year=year)
        month = request.query_params.get('month')
        if month:
            qs = qs.filter(period_start__month=month)

        return Response(VendorReportSerializer(qs, many=True).data)


class OperatorSummaryView(APIView):
    """City-wide aggregated totals for the current day."""
    permission_classes = [IsOperator]

    def get(self, request):
        today = date.today()
        qs = Order.objects.filter(status='delivered', updated_at__date=today)
        city = request.query_params.get('city')
        if city:
            qs = qs.filter(delivery_city=city)
        total_orders = qs.count()
        total_revenue = qs.aggregate(s=Sum('total_amount'))['s'] or 0
        return Response({
            'date': today.isoformat(),
            'city': city,
            'total_orders': total_orders,
            'total_revenue': total_revenue,
        })
