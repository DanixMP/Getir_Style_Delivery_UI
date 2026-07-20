"""
End-to-end scenario test against the running API (http://127.0.0.1:8000).

Simulates a real delivery: customer orders -> pays from wallet -> operator
accepts & assigns a peyk -> peyk picks up -> peyk streams live location ->
peyk delivers, entering the 6-digit handoff PIN the customer reads to them.

Run with the dev server already running:
    .venv/Scripts/python.exe scripts/scenario_test.py
"""
import os
import sys

import django
import requests

# Windows consoles default to cp1252; force UTF-8 so the box/emoji output works.
try:
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
except Exception:
    pass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.contrib.auth import get_user_model  # noqa: E402
from apps.accounts.models import (  # noqa: E402
    OperatorProfile,
    PeykProfile,
    VendorProfile,
)
from apps.catalog.models import Category, Item  # noqa: E402
from apps.wallet.services import credit, get_or_create_wallet  # noqa: E402

User = get_user_model()
BASE = 'http://127.0.0.1:8000/api/v1'
OK, FAIL = 0, 0


def step(title):
    print('\n' + '─' * 64)
    print(f'▶ {title}')


def check(label, condition, detail=''):
    global OK, FAIL
    mark = '✅' if condition else '❌'
    if condition:
        OK += 1
    else:
        FAIL += 1
    print(f'   {mark} {label}{(" — " + detail) if detail else ""}')


def H(token):
    return {'Authorization': f'Bearer {token}'}


def login(phone, password):
    r = requests.post(f'{BASE}/auth/login/', json={'phone': phone, 'password': password})
    r.raise_for_status()
    return r.json()['access']


# ─────────────────────────────────────────────────────────────────────────
# Setup: actors + a funded customer wallet (test data, not API)
# ─────────────────────────────────────────────────────────────────────────
print('Setting up test actors...')
cat, _ = Category.objects.get_or_create(slug='getir_style_delivery_ui-food', defaults={'name': 'GetirStyleDeliveryUi Food'})

vuser, _ = User.objects.get_or_create(phone='09120000300',
                                      defaults={'full_name': 'صاحب رستوران', 'role': 'vendor', 'city': 'Tehran'})
vuser.role = 'vendor'
vuser.set_password('pass1234')
vuser.save()
vendor, _ = VendorProfile.objects.get_or_create(
    user=vuser,
    defaults={'business_name': 'رستوران سنتی هفت‌خوان', 'address': 'تهران', 'city': 'Tehran',
              'phone': '09120000300', 'category': cat})

item, _ = Item.objects.get_or_create(vendor=vendor, name='چلو کباب کوبیده',
                                     defaults={'category': cat, 'price': 185000, 'city': 'Tehran'})

ouser, _ = User.objects.get_or_create(phone='09120000301',
                                      defaults={'full_name': 'اپراتور', 'role': 'operator', 'city': 'Tehran'})
ouser.role = 'operator'
ouser.set_password('pass1234')
ouser.save()
OperatorProfile.objects.get_or_create(user=ouser, defaults={'assigned_city': 'Tehran', 'employee_id': 'EMP-TEST'})

puser, _ = User.objects.get_or_create(phone='09120000302',
                                      defaults={'full_name': 'پیک تست', 'role': 'peyk', 'city': 'Tehran'})
puser.role = 'peyk'
puser.set_password('pass1234')
puser.save()
PeykProfile.objects.get_or_create(user=puser, defaults={'vehicle_type': 'motor'})

cust, _ = User.objects.get_or_create(phone='09121111111',
                                     defaults={'full_name': 'علی مشتری', 'role': 'customer', 'city': 'Tehran'})
cust.set_password('demo1234')
cust.save()
wallet = get_or_create_wallet(cust)
if wallet.balance < 500000:
    credit(wallet, 500000, 'topup', description='Test top-up')
wallet.refresh_from_db()
print(f'   customer wallet balance: {wallet.balance:,} Tomans')

# ─────────────────────────────────────────────────────────────────────────
# The flow (all via HTTP API)
# ─────────────────────────────────────────────────────────────────────────
cust_t = login('09121111111', 'demo1234')
op_t = login('09120000301', 'pass1234')
peyk_t = login('09120000302', 'pass1234')

