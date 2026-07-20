from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.catalog.models import Category, Item

User = get_user_model()


def make_vendor(phone, business, city='Tehran', category=None):
    user = User.objects.create_user(phone=phone, password='x', full_name=business, role='vendor', city=city)
    return VendorProfile.objects.create(
        user=user, business_name=business, address='addr', city=city,
        phone=phone, category=category,
    )


class CatalogTests(APITestCase):
    def setUp(self):
        self.cat = Category.objects.create(name='Food', slug='getir_style_delivery_ui-food', display_order=1)
        self.coming = Category.objects.create(name='Taxi', slug='getir_style_delivery_ui-taxi', is_coming_soon=True)
        self.vendor = make_vendor('09120000010', 'Pizza Place', category=self.cat)
        self.cheap = Item.objects.create(vendor=self.vendor, category=self.cat, name='Cheap Pizza',
                                         price=50000, city='Tehran', rating=4.0)
        self.pricey = Item.objects.create(vendor=self.vendor, category=self.cat, name='Lux Pizza',
                                          price=200000, city='Tehran', rating=5.0)
        self.other_city = Item.objects.create(vendor=self.vendor, category=self.cat, name='Shiraz Pizza',
                                              price=80000, city='Shiraz')
        self.customer = User.objects.create_user(phone='09120000011', password='x',
                                                  full_name='Cust', role='customer', city='Tehran')

    def auth(self, user):
        self.client.force_authenticate(user)

    def add_turkish_content(self):
        self.cat.name_translations = {'tr': 'Yemek'}
        self.cat.save(update_fields=['name_translations'])
        self.vendor.business_name_translations = {'tr': 'Pizza Noktasi'}
        self.vendor.description_translations = {'tr': 'Turkce aciklama'}
        self.vendor.save(update_fields=['business_name_translations', 'description_translations'])
        self.cheap.name_translations = {'tr': 'Ucuz Pizza'}
        self.cheap.description_translations = {'tr': 'Butce dostu pizza'}
        self.cheap.save(update_fields=['name_translations', 'description_translations'])

    def test_categories_include_coming_soon(self):
        self.auth(self.customer)
        resp = self.client.get('/api/v1/catalog/categories/')
        self.assertEqual(resp.status_code, 200)
        slugs = {c['slug'] for c in resp.data['results']}
        self.assertIn('getir_style_delivery_ui-taxi', slugs)

    def test_accept_language_localizes_category_and_item_content(self):
        self.add_turkish_content()
        self.auth(self.customer)

        category_resp = self.client.get(
            '/api/v1/catalog/categories/',
            HTTP_ACCEPT_LANGUAGE='tr',
        )
        category = next(c for c in category_resp.data['results'] if c['slug'] == 'getir_style_delivery_ui-food')
        self.assertEqual(category['name'], 'Yemek')

        item_resp = self.client.get(
            '/api/v1/catalog/items/?city=Tehran&ordering=cheapest',
            HTTP_ACCEPT_LANGUAGE='tr',
        )
        item = item_resp.data['results'][0]
        self.assertEqual(item['name'], 'Ucuz Pizza')
        self.assertEqual(item['description'], 'Butce dostu pizza')
        self.assertEqual(item['vendor_name'], 'Pizza Noktasi')

    def test_accept_language_falls_back_to_base_content(self):
        self.add_turkish_content()
        self.auth(self.customer)

        resp = self.client.get(
            '/api/v1/catalog/items/?city=Tehran&ordering=cheapest',
            HTTP_ACCEPT_LANGUAGE='en',
        )
        self.assertEqual(resp.data['results'][0]['name'], 'Cheap Pizza')

    def test_filter_by_city(self):
        self.auth(self.customer)
        resp = self.client.get('/api/v1/catalog/items/?city=Tehran')
        names = {i['name'] for i in resp.data['results']}
        self.assertIn('Cheap Pizza', names)
        self.assertNotIn('Shiraz Pizza', names)

    def test_ordering_cheapest(self):
        self.auth(self.customer)
        resp = self.client.get('/api/v1/catalog/items/?city=Tehran&ordering=cheapest')
        prices = [i['price'] for i in resp.data['results']]
        self.assertEqual(prices, sorted(prices))

    def test_ordering_priciest(self):
        self.auth(self.customer)
        resp = self.client.get('/api/v1/catalog/items/?city=Tehran&ordering=priciest')
        prices = [i['price'] for i in resp.data['results']]
        self.assertEqual(prices, sorted(prices, reverse=True))

    def test_search(self):
        self.auth(self.customer)
        resp = self.client.get('/api/v1/catalog/items/?search=Lux')
        names = {i['name'] for i in resp.data['results']}
        self.assertEqual(names, {'Lux Pizza'})

    def test_search_matches_requested_language_translations(self):
        self.add_turkish_content()
        self.auth(self.customer)

        resp = self.client.get(
            '/api/v1/catalog/items/?search=Ucuz',
            HTTP_ACCEPT_LANGUAGE='tr',
        )
        names = {i['name'] for i in resp.data['results']}
        self.assertEqual(names, {'Ucuz Pizza'})

    def test_customer_cannot_create_item(self):
        self.auth(self.customer)
        resp = self.client.post('/api/v1/catalog/items/', {
            'category': str(self.cat.id), 'name': 'X', 'price': 1000, 'city': 'Tehran',
        })
        self.assertEqual(resp.status_code, 403)

    def test_vendor_creates_own_item(self):
        self.auth(self.vendor.user)
        resp = self.client.post('/api/v1/catalog/items/', {
            'category': str(self.cat.id), 'name': 'New Dish', 'price': 30000, 'city': 'Tehran',
        })
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(Item.objects.get(name='New Dish').vendor_id, self.vendor.id)

    def test_vendor_create_item_accepts_translation_maps(self):
        self.auth(self.vendor.user)
        resp = self.client.post('/api/v1/catalog/items/', {
            'category': str(self.cat.id),
            'name': 'New Dish',
            'name_translations': {'tr': 'Yeni Yemek'},
            'description': 'Base description',
            'description_translations': {'tr': 'Turkce aciklama'},
            'price': 30000,
            'city': 'Tehran',
        }, format='json')
        self.assertEqual(resp.status_code, 201, resp.data)
        item = Item.objects.get(name='New Dish')
        self.assertEqual(item.name_translations['tr'], 'Yeni Yemek')
        self.assertEqual(item.description_translations['tr'], 'Turkce aciklama')

    def test_vendor_create_item_rejects_unsupported_translation_language(self):
        self.auth(self.vendor.user)
        resp = self.client.post('/api/v1/catalog/items/', {
            'category': str(self.cat.id),
            'name': 'New Dish',
            'name_translations': {'de': 'Neues Gericht'},
            'price': 30000,
            'city': 'Tehran',
        }, format='json')
        self.assertEqual(resp.status_code, 400)

    def test_soft_delete_marks_unavailable(self):
        self.auth(self.vendor.user)
        resp = self.client.delete(f'/api/v1/catalog/items/{self.cheap.id}/')
        self.assertEqual(resp.status_code, 204)
        self.cheap.refresh_from_db()
        self.assertFalse(self.cheap.is_available)
