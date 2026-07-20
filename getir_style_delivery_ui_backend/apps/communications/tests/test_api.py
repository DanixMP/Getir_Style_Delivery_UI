from unittest.mock import patch

from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.communications.models import CallLog, FCMDevice
from apps.communications.voip_adapter import VOIPAdapter
from apps.delivery.models import PeykAssignment
from apps.orders.models import Order

User = get_user_model()


class FakeAdapter(VOIPAdapter):
    def generate_token(self, channel, user_id, user_name, expiry_seconds):
        return f'fake-token-{channel}'

    def start_recording(self, channel, order_id):
        return 'egress-123'

    def stop_recording(self, egress_id):
        return None


class CallTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000070', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000070')
        self.customer = User.objects.create_user(phone='09120000071', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.other = User.objects.create_user(phone='09120000072', password='x',
                                               full_name='X', role='customer', city='Tehran')
        self.operator = User.objects.create_user(phone='09120000073', password='x',
                                                  full_name='O', role='operator', city='Tehran')
        self.peyk = User.objects.create_user(phone='09120000074', password='x',
                                             full_name='P', role='peyk', city='Tehran')
        self.order = Order.objects.create(customer=self.customer, vendor=self.vendor,
                                          delivery_type='in_city', payment_method='cash',
                                          delivery_address='a', delivery_city='Tehran', total_amount=0)

    def _assign_order(self, status='accepted'):
        self.order.status = status
        self.order.save(update_fields=['status'])
        return PeykAssignment.objects.create(order=self.order, peyk=self.peyk)

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_initiate_requires_consent(self, _mock):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/communications/call/initiate/',
                                {'order_id': str(self.order.id), 'consent_acknowledged': False},
                                format='json')
        self.assertEqual(resp.status_code, 400)

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_no_assigned_peyk_cannot_call(self, _mock):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/communications/call/initiate/',
                                {'order_id': str(self.order.id), 'consent_acknowledged': True},
                                format='json')
        self.assertEqual(resp.status_code, 400)
        self.assertEqual(CallLog.objects.count(), 0)

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_customer_can_call_assigned_active_order(self, _mock):
        self._assign_order()
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/communications/call/initiate/',
                                {'order_id': str(self.order.id), 'consent_acknowledged': True},
                                format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertTrue(resp.data['token'].startswith('fake-token-order_'))
        self.assertEqual(resp.data['channel_name'], f'order_{self.order.id}')
        self.assertEqual(CallLog.objects.count(), 1)

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_assigned_peyk_can_call_same_active_order(self, _mock):
        self._assign_order('picked_up')
        self.client.force_authenticate(self.peyk)
        resp = self.client.post('/api/v1/communications/call/initiate/',
                                {'order_id': str(self.order.id), 'consent_acknowledged': True},
                                format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertTrue(resp.data['token'].startswith('fake-token-order_'))
        self.assertEqual(resp.data['channel_name'], f'order_{self.order.id}')

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_non_party_rejected(self, _mock):
        self._assign_order()
        self.client.force_authenticate(self.other)
        resp = self.client.post('/api/v1/communications/call/initiate/',
                                {'order_id': str(self.order.id), 'consent_acknowledged': True},
                                format='json')
        self.assertEqual(resp.status_code, 403)

    @patch('apps.communications.call_service.get_voip_adapter', return_value=FakeAdapter())
    def test_operator_initiate_to_peyk(self, _mock):
        self.client.force_authenticate(self.operator)
        resp = self.client.post('/api/v1/communications/call/operator-initiate/',
                                {'peyk_id': str(self.peyk.id), 'consent_acknowledged': True},
                                format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertTrue(resp.data['channel_name'].startswith(f'op_{self.operator.id}_'))

    @patch('apps.communications.views.get_voip_adapter', return_value=FakeAdapter())
    def test_call_end_computes_duration(self, _mock):
        log = CallLog.objects.create(caller=self.customer, channel_name='order_x',
                                     livekit_room_name='order_x', consent_acknowledged=True)
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/communications/call/end/',
                                {'call_log_id': str(log.id)}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('duration_seconds', resp.data)


class DeviceTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(phone='09120000080', password='x',
                                             full_name='U', role='customer', city='Tehran')

    def test_register_and_delete_device(self):
        self.client.force_authenticate(self.user)
        resp = self.client.post('/api/v1/communications/devices/register/',
                                {'fcm_token': 'tok-abc', 'device_type': 'android'}, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertTrue(FCMDevice.objects.filter(fcm_token='tok-abc').exists())

        resp = self.client.delete('/api/v1/communications/devices/tok-abc/')
        self.assertEqual(resp.status_code, 204)
        self.assertFalse(FCMDevice.objects.filter(fcm_token='tok-abc').exists())
