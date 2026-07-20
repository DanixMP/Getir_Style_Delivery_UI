"""
Celery Beat report generation. Models are imported at execution time (not at
module import) to avoid circular imports.
"""
from datetime import date, timedelta

from celery import shared_task


def _aggregate(vendor, period, period_start, period_end):
    """Build/refresh one VendorReport from delivered orders in the window."""
    from django.db.models import Sum

    from apps.orders.models import Order
    from apps.reports.models import VendorReport

    qs = Order.objects.filter(
        vendor=vendor,
        status='delivered',
        updated_at__date__gte=period_start,
        updated_at__date__lte=period_end,
    )
    total_orders = qs.count()
    total_revenue = qs.aggregate(s=Sum('total_amount'))['s'] or 0
    avg = total_revenue // total_orders if total_orders else 0
    VendorReport.objects.update_or_create(
        vendor=vendor, period=period, period_start=period_start,
        defaults=dict(
            period_end=period_end,
            total_orders=total_orders,
            total_revenue=total_revenue,
            avg_order_value=avg,
        ),
    )


def _active_vendors():
    from apps.accounts.models import VendorProfile
    return VendorProfile.objects.filter(is_active=True)


@shared_task
def generate_daily_reports():
    """Runs at 00:05 every day. Aggregates yesterday's delivered orders."""
    yesterday = date.today() - timedelta(days=1)
    for vendor in _active_vendors():
        _aggregate(vendor, 'daily', yesterday, yesterday)


@shared_task
def generate_weekly_reports():
    """Runs every Monday at 00:10. Covers Mon-Sun of the previous week."""
    today = date.today()
    last_monday = today - timedelta(days=today.weekday() + 7)
    last_sunday = last_monday + timedelta(days=6)
    for vendor in _active_vendors():
        _aggregate(vendor, 'weekly', last_monday, last_sunday)


@shared_task
def generate_monthly_reports():
    """Runs on the 1st of each month at 00:15. Covers the previous month."""
    first_this_month = date.today().replace(day=1)
    last_month_end = first_this_month - timedelta(days=1)
    last_month_start = last_month_end.replace(day=1)
    for vendor in _active_vendors():
        _aggregate(vendor, 'monthly', last_month_start, last_month_end)


@shared_task
def generate_yearly_reports():
    """Runs on Jan 1 at 00:20. Covers the previous calendar year."""
    year = date.today().year - 1
    start = date(year, 1, 1)
    end = date(year, 12, 31)
    for vendor in _active_vendors():
        _aggregate(vendor, 'yearly', start, end)
