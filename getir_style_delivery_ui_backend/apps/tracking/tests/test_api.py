from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.orders.models import Order
from apps.tracking.models import GPSSnapshot

User = get_user_model()


class TrackingTests(APITestCase):
    def setUp(self):
        self.peyk = User.objects.create_user(phone='09120000060', password='x',
                                              full_name='P', role='peyk', city='Tehran')
        self.customer = User.objects.create_user(phone='09120000061', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.operator = User.objects.create_user(phone='09120000062', password='x',
                                                  full_name='O', role='operator', city='Tehran')

    def test_customer_cannot_post_location(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/tracking/location/',
                                {'latitude': '35.6892', 'longitude': '51.3890'}, format='json')
        self.assertEqual(resp.status_code, 403)

    def test_peyk_posts_location(self):
        self.client.force_authenticate(self.peyk)
        resp = self.client.post('/api/v1/tracking/location/',
                                {'latitude': '35.6892', 'longitude': '51.3890'}, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(GPSSnapshot.objects.filter(peyk=self.peyk).count(), 1)

    def test_operator_reads_latest(self):
        from datetime import timedelta

        from django.utils import timezone
        now = timezone.now()
        s1 = GPSSnapshot.objects.create(peyk=self.peyk, latitude='35.1', longitude='51.1')
        s2 = GPSSnapshot.objects.create(peyk=self.peyk, latitude='35.2', longitude='51.2')
        # Force distinct timestamps (auto_now_add can collide at clock resolution).
        GPSSnapshot.objects.filter(pk=s1.pk).update(timestamp=now - timedelta(seconds=10))
        GPSSnapshot.objects.filter(pk=s2.pk).update(timestamp=now)
        self.client.force_authenticate(self.operator)
        resp = self.client.get(f'/api/v1/tracking/location/{self.peyk.id}/latest/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(str(resp.data['latitude']), '35.200000')

    def test_latest_404_when_no_data(self):
        self.client.force_authenticate(self.operator)
        resp = self.client.get(f'/api/v1/tracking/location/{self.peyk.id}/latest/')
        self.assertEqual(resp.status_code, 404)
