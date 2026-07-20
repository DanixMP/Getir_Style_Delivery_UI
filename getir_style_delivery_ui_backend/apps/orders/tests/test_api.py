from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.catalog.models import Category, DiningTable, Item
from apps.orders.models import Order

User = get_user_model()


class OrderApiTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food')
        vuser = User.objects.create_user(phone='09120000020', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V Co',
                                                    address='a', city='Tehran', phone='09120000020')
        self.item = Item.objects.create(vendor=self.vendor, category=self.cat,
                                        name='Burger', price=120000, city='Tehran')
        self.customer = User.objects.create_user(phone='09120000021', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.operator = User.objects.create_user(phone='09120000022', password='x',
                                                  full_name='O', role='operator', city='Tehran')

    def _create_order(self):
        self.client.force_authenticate(self.customer)
        return self.client.post('/api/v1/orders/', {
            'vendor': str(self.vendor.id),
            'delivery_type': 'in_city',
            'payment_method': 'cash',
            'delivery_address': 'Street 1',
            'delivery_city': 'Tehran',
            'items': [{'item': str(self.item.id), 'quantity': 2}],
        }, format='json')

    def test_create_order_computes_total(self):
        resp = self._create_order()
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(resp.data['total_amount'], 240000)
        self.assertEqual(len(resp.data['items']), 1)

    def test_order_rejects_item_from_other_vendor(self):
        other_v = VendorProfile.objects.create(
            user=User.objects.create_user(phone='09120000099', password='x', full_name='O2', role='vendor'),
            business_name='Other', address='a', city='Tehran', phone='09120000099')
        other_item = Item.objects.create(vendor=other_v, category=self.cat, name='X', price=1000, city='Tehran')
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/orders/', {
            'vendor': str(self.vendor.id), 'delivery_type': 'in_city', 'payment_method': 'cash',
            'delivery_address': 'a', 'delivery_city': 'Tehran',
            'items': [{'item': str(other_item.id), 'quantity': 1}],
        }, format='json')
        self.assertEqual(resp.status_code, 400)

    def test_customer_sees_only_own_orders(self):
        self._create_order()
        other = User.objects.create_user(phone='09120000030', password='x', full_name='C2', role='customer')
        self.client.force_authenticate(other)
        resp = self.client.get('/api/v1/orders/')
        self.assertEqual(resp.data['count'], 0)

    def test_valid_status_transition_via_api(self):
        order = Order.objects.create(customer=self.customer, vendor=self.vendor,
                                     delivery_type='in_city', payment_method='cash',
                                     delivery_address='a', delivery_city='Tehran', total_amount=0)
        self.client.force_authenticate(self.operator)
        resp = self.client.patch(f'/api/v1/orders/{order.id}/status/', {'status': 'accepted'}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['status'], 'accepted')

    def test_invalid_status_transition_returns_400(self):
        order = Order.objects.create(customer=self.customer, vendor=self.vendor,
                                     delivery_type='in_city', payment_method='cash',
                                     delivery_address='a', delivery_city='Tehran', total_amount=0)
        self.client.force_authenticate(self.operator)
        resp = self.client.patch(f'/api/v1/orders/{order.id}/status/', {'status': 'delivered'}, format='json')
        self.assertEqual(resp.status_code, 400)
        self.assertEqual(resp.data['detail'], 'Invalid status transition.')

    def test_offline_order_operator_only(self):
        self.client.force_authenticate(self.customer)
        self.assertEqual(self.client.get('/api/v1/orders/offline/').status_code, 403)
        self.client.force_authenticate(self.operator)
        resp = self.client.post('/api/v1/orders/offline/', {
            'customer_phone': '09120000040', 'customer_name': 'Phone Cust',
            'vendor': str(self.vendor.id), 'items_description': '2x Burger',
            'total_amount': 240000, 'delivery_address': 'Street 9',
        }, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)


class DineInOrderApiTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food')
        vuser = User.objects.create_user(phone='09120000050', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(
            user=vuser, business_name='Dine Rest', address='a', city='Tehran',
            phone='09120000050', supports_dine_in=True,
        )
        self.table = DiningTable.objects.create(
            vendor=self.vendor, label='Table 5', hotspot_yaw=0, hotspot_pitch=0,
            capacity=2, status='available',
        )
        self.item = Item.objects.create(
            vendor=self.vendor, category=self.cat, name='Soup', price=80000, city='Tehran',
        )
        self.customer = User.objects.create_user(phone='09120000051', password='x',
                                                  full_name='C', role='customer', city='Tehran')

    def test_create_dine_in_order_without_delivery_address(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/orders/', {
            'vendor': str(self.vendor.id),
            'fulfillment_type': 'dine_in',
            'dining_table': str(self.table.id),
            'delivery_type': 'in_city',
            'payment_method': 'cash',
            'items': [{'item': str(self.item.id), 'quantity': 1}],
        }, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(resp.data['fulfillment_type'], 'dine_in')
        self.assertEqual(str(resp.data['dining_table']), str(self.table.id))
        self.assertEqual(resp.data['delivery_address'], 'Table 5')
        self.assertEqual(resp.data['delivery_city'], 'Tehran')
        self.assertEqual(resp.data['total_amount'], 80000)

    def test_delivery_order_still_requires_address(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/orders/', {
            'vendor': str(self.vendor.id),
            'fulfillment_type': 'delivery',
            'delivery_type': 'in_city',
            'payment_method': 'cash',
            'items': [{'item': str(self.item.id), 'quantity': 1}],
        }, format='json')
        self.assertEqual(resp.status_code, 400)
        self.assertIn('delivery_address', resp.data)

    def test_dine_in_status_transition_preparing_to_ready(self):
        order = Order.objects.create(
            customer=self.customer, vendor=self.vendor,
            fulfillment_type='dine_in', dining_table=self.table,
            delivery_type='in_city', payment_method='cash',
            delivery_address='Table 5', delivery_city='Tehran',
            status='preparing', total_amount=80000,
        )
        self.client.force_authenticate(self.vendor.user)
        resp = self.client.patch(
            f'/api/v1/orders/{order.id}/status/', {'status': 'ready'}, format='json',
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['status'], 'ready')
