from django.test import override_settings
from rest_framework.test import APITestCase

DEV_KEY = 'test-developer-key'


@override_settings(DEVELOPER_SECRET_KEY=DEV_KEY)
class KillSwitchEndpointTests(APITestCase):
    def test_status_requires_valid_key(self):
        resp = self.client.post('/api/v1/developer/kill-switch/status/')
        self.assertEqual(resp.status_code, 403)

    def test_status_with_key(self):
        resp = self.client.post(
            '/api/v1/developer/kill-switch/status/',
            HTTP_X_DEVELOPER_KEY=DEV_KEY,
        )
        self.assertEqual(resp.status_code, 200)
        self.assertIn('active', resp.data)


@override_settings(DEVELOPER_SECRET_KEY=DEV_KEY)
class KillSwitchMiddlewareTests(APITestCase):
    @override_settings(KILL_SWITCH_ACTIVE=True)
    def test_blocks_api_when_active(self):
        # No redis in test env -> falls back to settings flag.
        resp = self.client.post('/api/v1/auth/login/', {'phone': 'x', 'password': 'y'})
        self.assertEqual(resp.status_code, 503)

    @override_settings(KILL_SWITCH_ACTIVE=True)
    def test_kill_switch_endpoint_itself_exempt(self):
        resp = self.client.post(
            '/api/v1/developer/kill-switch/status/',
            HTTP_X_DEVELOPER_KEY=DEV_KEY,
        )
        self.assertEqual(resp.status_code, 200)

    @override_settings(KILL_SWITCH_ACTIVE=False)
    def test_allows_api_when_inactive(self):
        resp = self.client.post('/api/v1/auth/login/', {'phone': 'x', 'password': 'y'})
        self.assertNotEqual(resp.status_code, 503)
