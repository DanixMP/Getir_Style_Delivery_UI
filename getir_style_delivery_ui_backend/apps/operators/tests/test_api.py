from unittest.mock import patch

from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import OperatorProfile, PeykProfile, VendorProfile
from apps.catalog.models import Category, Item
from apps.communications.voip_adapter import VOIPAdapter
from apps.orders.models import Order

User = get_user_model()


class FakeAdapter(VOIPAdapter):
    def generate_token(self, channel, user_id, user_name, expiry_seconds):
        return 'fake'

    def start_recording(self, channel, order_id):
        return None

    def stop_recording(self, egress_id):
        return None


class OperatorPanelTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food')
        vuser = User.objects.create_user(phone='09120000110', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000110')
        self.item = Item.objects.create(vendor=self.vendor, category=self.cat, name='Dish',
                                        price=10000, city='Tehran')
        puser = User.objects.create_user(phone='09120000111', password='x',
                                         full_name='P', role='peyk', city='Tehran')
        self.peyk = PeykProfile.objects.create(user=puser, vehicle_type='motor')
        self.operator = User.objects.create_user(phone='09120000112', password='x',
                                                  full_name='O', role='operator', city='Tehran')
        OperatorProfile.objects.create(user=self.operator, assigned_city='Tehran', employee_id='EMP-1')

    def test_checklist(self):
        self.client.force_authenticate(self.operator)
        resp = self.client.get('/api/v1/operator/vendors/checklist/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data[0]['business_name'], 'V')
        self.assertEqual(resp.data[0]['items'][0]['name'], 'Dish')

    def test_item_availability_and_price(self):
        self.client.force_authenticate(self.operator)
        r1 = self.client.patch(f'/api/v1/operator/items/{self.item.id}/availability/',
                               {'is_available': False}, format='json')
        self.assertEqual(r1.status_code, 200)
        self.item.refresh_from_db()
        self.assertFalse(self.item.is_available)

        r2 = self.client.patch(f'/api/v1/operator/items/{self.item.id}/price/',
                               {'price': 75000}, format='json')
        self.assertEqual(r2.status_code, 200)
        self.item.refresh_from_db()
        self.assertEqual(self.item.price, 75000)

    def test_peyk_board_and_availability(self):
        self.client.force_authenticate(self.operator)
        resp = self.client.get('/api/v1/operator/peyks/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 1)

        r2 = self.client.patch(f'/api/v1/operator/peyks/{self.peyk.id}/availability/',
                               {'is_available': True}, format='json')
        self.assertEqual(r2.status_code, 200)
        self.peyk.refresh_from_db()
        self.assertTrue(self.peyk.is_available)

    def test_non_operator_denied(self):
        customer = User.objects.create_user(phone='09120000113', password='x',
                                            full_name='C', role='customer', city='Tehran')
        self.client.force_authenticate(customer)
        self.assertEqual(self.client.get('/api/v1/operator/vendors/checklist/').status_code, 403)

    def test_offline_orders_via_operator_route(self):
        self.client.force_authenticate(self.operator)
        resp = self.client.post('/api/v1/operator/offline-orders/', {
            'customer_phone': '09120000120', 'customer_name': 'Phone',
            'vendor': str(self.vendor.id), 'items_description': '1x Dish',
            'total_amount': 10000, 'delivery_address': 'addr',
        }, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)

    @patch('apps.communications.call_service.get_voip_adapter', return_value=FakeAdapter())
    def test_peyk_call_proxy(self, _mock):
        self.client.force_authenticate(self.operator)
        resp = self.client.post(f'/api/v1/operator/peyks/{self.peyk.user_id}/call/',
                                {'consent_acknowledged': True}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('token', resp.data)

    @patch('apps.communications.call_service.get_voip_adapter', return_value=FakeAdapter())
    def test_vendor_call_proxy(self, _mock):
        self.client.force_authenticate(self.operator)
        resp = self.client.post(f'/api/v1/operator/vendors/{self.vendor.id}/call/',
                                {'consent_acknowledged': True}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('token', resp.data)
