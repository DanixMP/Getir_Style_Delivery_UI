from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import PhoneOtp

User = get_user_model()


class OtpAuthTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone='09120000000',
            password='dev123456',
            full_name='Dev User',
            role='developer',
        )

    def test_request_and_verify_otp(self):
        resp = self.client.post('/api/v1/auth/otp/request/', {'phone': '09120000000'})
        self.assertEqual(resp.status_code, 200)
        otp = PhoneOtp.objects.filter(phone='09120000000', is_used=False).latest('created_at')
        resp = self.client.post('/api/v1/auth/otp/verify/', {
            'phone': '09120000000',
            'code': otp.code,
        })
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('access', resp.data)
        self.assertIn('refresh', resp.data)
