"""
Live WebSocket tracking test against Daphne (http://127.0.0.1:8000).

Prepares a picked_up order, opens ws/tracking/{order_id}/ as the customer,
posts GPS from the peyk over HTTP, and asserts the customer receives
location.update frames in real time.

Usage (Daphne must already be running):
    .venv/Scripts/python.exe scripts/ws_tracking_test.py
"""
import asyncio
import json
import os
import sys
import threading
import time

import django
import requests

try:
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
except Exception:
    pass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.contrib.auth import get_user_model  # noqa: E402
from apps.accounts.models import OperatorProfile, PeykProfile, VendorProfile  # noqa: E402
from apps.catalog.models import Category, Item  # noqa: E402
from apps.orders.models import Order  # noqa: E402
from apps.wallet.services import credit, get_or_create_wallet  # noqa: E402

User = get_user_model()
BASE = 'http://127.0.0.1:8000/api/v1'
WS_BASE = 'ws://127.0.0.1:8000'


def H(token):
    return {'Authorization': f'Bearer {token}'}


def login(phone, password):
    r = requests.post(f'{BASE}/auth/login/', json={'phone': phone, 'password': password}, timeout=10)
    r.raise_for_status()
    return r.json()['access']


def ensure_order(peyk_id):
    """Return (order_id, customer_token, peyk_token) for a picked_up order."""
    cat, _ = Category.objects.get_or_create(slug='getir_style_delivery_ui-food', defaults={'name': 'GetirStyleDeliveryUi Food'})
    vuser, _ = User.objects.get_or_create(
        phone='09120000300',
        defaults={'full_name': 'صاحب رستوران', 'role': 'vendor', 'city': 'Tehran'},
    )
    vendor, _ = VendorProfile.objects.get_or_create(
        user=vuser,
        defaults={
            'business_name': 'رستوران تست',
            'address': 'تهران',
            'city': 'Tehran',
            'phone': '09120000300',
            'category': cat,
        },
    )
    item, _ = Item.objects.get_or_create(
        vendor=vendor,
        name='چلو کباب تست',
        defaults={'category': cat, 'price': 185000, 'city': 'Tehran'},
    )
    ouser, _ = User.objects.get_or_create(
        phone='09120000301',
        defaults={'full_name': 'اپراتور', 'role': 'operator', 'city': 'Tehran'},
    )
    OperatorProfile.objects.get_or_create(
        user=ouser, defaults={'assigned_city': 'Tehran', 'employee_id': 'EMP-WS'},
    )
    puser = User.objects.get(id=peyk_id)
    cust, _ = User.objects.get_or_create(
        phone='09121111111',
        defaults={'full_name': 'علی مشتری', 'role': 'customer', 'city': 'Tehran'},
    )
    cust.set_password('demo1234')
    cust.save()
    wallet = get_or_create_wallet(cust)
    if wallet.balance < 500000:
        credit(wallet, 500000, 'topup', description='WS test top-up')

    cust_t = login('09121111111', 'demo1234')
    op_t = login('09120000301', 'pass1234')
    peyk_t = login(puser.phone, 'pass1234')

    r = requests.post(
        f'{BASE}/orders/',
        headers=H(cust_t),
        json={
            'vendor': str(vendor.id),
            'delivery_type': 'in_city',
            'payment_method': 'wallet',
            'delivery_address': 'تهران، آزادی',
            'delivery_city': 'Tehran',
            'items': [{'item': str(item.id), 'quantity': 1}],
        },
        timeout=10,
    )
    r.raise_for_status()
    oid = r.json()['id']
    requests.post(f'{BASE}/wallet/pay-order/', headers=H(cust_t), json={'order_id': oid}, timeout=10)
    for status in ('accepted', 'preparing'):
        requests.patch(
            f'{BASE}/orders/{oid}/status/',
            headers=H(op_t),
            json={'status': status},
            timeout=10,
        )
    requests.post(
        f'{BASE}/delivery/assignments/',
        headers=H(op_t),
        json={'order': oid, 'peyk': peyk_id},
        timeout=10,
    )
    requests.patch(
        f'{BASE}/orders/{oid}/status/',
        headers=H(peyk_t),
        json={'status': 'picked_up'},
        timeout=10,
    )
    order = Order.objects.get(id=oid)
    assert order.status == 'picked_up'
    return oid, cust_t, peyk_t


async def listen_tracking(order_id, token, received):
    import websockets

    uri = f'{WS_BASE}/ws/tracking/{order_id}/?token={token}'
    async with websockets.connect(uri, open_timeout=8) as ws:
        deadline = time.time() + 12
        while time.time() < deadline:
            try:
                raw = await asyncio.wait_for(ws.recv(), timeout=6)
            except asyncio.TimeoutError:
                break
            data = json.loads(raw)
            if data.get('type') == 'location.update':
                received.append(data)


def post_locations(peyk_t, order_id, route):
    for lat, lng in route:
        r = requests.post(
            f'{BASE}/tracking/location/',
            headers=H(peyk_t),
            json={'latitude': lat, 'longitude': lng, 'order_id': order_id},
            timeout=10,
        )
        if r.status_code != 201:
            raise RuntimeError(f'location post failed: {r.status_code} {r.text}')
        time.sleep(0.4)


def main():
    try:
        import websockets  # noqa: F401
    except ImportError:
        print('Installing websockets package for this test...')
        import subprocess
        py = sys.executable
        subprocess.check_call([py, '-m', 'pip', 'install', 'websockets', '-q'])
        import websockets  # noqa: F401

    # Health check — Daphne must be up (runserver cannot serve WebSockets).
    try:
        requests.get('http://127.0.0.1:8000/api/v1/', timeout=3)
    except requests.RequestException as exc:
        print(f'❌ Backend not reachable at http://127.0.0.1:8000 — start Daphne first.\n   {exc}')
        sys.exit(1)

    puser, _ = User.objects.get_or_create(
        phone='09120000302',
        defaults={'full_name': 'پیک تست', 'role': 'peyk', 'city': 'Tehran'},
    )
    puser.role = 'peyk'
    puser.set_password('pass1234')
    puser.save()
    PeykProfile.objects.get_or_create(user=puser, defaults={'vehicle_type': 'motor'})

    print('Preparing picked_up order...')
    order_id, cust_t, peyk_t = ensure_order(str(puser.id))
    print(f'   order {order_id[:8]}… ready')

    received = []

    def run_listener():
        asyncio.run(listen_tracking(order_id, cust_t, received))

    listener = threading.Thread(target=run_listener, daemon=True)
    listener.start()
    time.sleep(1.2)  # let the WebSocket connect

    print('Posting peyk GPS updates…')
    route = [(35.7000, 51.3800), (35.6950, 51.3850), (35.6900, 51.3890)]
    post_locations(peyk_t, order_id, route)

    listener.join(timeout=15)

    print(f'\nWebSocket frames received: {len(received)}')
    for i, frame in enumerate(received, 1):
        print(
            f'   #{i} lat={frame["latitude"]} lng={frame["longitude"]} '
            f'peyk={frame["peyk_id"][:8]}…'
        )

    ok = len(received) >= 1
    last = received[-1] if received else {}
    ok = ok and abs(float(last.get('latitude', 0)) - 35.69) < 0.01

    if ok:
        print('\n✅ Realtime location tracking works over Daphne WebSocket.')
        sys.exit(0)
    print('\n❌ No location.update frames received — is Daphne running (not runserver)?')
    sys.exit(1)


if __name__ == '__main__':
    main()
