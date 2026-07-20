from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import PeykProfile

User = get_user_model()


class RegistrationTests(APITestCase):
    def test_customer_registration(self):
        resp = self.client.post('/api/v1/auth/register/', {
            'phone': '09120000001',
            'password': 'strongpass1',
            'full_name': 'Test Customer',
            'role': 'customer',
            'city': 'Tehran',
        })
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(resp.data['role'], 'customer')
        self.assertTrue(User.objects.filter(phone='09120000001').exists())

    def test_peyk_registration_creates_profile_and_code(self):
        resp = self.client.post('/api/v1/auth/register/', {
            'phone': '09120000002',
            'password': 'strongpass1',
            'full_name': 'Test Peyk',
            'role': 'peyk',
            'vehicle_type': 'motor',
        })
        self.assertEqual(resp.status_code, 201, resp.data)
        profile = PeykProfile.objects.get(user__phone='09120000002')
        self.assertTrue(profile.peyk_code.startswith('YLK-'))
        self.assertEqual(len(profile.peyk_code), 9)

    def test_peyk_registration_requires_vehicle_type(self):
        resp = self.client.post('/api/v1/auth/register/', {
            'phone': '09120000003',
            'password': 'strongpass1',
            'full_name': 'No Vehicle',
            'role': 'peyk',
        })
        self.assertEqual(resp.status_code, 400)

    def test_duplicate_phone_rejected(self):
        User.objects.create_user(phone='09120000004', password='x', full_name='A', role='customer')
        resp = self.client.post('/api/v1/auth/register/', {
            'phone': '09120000004',
            'password': 'strongpass1',
            'full_name': 'Dup',
            'role': 'customer',
        })
        self.assertEqual(resp.status_code, 400)


class LoginTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone='09121111111', password='strongpass1',
            full_name='Login User', role='customer',
        )

    def test_login_returns_tokens(self):
        resp = self.client.post('/api/v1/auth/login/', {
            'phone': '09121111111', 'password': 'strongpass1',
        })
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('access', resp.data)
        self.assertIn('refresh', resp.data)

    def test_login_wrong_password(self):
        resp = self.client.post('/api/v1/auth/login/', {
            'phone': '09121111111', 'password': 'wrong',
        })
        self.assertEqual(resp.status_code, 401)

    def test_me_requires_auth(self):
        self.assertEqual(self.client.get('/api/v1/accounts/me/').status_code, 401)

    def test_me_returns_profile(self):
        self.client.force_authenticate(self.user)
        resp = self.client.get('/api/v1/accounts/me/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data['phone'], '09121111111')


class UserManagementTests(APITestCase):
    def setUp(self):
        self.admin = User.objects.create_user(
            phone='09122222222', password='x', full_name='Admin', role='admin',
        )
        self.customer = User.objects.create_user(
            phone='09123333333', password='x', full_name='Cust', role='customer',
        )

    def test_customer_cannot_list_users(self):
        self.client.force_authenticate(self.customer)
        self.assertEqual(self.client.get('/api/v1/accounts/users/').status_code, 403)

    def test_admin_can_create_vendor_user(self):
        self.client.force_authenticate(self.admin)
        resp = self.client.post('/api/v1/accounts/users/', {
            'phone': '09124444444', 'full_name': 'Vendor User',
            'role': 'vendor', 'password': 'strongpass1', 'city': 'Tehran',
        })
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertTrue(User.objects.filter(phone='09124444444', role='vendor').exists())
