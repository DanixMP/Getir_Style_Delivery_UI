from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.delivery.models import PeykAssignment, TipaxShipment
from apps.orders.models import Order

User = get_user_model()


class DeliveryTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000090', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000090')
        self.customer = User.objects.create_user(phone='09120000091', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.peyk = User.objects.create_user(phone='09120000092', password='x',
                                             full_name='P', role='peyk', city='Tehran')
        self.operator = User.objects.create_user(phone='09120000093', password='x',
                                                  full_name='O', role='operator', city='Tehran')

    def _make_order(self, delivery_type='in_city'):
        return Order.objects.create(customer=self.customer, vendor=self.vendor,
                                    delivery_type=delivery_type, payment_method='cash',
                                    delivery_address='a', delivery_city='Tehran', total_amount=0)

    def test_operator_assigns_peyk(self):
        order = self._make_order()
        self.client.force_authenticate(self.operator)
        resp = self.client.post('/api/v1/delivery/assignments/', {
            'order': str(order.id), 'peyk': str(self.peyk.id),
        }, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertTrue(PeykAssignment.objects.filter(order=order, peyk=self.peyk).exists())

    def test_peyk_cannot_create_assignment(self):
        order = self._make_order()
        self.client.force_authenticate(self.peyk)
        resp = self.client.post('/api/v1/delivery/assignments/', {
            'order': str(order.id), 'peyk': str(self.peyk.id),
        }, format='json')
        self.assertEqual(resp.status_code, 403)

    def test_intercity_assignment_creates_tipax_shipment(self):
        order = self._make_order(delivery_type='inter_city')
        self.client.force_authenticate(self.operator)
        self.client.post('/api/v1/delivery/assignments/', {
            'order': str(order.id), 'peyk': str(self.peyk.id),
        }, format='json')
        self.assertTrue(TipaxShipment.objects.filter(order=order).exists())

    def test_peyk_confirm_drop_then_operator_enters_code(self):
        order = self._make_order(delivery_type='inter_city')
        TipaxShipment.objects.create(order=order, peyk=self.peyk)

        self.client.force_authenticate(self.peyk)
        resp = self.client.patch(f'/api/v1/delivery/tipax/{order.id}/confirm-drop/')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIsNotNone(TipaxShipment.objects.get(order=order).dropped_at)

        self.client.force_authenticate(self.operator)
        resp = self.client.patch(f'/api/v1/delivery/tipax/{order.id}/', {
            'tipax_tracking_code': 'TIP-12345678', 'tipax_branch_name': 'Tehran Central',
        }, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        shipment = TipaxShipment.objects.get(order=order)
        self.assertEqual(shipment.tipax_tracking_code, 'TIP-12345678')
        self.assertEqual(shipment.code_entered_by_id, self.operator.id)

    def test_peyk_sees_only_own_assignments(self):
        order = self._make_order()
        PeykAssignment.objects.create(order=order, peyk=self.peyk)
        other_peyk = User.objects.create_user(phone='09120000094', password='x',
                                              full_name='P2', role='peyk', city='Tehran')
        self.client.force_authenticate(other_peyk)
        resp = self.client.get('/api/v1/delivery/assignments/')
        self.assertEqual(resp.data['count'], 0)
