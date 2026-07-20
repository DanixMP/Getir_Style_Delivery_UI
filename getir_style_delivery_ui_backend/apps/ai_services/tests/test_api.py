from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.catalog.models import Category, Item

User = get_user_model()


class AiServicesTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food')
        vuser = User.objects.create_user(phone='09120000050', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000050')
        Item.objects.create(vendor=self.vendor, category=self.cat, name='Top', price=10000,
                            city='Tehran', rating=5.0)
        self.customer = User.objects.create_user(phone='09120000051', password='x',
                                                  full_name='C', role='customer', city='Tehran')

    def test_recommendations_requires_auth(self):
        self.assertEqual(self.client.get('/api/v1/ai/recommendations/').status_code, 401)

    def test_recommendations_returns_city_items(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.get('/api/v1/ai/recommendations/')
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(any(i['name'] == 'Top' for i in resp.data))

    def test_new_user_gets_welcome_discount(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.get('/api/v1/ai/discounts/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data[0]['type'], 'welcome')
