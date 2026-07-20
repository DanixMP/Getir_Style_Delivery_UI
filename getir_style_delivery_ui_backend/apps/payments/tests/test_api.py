from unittest.mock import patch

from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.orders.models import Order
from apps.payments.models import ZarinpalTransaction

User = get_user_model()


class PaymentTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000100', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000100')
        self.customer = User.objects.create_user(phone='09120000101', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.order = Order.objects.create(customer=self.customer, vendor=self.vendor,
                                          delivery_type='in_city', payment_method='online',
                                          delivery_address='a', delivery_city='Tehran',
                                          total_amount=50000)

    @patch('apps.payments.views.zarinpal.request_payment', return_value={'authority': 'A00000000001'})
    def test_initiate_returns_payment_url(self, _mock):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/payments/initiate/', {'order_id': str(self.order.id)}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('StartPay/A00000000001', resp.data['payment_url'])
        self.assertTrue(ZarinpalTransaction.objects.filter(authority='A00000000001').exists())

    def test_initiate_customer_only(self):
        operator = User.objects.create_user(phone='09120000102', password='x',
                                            full_name='O', role='operator', city='Tehran')
        self.client.force_authenticate(operator)
        resp = self.client.post('/api/v1/payments/initiate/', {'order_id': str(self.order.id)}, format='json')
        self.assertEqual(resp.status_code, 403)

    @patch('apps.payments.views.zarinpal.verify_payment', return_value={'ref_id': '99887766', 'verified': True})
    def test_verify_success(self, _mock):
        ZarinpalTransaction.objects.create(order=self.order, amount=50000,
                                           authority='A00000000002', payment_method='online')
        resp = self.client.get('/api/v1/payments/verify/?Authority=A00000000002&Status=OK')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['ref_id'], '99887766')
        self.assertEqual(ZarinpalTransaction.objects.get(authority='A00000000002').status, 'verified')

    def test_verify_cancelled(self):
        ZarinpalTransaction.objects.create(order=self.order, amount=50000,
                                           authority='A00000000003', payment_method='online')
        resp = self.client.get('/api/v1/payments/verify/?Authority=A00000000003&Status=NOK')
        self.assertEqual(resp.status_code, 400)
        self.assertEqual(ZarinpalTransaction.objects.get(authority='A00000000003').status, 'failed')

    def test_status_endpoint(self):
        ZarinpalTransaction.objects.create(order=self.order, amount=50000,
                                           authority='A00000000004', payment_method='online',
                                           status='verified', ref_id='123')
        self.client.force_authenticate(self.customer)
        resp = self.client.get(f'/api/v1/payments/{self.order.id}/status/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data['status'], 'verified')
