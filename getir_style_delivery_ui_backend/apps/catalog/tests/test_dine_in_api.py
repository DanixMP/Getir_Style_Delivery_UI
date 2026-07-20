from decimal import Decimal

from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.catalog.models import Category, DiningTable, Item, VenuePanorama

User = get_user_model()


class DineInApiTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food', display_order=1)
        vuser = User.objects.create_user(
            phone='09120000100', password='x', full_name='Rest', role='vendor', city='Tehran',
        )
        self.vendor = VendorProfile.objects.create(
            user=vuser,
            business_name='Dine Hall',
            address='Tehran',
            city='Tehran',
            phone='09120000100',
            category=self.cat,
            supports_dine_in=True,
            latitude=Decimal('35.721900'),
            longitude=Decimal('51.334700'),
        )
        self.other_vendor = VendorProfile.objects.create(
            user=User.objects.create_user(
                phone='09120000101', password='x', full_name='Delivery', role='vendor',
            ),
            business_name='Delivery Only',
            address='Tehran',
            city='Tehran',
            phone='09120000101',
            category=self.cat,
            supports_dine_in=False,
        )
        self.panorama = VenuePanorama.objects.create(
            vendor=self.vendor,
            title='Main hall',
            image_url='https://example.com/pano.jpg',
            initial_yaw=90,
            is_active=True,
        )
        self.table = DiningTable.objects.create(
            vendor=self.vendor,
            panorama=self.panorama,
            label='Table 1',
            hotspot_yaw=45,
            hotspot_pitch=-5,
            capacity=4,
            status='available',
        )
        self.item = Item.objects.create(
            vendor=self.vendor, category=self.cat, name='Kebab', price=150000, city='Tehran',
        )
        self.customer = User.objects.create_user(
            phone='09120000102', password='x', full_name='Cust', role='customer', city='Tehran',
        )

    def test_vendor_list_filters_supports_dine_in(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.get('/api/v1/catalog/vendors/?category=getir_style_delivery_ui-food&supports_dine_in=true')
        self.assertEqual(resp.status_code, 200)
        ids = {v['id'] for v in resp.data['results']}
        self.assertIn(str(self.vendor.id), ids)
        self.assertNotIn(str(self.other_vendor.id), ids)

    def test_restaurant_category_lists_dine_in_vendors(self):
        restaurant_cat = Category.objects.create(
            name='GetirStyleDeliveryUi Restaurant', slug='getir_style_delivery_ui-restaurant', display_order=2,
        )
        self.vendor.category = restaurant_cat
        self.vendor.save(update_fields=['category'])
        self.client.force_authenticate(self.customer)
        resp = self.client.get('/api/v1/catalog/vendors/?category=getir_style_delivery_ui-restaurant&supports_dine_in=true')
        self.assertEqual(resp.status_code, 200)
        ids = {v['id'] for v in resp.data['results']}
        self.assertIn(str(self.vendor.id), ids)
        self.assertNotIn(str(self.other_vendor.id), ids)

    def test_dine_in_endpoint_returns_panorama_and_tables(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.get(f'/api/v1/catalog/vendors/{self.vendor.id}/dine-in/')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['vendor']['business_name'], 'Dine Hall')
        self.assertIsNotNone(resp.data['panorama'])
        self.assertEqual(resp.data['panorama']['image'], 'https://example.com/pano.jpg')
        self.assertEqual(len(resp.data['tables']), 1)
        table = resp.data['tables'][0]
        self.assertEqual(table['label'], 'Table 1')
        self.assertEqual(table['hotspot_yaw'], 45)
        self.assertEqual(table['hotspot_pitch'], -5)
        self.assertEqual(table['status'], 'available')

    def test_dine_in_endpoint_404_when_not_supported(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.get(f'/api/v1/catalog/vendors/{self.other_vendor.id}/dine-in/')
        self.assertEqual(resp.status_code, 404)

    def test_table_hold(self):
        self.client.force_authenticate(self.customer)
        resp = self.client.post(
            f'/api/v1/catalog/vendors/{self.vendor.id}/tables/{self.table.id}/hold/',
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['label'], 'Table 1')
        self.assertEqual(resp.data['hold_seconds'], 300)
