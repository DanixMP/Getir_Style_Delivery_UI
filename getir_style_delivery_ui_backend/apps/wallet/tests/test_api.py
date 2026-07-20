from unittest.mock import patch

from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from apps.accounts.models import VendorProfile
from apps.catalog.models import Category, Item
from apps.orders.models import Order
from apps.wallet import services
from apps.wallet.models import Wallet, WalletTopUp, WalletTransaction

User = get_user_model()


class WalletServiceTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(phone='09120000200', password='x',
                                             full_name='C', role='customer', city='Tehran')

    def test_credit_and_debit_track_balance(self):
        wallet = services.get_or_create_wallet(self.user)
        c = services.credit(wallet, 100000, 'topup')
        d = services.debit(wallet, 30000, 'order_payment')
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 70000)
        # Each entry snapshots the balance after it was applied.
        self.assertEqual(c.balance_after, 100000)
        self.assertEqual(d.balance_after, 70000)
        self.assertEqual(WalletTransaction.objects.filter(wallet=wallet).count(), 2)

    def test_debit_overdraft_blocked(self):
        wallet = services.get_or_create_wallet(self.user)
        services.credit(wallet, 5000, 'topup')
        with self.assertRaises(services.InsufficientFunds):
            services.debit(wallet, 6000, 'order_payment')
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 5000)


class WalletApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(phone='09120000201', password='x',
                                             full_name='C', role='customer', city='Tehran')

    def test_get_wallet_creates_it(self):
        self.client.force_authenticate(self.user)
        resp = self.client.get('/api/v1/wallet/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data['balance'], 0)
        self.assertTrue(Wallet.objects.filter(user=self.user).exists())

    def test_wallet_requires_auth(self):
        self.assertEqual(self.client.get('/api/v1/wallet/').status_code, 401)

    @patch('apps.wallet.views.zarinpal.request_payment', return_value={'authority': 'W0000000001'})
    def test_topup_initiate(self, _mock):
        self.client.force_authenticate(self.user)
        resp = self.client.post('/api/v1/wallet/topup/initiate/', {'amount': 50000}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn('StartPay/W0000000001', resp.data['payment_url'])
        self.assertTrue(WalletTopUp.objects.filter(authority='W0000000001', status='pending').exists())

    def test_topup_min_amount(self):
        self.client.force_authenticate(self.user)
        resp = self.client.post('/api/v1/wallet/topup/initiate/', {'amount': 100}, format='json')
        self.assertEqual(resp.status_code, 400)

    @patch('apps.wallet.views.zarinpal.verify_payment', return_value={'ref_id': 'R123', 'verified': True})
    def test_topup_verify_credits_wallet(self, _mock):
        wallet = services.get_or_create_wallet(self.user)
        WalletTopUp.objects.create(wallet=wallet, amount=80000, authority='W0000000002')
        resp = self.client.get('/api/v1/wallet/topup/verify/?Authority=W0000000002&Status=OK')
        self.assertEqual(resp.status_code, 200, resp.data)
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 80000)
        self.assertEqual(WalletTopUp.objects.get(authority='W0000000002').status, 'verified')

    @patch('apps.wallet.views.zarinpal.verify_payment')
    def test_topup_verify_cancelled(self, mock_verify):
        wallet = services.get_or_create_wallet(self.user)
        WalletTopUp.objects.create(wallet=wallet, amount=80000, authority='W0000000003')
        resp = self.client.get('/api/v1/wallet/topup/verify/?Authority=W0000000003&Status=NOK')
        self.assertEqual(resp.status_code, 400)
        mock_verify.assert_not_called()
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 0)


class WalletPayOrderTests(APITestCase):
    def setUp(self):
        vuser = User.objects.create_user(phone='09120000210', password='x',
                                         full_name='V', role='vendor', city='Tehran')
        self.vendor = VendorProfile.objects.create(user=vuser, business_name='V', address='a',
                                                    city='Tehran', phone='09120000210')
        self.customer = User.objects.create_user(phone='09120000211', password='x',
                                                  full_name='C', role='customer', city='Tehran')
        self.operator = User.objects.create_user(phone='09120000212', password='x',
                                                  full_name='O', role='operator', city='Tehran')

    def _order(self, method='wallet', amount=40000):
        return Order.objects.create(customer=self.customer, vendor=self.vendor,
                                    delivery_type='in_city', payment_method=method,
                                    delivery_address='a', delivery_city='Tehran',
                                    total_amount=amount)

    def test_pay_order_debits_and_marks_paid(self):
        wallet = services.get_or_create_wallet(self.customer)
        services.credit(wallet, 100000, 'topup')
        order = self._order()
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/wallet/pay-order/', {'order_id': str(order.id)}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data['balance_after'], 60000)
        order.refresh_from_db()
        self.assertTrue(order.is_paid)

    def test_pay_order_insufficient_funds(self):
        services.get_or_create_wallet(self.customer)  # zero balance
        order = self._order()
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/wallet/pay-order/', {'order_id': str(order.id)}, format='json')
        self.assertEqual(resp.status_code, 400)
        order.refresh_from_db()
        self.assertFalse(order.is_paid)

    def test_pay_order_rejects_non_wallet_method(self):
        wallet = services.get_or_create_wallet(self.customer)
        services.credit(wallet, 100000, 'topup')
        order = self._order(method='cash')
        self.client.force_authenticate(self.customer)
        resp = self.client.post('/api/v1/wallet/pay-order/', {'order_id': str(order.id)}, format='json')
        self.assertEqual(resp.status_code, 400)

    def test_cancel_refunds_wallet_paid_order(self):
        wallet = services.get_or_create_wallet(self.customer)
        services.credit(wallet, 100000, 'topup')
        order = self._order()
        services.pay_order(self.customer, order)
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 60000)

        # Operator cancels a pending order -> wallet refunded.
        self.client.force_authenticate(self.operator)
        resp = self.client.patch(f'/api/v1/orders/{order.id}/status/', {'status': 'cancelled'}, format='json')
        self.assertEqual(resp.status_code, 200, resp.data)
        wallet.refresh_from_db()
        self.assertEqual(wallet.balance, 100000)
        order.refresh_from_db()
        self.assertFalse(order.is_paid)