step('1. Customer places an order (pay with wallet)')
r = requests.post(f'{BASE}/orders/', headers=H(cust_t), json={
    'vendor': str(vendor.id), 'delivery_type': 'in_city', 'payment_method': 'wallet',
    'delivery_address': 'تهران، خیابان آزادی، پلاک ۱۰', 'delivery_city': 'Tehran',
    'items': [{'item': str(item.id), 'quantity': 2}],
})
order = r.json()
oid = order['id']
pin = order['delivery_code']
check('order created', r.status_code == 201, f'#{oid[:8]} total {order["total_amount"]:,}')
check('customer can see the 6-digit receive PIN', bool(pin) and len(pin) == 6, f'PIN={pin}')

step('2. Customer pays from wallet')
r = requests.post(f'{BASE}/wallet/pay-order/', headers=H(cust_t), json={'order_id': oid})
check('payment accepted', r.status_code == 200, f'balance after {r.json().get("balance_after"):,}')
paid = requests.get(f'{BASE}/orders/{oid}/', headers=H(cust_t)).json()
check('order marked paid', paid['is_paid'] is True)

step('3. Operator accepts and prepares the order')
for s in ('accepted', 'preparing'):
    r = requests.patch(f'{BASE}/orders/{oid}/status/', headers=H(op_t), json={'status': s})
    check(f'status -> {s}', r.status_code == 200, r.json().get('status'))

step('4. Operator assigns the peyk')
r = requests.post(f'{BASE}/delivery/assignments/', headers=H(op_t),
                  json={'order': oid, 'peyk': str(puser.id)})
check('peyk assigned', r.status_code == 201)

step('5. Peyk sees the order (but NOT the PIN)')
r = requests.get(f'{BASE}/orders/', headers=H(peyk_t))
peyk_orders = r.json().get('results', r.json() if isinstance(r.json(), list) else [])
mine = next((o for o in peyk_orders if o['id'] == oid), None)
check('peyk sees assigned order', mine is not None)
check('PIN hidden from peyk', mine is not None and 'delivery_code' not in mine)

step('6. Peyk picks up the order')
r = requests.patch(f'{BASE}/orders/{oid}/status/', headers=H(peyk_t), json={'status': 'picked_up'})
check('status -> picked_up', r.status_code == 200, r.json().get('status'))

step('7. Peyk streams live GPS toward the customer')
route = [(35.700, 51.380), (35.695, 51.385), (35.690, 51.389)]
for lat, lng in route:
    r = requests.post(f'{BASE}/tracking/location/', headers=H(peyk_t),
                      json={'latitude': lat, 'longitude': lng, 'order_id': oid})
    check(f'location sent ({lat}, {lng})', r.status_code == 201)
latest = requests.get(f'{BASE}/tracking/location/{puser.id}/latest/', headers=H(op_t)).json()
check('latest position stored', str(latest.get('latitude')) == '35.690000', f'@ {latest.get("latitude")},{latest.get("longitude")}')

step('8. Peyk arrives — enters a WRONG PIN (should be rejected)')
wrong = '000000' if pin != '000000' else '111111'
r = requests.patch(f'{BASE}/orders/{oid}/status/', headers=H(peyk_t),
                   json={'status': 'delivered', 'delivery_code': wrong})
check('wrong PIN rejected', r.status_code == 400, r.json().get('detail'))
still = requests.get(f'{BASE}/orders/{oid}/', headers=H(cust_t)).json()
check('order still not delivered', still['status'] == 'picked_up')

step('9. Customer reads the PIN to the peyk — peyk completes delivery')
r = requests.patch(f'{BASE}/orders/{oid}/status/', headers=H(peyk_t),
                   json={'status': 'delivered', 'delivery_code': pin})
check('correct PIN accepted', r.status_code == 200, f'status {r.json().get("status")}')

final = requests.get(f'{BASE}/orders/{oid}/', headers=H(cust_t)).json()
check('order delivered', final['status'] == 'delivered')

print('\n' + '═' * 64)
print(f'  RESULT: {OK} passed, {FAIL} failed')
print('═' * 64)
sys.exit(1 if FAIL else 0)
