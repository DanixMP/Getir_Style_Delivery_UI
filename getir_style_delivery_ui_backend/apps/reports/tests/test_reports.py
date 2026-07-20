from datetime import date, timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.orders.models import Order
from apps.reports.models import VendorReport
from apps.reports.tasks import generate_daily_reports

User = get_user_model()


class ReportTaskTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000130', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000130')
        self.customer = User.objects.create_user(phone='09120000131', password='x',
                                                  full_name='C', role='customer', city='Tehran')

    def _delivered_order_yesterday(self, amount):
        order = Order.objects.create(customer=self.customer, vendor=self.vendor,
                                     delivery_type='in_city', payment_method='cash',
                                     delivery_address='a', delivery_city='Tehran',
                                     status='delivered', total_amount=amount)
        yesterday = timezone.now() - timedelta(days=1)
        Order.objects.filter(pk=order.pk).update(updated_at=yesterday)
        return order

    def test_daily_report_aggregates(self):
        self._delivered_order_yesterday(100000)
        self._delivered_order_yesterday(200000)
        generate_daily_reports()
        report = VendorReport.objects.get(vendor=self.vendor, period='daily')
        self.assertEqual(report.total_orders, 2)
        self.assertEqual(report.total_revenue, 300000)
        self.assertEqual(report.avg_order_value, 150000)


class ReportApiTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000140', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000140')
        self.vendor_user = vuser
        self.operator = User.objects.create_user(phone='09120000141', password='x',
                                                  full_name='O', role='operator', city='Tehran')
        VendorReport.objects.create(vendor=self.vendor, period='daily',
                                    period_start=date.today(), period_end=date.today(),
                                    total_orders=5, total_revenue=500000, avg_order_value=100000)

    def test_vendor_sees_own_reports(self):
        self.client.force_authenticate(self.vendor_user)
        resp = self.client.get('/api/v1/reports/vendor/?period=daily')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 1)
        self.assertEqual(resp.data[0]['total_revenue'], 500000)

    def test_operator_summary(self):
        self.client.force_authenticate(self.operator)
        resp = self.client.get('/api/v1/reports/operator/summary/')
        self.assertEqual(resp.status_code, 200)
        self.assertIn('total_revenue', resp.data)
