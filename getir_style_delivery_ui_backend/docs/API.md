# GetirStyleDeliveryUi Backend — System & API Reference

> Authoritative runtime documentation for the implemented Django backend.
> Generated from the actual code in `getir_style_delivery_ui_backend/` (not just the design spec).
> For the original design contract see the root `DESIGN.md`.

---

## 1. Overview

GetirStyleDeliveryUi is a multi-category delivery platform for the Iranian market. This backend
is a JSON REST API + WebSocket service consumed exclusively by Flutter clients
(customer app, peyk/driver app, vendor web panel). Django Admin is the ops panel.

| Property | Value |
|---|---|
| Language | Python 3.11+ |
| Framework | Django 5.x + Django REST Framework |
| Auth | JWT (phone + password) via `djangorestframework-simplejwt` |
| Real-time | Django Channels (ASGI / Daphne) |
| Async | Celery + Celery Beat |
| DB | PostgreSQL 16 (prod) / SQLite (dev fallback) |
| Cache / channel layer | Redis 7 (prod) / in-memory (dev fallback) |
| Currency | Iranian Toman — `BigIntegerField`, no decimals |
| API prefix | `/api/v1/` |
| WebSocket prefix | `/ws/` |
| Default page size | 20 (PageNumberPagination) |

### Roles

`customer`, `peyk` (courier), `vendor`, `operator`, `admin`, `developer`.
`admin` and `developer` inherit all `operator` privileges.

---

## 2. Running the project

```bash
cd getir_style_delivery_ui_backend
python -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements/development.txt
copy .env.example .env          # then edit values
.venv/Scripts/python.exe manage.py migrate
.venv/Scripts/python.exe manage.py loaddata categories
.venv/Scripts/python.exe manage.py create_developer_user   # uses DEVELOPER_PHONE/PASSWORD
.venv/Scripts/python.exe manage.py runserver               # HTTP only
# For WebSockets use Daphne:
.venv/Scripts/daphne.exe -b 0.0.0.0 -p 8000 config.asgi:application
```

Run the test suite:

```bash
.venv/Scripts/python.exe manage.py test
```

> **Dev fallbacks:** with no `DATABASE_URL` the app uses SQLite; the channel layer
> is in-memory; Celery runs eagerly; the kill-switch Redis fast-path is disabled.
> Production (`config.settings.production`) requires Postgres, Redis and Arvan S3.

---

## 3. Authentication

All endpoints require a JWT access token unless marked **Public**.

```
Authorization: Bearer <access_token>
```

- Access token lifetime: **2 hours**. Refresh token: **30 days** (rotated, blacklisted after rotation).
- Obtain tokens via `POST /api/v1/auth/login/`.
- Refresh via `POST /api/v1/auth/token/refresh/`.
- The JWT payload includes custom claims `role` and `full_name`.

Standard error shapes:

| Status | Meaning |
|---|---|
| `400` | Validation error (DRF field errors) or invalid state transition |
| `401` | Missing/invalid/expired token |
| `403` | Authenticated but role/ownership not permitted |
| `404` | Object not found / not visible to the caller |
| `503` | Kill switch active (all `/api/` traffic halted) |

---

## 4. Permission matrix

| Endpoint area | customer | peyk | vendor | operator | admin | developer |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Auth (register/login) | ✓ | ✓ | — | — | — | — |
| Catalog read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Catalog write | — | — | own | ✓ | ✓ | ✓ |
| Create order | ✓ | — | — | ✓ | ✓ | ✓ |
| View orders | own | assigned | own vendor | all | all | all |
| Update order status | — | own assigned | own | ✓ | ✓ | ✓ |
| Tracking (GPS post) | — | ✓ | — | — | — | — |
| Tracking (GPS read) | own order | own | — | ✓ | ✓ | ✓ |
| Initiate call | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| Payments initiate | ✓ | — | — | — | — | — |
| Wallet (own balance/top-up) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Wallet pay order | ✓ | — | — | — | — | — |
| Operator panel | — | — | — | ✓ | ✓ | ✓ |
| Vendor reports | — | — | own | ✓ | ✓ | ✓ |
| Peyk management | — | — | — | ✓ | ✓ | ✓ |
| User management | — | — | — | — | ✓ | ✓ |
| Kill switch | — | — | — | — | — | header key |

---

## 5. Endpoints

Conventions: **Auth** column lists the role(s)/permission required. `{id}` and
`{order_id}` etc. are UUIDs. Request bodies are JSON.

### 5.1 Auth — `/api/v1/auth/`

| Method | Path | Auth | Body | Response |
|---|---|---|---|---|
| POST | `/auth/register/` | Public | `phone, password, full_name, role(customer\|peyk), city?, vehicle_type?` | `201` user object |
| POST | `/auth/login/` | Public | `phone, password` | `200 {access, refresh}` |
| POST | `/auth/token/refresh/` | Public | `refresh` | `200 {access}` |
| POST | `/auth/logout/` | Authenticated | `refresh` | `205` (blacklists token) |

`vehicle_type` (`car`|`motor`) is **required when `role=peyk`** and creates a `PeykProfile` with an auto-generated `peyk_code` (`YLK-XXXXX`).

**Register request example**
```json
{ "phone": "09120000001", "password": "strongpass1",
  "full_name": "Ali", "role": "peyk", "vehicle_type": "motor" }
```

### 5.2 Accounts / Profiles — `/api/v1/accounts/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/accounts/me/` | Authenticated | Role-aware profile (embeds peyk/vendor/operator profile) |
| PATCH | `/accounts/me/` | Authenticated | Update own editable fields (`email, full_name, city`) |
| GET | `/accounts/peyks/{id}/` | Authenticated | Public peyk profile (by `PeykProfile.id`) |
| GET | `/accounts/users/` | operator+ | List users; `?role=` filter |
| POST | `/accounts/users/` | admin+ | Create vendor/operator user |
| GET | `/accounts/users/{id}/` | operator+ | Retrieve user |
| PATCH | `/accounts/users/{id}/` | admin+ | Update any user (incl. password) |
| DELETE | `/accounts/users/{id}/` | admin+ | Delete user |

### 5.3 Catalog — `/api/v1/catalog/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/catalog/categories/` | Authenticated | All active categories (incl. `is_coming_soon`) |
| GET | `/catalog/categories/{slug}/` | Authenticated | Category detail (lookup by slug) |
| GET | `/catalog/items/` | Authenticated | List + filter + sort (see below) |
| GET | `/catalog/items/{id}/` | Authenticated | Item detail with gallery |
| POST | `/catalog/items/` | vendor / operator | Create item (vendor auto-bound to caller) |
| PATCH | `/catalog/items/{id}/` | owner vendor / operator | Update item |
| DELETE | `/catalog/items/{id}/` | owner vendor / operator | **Soft delete** → `is_available=False` |
| GET | `/catalog/vendors/` | Authenticated | List vendors; `?city=`, `?category=` (slug) |
| GET | `/catalog/vendors/{id}/` | Authenticated | Vendor detail with gallery + active items |

**Item query params** (`GET /catalog/items/`):

| Param | Behaviour |
|---|---|
| `city` | exact match |
| `category` | category slug |
| `vendor` | vendor UUID |
| `available` | `true`/`false` |
| `search` | `icontains` on name + description |
| `ordering=cheapest` | `price` ascending |
| `ordering=priciest` | `price` descending |
| `ordering=top_rated` | `rating` descending |
| `ordering=top_choice` | `rating`, then `rating_count` descending |
| `ordering=closest` | requires `lat` & `lng`; pilot-scale heuristic (rating/price) |

### 5.4 Orders — `/api/v1/orders/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/orders/` | customer / operator | Create order with line items; total computed server-side |
| GET | `/orders/` | Authenticated | Scoped: customer→own, vendor→own vendor, peyk→assigned, operator→all |
| GET | `/orders/{id}/` | Authenticated | Order detail (same scoping) |
| PATCH | `/orders/{id}/status/` | role-validated | Transition status (state machine) |
| GET | `/orders/offline/` | operator+ | List offline (phone-in) orders |
| POST | `/orders/offline/` | operator+ | Create offline order |
| GET/PATCH | `/orders/offline/{id}/` | operator+ | Retrieve/update offline order |

**Create order body**
```json
{
  "vendor": "<vendor-uuid>",
  "delivery_type": "in_city",         // in_city | inter_city
  "payment_method": "cash",           // online | cash | card_in_person | wallet
  "delivery_address": "Street 1",
  "delivery_city": "Tehran",
  "customer_notes": "",
  "items": [ { "item": "<item-uuid>", "quantity": 2 } ]
}
```
All items must belong to the chosen `vendor`. `unit_price` is snapshotted at order
time; `total_amount` = Σ(unit_price × quantity).

**Status transition body**: `{ "status": "accepted" }`.
Invalid transitions return `400 {"detail": "Invalid status transition."}`.

#### Order state machine

```
pending ──► accepted ──► preparing ──► picked_up ──► delivered
   │           │
   └───────────┴────────────────────────────────────► cancelled
```

| From | To | Allowed actor |
|---|---|---|
| pending | accepted | vendor, operator |
| pending | cancelled | customer, vendor, operator |
| accepted | preparing | vendor, operator |
| accepted | cancelled | vendor, operator |
| preparing | picked_up | assigned peyk |
| picked_up | delivered | assigned peyk |

Peyk transitions additionally require the caller to be the peyk assigned to that order.
Every successful transition broadcasts to the order's WebSocket group and pushes an
FCM notification to the customer.

### 5.5 Delivery — `/api/v1/delivery/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/delivery/assignments/` | Authenticated | peyk→own, customer→own orders, operator→all |
| GET | `/delivery/assignments/{id}/` | Authenticated | Assignment detail |
| POST | `/delivery/assignments/` | operator+ | Assign peyk to order; inter-city auto-creates a pending Tipax shipment |
| PATCH | `/delivery/assignments/{id}/` | operator+ | Update assignment (pickup/deliver times) |
| PATCH | `/delivery/tipax/{order_id}/` | operator+ | Enter Tipax code + branch |
| PATCH | `/delivery/tipax/{order_id}/confirm-drop/` | assigned peyk | Confirm package dropped at branch |

**Tipax code body**: `{ "tipax_tracking_code": "TIP-12345678", "tipax_branch_name": "Tehran Central", "peyk": "<uuid?>" }`
(`peyk` required only when creating a shipment that doesn't exist yet).

> `TaxiRide` exists as a model/migration only — **Coming Soon**, no API.

### 5.6 Tracking — `/api/v1/tracking/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/tracking/location/` | peyk | Post GPS update; broadcasts to order's tracking group |
| GET | `/tracking/location/{peyk_id}/latest/` | operator+ | Last known position of a peyk |

**Location post body**: `{ "latitude": 35.6892, "longitude": 51.3890, "order_id": "<uuid|null>" }`

### 5.7 Communications — `/api/v1/communications/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/communications/call/initiate/` | Authenticated (party to order) | Start order call; returns LiveKit token |
| POST | `/communications/call/end/` | Authenticated | End call, compute duration, stop recording |
| POST | `/communications/call/operator-initiate/` | operator+ | Operator→peyk call (bypasses order check) |
| POST | `/communications/devices/register/` | Authenticated | Register/refresh FCM device |
| DELETE | `/communications/devices/{fcm_token}/` | Authenticated | Remove device |

**Call initiate body**: `{ "order_id": "<uuid>", "consent_acknowledged": true }`
(consent must be `true`; recording requires it).

**Call initiate response**
```json
{
  "token": "<livekit-jwt>",
  "channel_name": "order_<uuid>",
  "livekit_url": "ws://localhost:7880",
  "call_log_id": "<uuid>"
}
```

**Operator-initiate body**: `{ "peyk_id": "<uuid>", "consent_acknowledged": true }` →
channel `op_<operator>_<peyk>_<ts>`.

**Device register body**: `{ "fcm_token": "...", "device_type": "android" }` (`android`|`ios`).

### 5.8 Payments — `/api/v1/payments/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/payments/initiate/` | customer | Start Zarinpal payment for an order |
| GET | `/payments/verify/` | Public (Zarinpal callback) | Verify via `?Authority=&Status=OK` |
| GET | `/payments/{order_id}/status/` | Authenticated | Transaction status (customer→own, operator→all) |

**Initiate body**: `{ "order_id": "<uuid>" }` → `{ "payment_url": "https://.../StartPay/<authority>" }`.
Amounts are converted Toman→Rial (×10) for the Zarinpal API. Sandbox vs production is
controlled by `ZARINPAL_SANDBOX`.

### 5.9 AI Services — `/api/v1/ai/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/ai/recommendations/` | Authenticated | `?city=` (default user.city), `?limit=` (≤100); ORM query (Release 1) |
| GET | `/ai/discounts/` | Authenticated | Rule-based suggestions (welcome / win-back) |

Both functions have stable signatures so Release 2 can swap in an LLM call without
changing the views.

### 5.10 Operator Panel — `/api/v1/operator/`

All require operator+.

| Method | Path | Notes |
|---|---|---|
| GET | `/operator/vendors/checklist/` | Vendors in operator's city with their items |
| PATCH | `/operator/items/{item_id}/availability/` | `{ "is_available": false }` |
| PATCH | `/operator/items/{item_id}/price/` | `{ "price": 75000 }` |
| GET | `/operator/peyks/` | Peyks in operator's city |
| PATCH | `/operator/peyks/{id}/availability/` | `{ "is_available": true }` (by `PeykProfile.id`) |
| POST | `/operator/peyks/{id}/call/` | `{ "consent_acknowledged": true }` → operator→peyk call |
| GET/POST | `/operator/offline-orders/` | List/create offline orders |
| PATCH | `/operator/offline-orders/{id}/` | Update offline order |
| PATCH | `/operator/orders/{order_id}/tipax-code/` | Enter Tipax code (same contract as delivery) |

### 5.11 Reports — `/api/v1/reports/`

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/reports/vendor/` | vendor (own) / operator (`?vendor_id=`) | `?period=daily\|weekly\|monthly\|yearly`, `?year=`, `?month=` |
| GET | `/reports/operator/summary/` | operator+ | City-wide totals for today; `?city=` |

Reports are pre-computed by Celery Beat (see §8) for fast reads.

### 5.12 Wallet — `/api/v1/wallet/`

Every user has a single wallet (created on first access). Balances are in Tomans
and can never go negative. All balance changes are recorded as immutable
`WalletTransaction` ledger entries with a `balance_after` snapshot.

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/wallet/` | Authenticated | Own wallet balance (auto-creates the wallet) |
| GET | `/wallet/transactions/` | Authenticated | Paginated ledger of own transactions |
| POST | `/wallet/topup/initiate/` | Authenticated | Start a Zarinpal top-up; returns `payment_url` |
| GET | `/wallet/topup/verify/` | Public (Zarinpal callback) | `?Authority=&Status=OK` → credits wallet |
| POST | `/wallet/pay-order/` | customer | Pay an own `wallet`-method order from balance |

**Top-up initiate body**: `{ "amount": 50000 }` (min 1,000 Tomans) →
`{ "payment_url": "https://.../StartPay/<authority>" }`. Uses
`ZARINPAL_WALLET_CALLBACK_URL`.

**Pay-order body**: `{ "order_id": "<uuid>" }`. Requires the order's
`payment_method == "wallet"` and that it isn't already paid; debits the balance
atomically and sets `order.is_paid = true`. Returns
`{ "detail": "order paid", "balance_after": 60000, "transaction_id": "<uuid>" }`.
Insufficient balance → `400`.

**Refund-on-cancel:** when a `wallet`-paid order transitions to `cancelled`, the
customer's wallet is automatically credited back (a `refund` ledger entry) and
`is_paid` is cleared.

Ledger entry types: `topup`, `order_payment`, `refund`, `adjustment`
(direction `credit` | `debit`).

### 5.13 Developer / Kill Switch — `/api/v1/developer/`

Auth: **header `X-Developer-Key: <DEVELOPER_SECRET_KEY>`** — no JWT, constant-time compared.
These paths are exempt from the kill switch.

| Method | Path | Effect |
|---|---|---|
| POST | `/developer/kill-switch/activate/` | Halt all `/api/` traffic (503) |
| POST | `/developer/kill-switch/deactivate/` | Resume traffic |
| POST | `/developer/kill-switch/status/` | `{ "active": bool }` |

State is stored in Redis key `getir_style_delivery_ui:kill_switch` (fast path) with the
`KILL_SWITCH_ACTIVE` env var as fallback.

---

## 6. WebSocket endpoints

Served by Daphne under `/ws/`. JWT is validated on connect via Channels'
`AuthMiddlewareStack`. Unauthorized connects are closed with code `4001`
(unauthenticated) or `4003` (forbidden). Clients are read-only listeners.

### Order status — `ws/orders/{order_id}/`
Group `order_{order_id}`. Access: the order's customer, the assigned peyk, or any operator.
```json
{ "type": "order.status", "order_id": "<uuid>", "status": "preparing", "updated_at": "ISO8601" }
```

### Live tracking — `ws/tracking/{order_id}/`
Group `tracking_order_{order_id}`. Access: the order's customer, or any operator.
```json
{ "type": "location.update", "peyk_id": "<uuid>",
  "latitude": 35.6892, "longitude": 51.3890, "timestamp": "ISO8601" }
```

---

## 7. Data models (summary)

All primary models use UUID PKs and `created_at`/`updated_at` timestamps.
Money is `BigIntegerField` (Tomans).

| App | Models |
|---|---|
| accounts | `CustomUser` (phone login), `PeykProfile`, `VendorProfile`, `OperatorProfile` |
| catalog | `Category`, `Item`, `ItemGallery`, `VendorGallery` |
| orders | `Order`, `OrderItem`, `OfflineOrder` |
| delivery | `PeykAssignment`, `TipaxShipment`, `TaxiRide` (coming soon) |
| tracking | `GPSSnapshot` |
| communications | `CallLog`, `FCMDevice` |
| payments | `ZarinpalTransaction` |
| reports | `VendorReport` |
| wallet | `Wallet`, `WalletTransaction` (ledger), `WalletTopUp` |
| developer / ai_services / operators / notifications | no models (logic only) |

---

## 8. Celery Beat schedule

| Task | Schedule | Window aggregated |
|---|---|---|
| `apps.reports.tasks.generate_daily_reports` | 00:05 daily | yesterday |
| `apps.reports.tasks.generate_weekly_reports` | 00:10 Mondays | previous Mon–Sun |
| `apps.reports.tasks.generate_monthly_reports` | 00:15 on the 1st | previous month |
| `apps.reports.tasks.generate_yearly_reports` | 00:20 on Jan 1 | previous year |

Each task aggregates **delivered** orders per active vendor into `VendorReport`
(`total_orders`, `total_revenue`, `avg_order_value`).

---

## 9. Environment variables

See `.env.example` for the full list. Key groups:

- **Django**: `SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`
- **Database**: `DATABASE_URL` (omit in dev → SQLite)
- **Redis**: `REDIS_URL`
- **LiveKit**: `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `LIVEKIT_RECORDING_ENABLED`
- **Zarinpal**: `ZARINPAL_MERCHANT_ID`, `ZARINPAL_SANDBOX`, `ZARINPAL_CALLBACK_URL`, `ZARINPAL_WALLET_CALLBACK_URL`
- **Firebase**: `FIREBASE_CREDENTIALS_PATH`
- **Arvan S3**: `ARVAN_ACCESS_KEY`, `ARVAN_SECRET_KEY`, `ARVAN_BUCKET_NAME`, `ARVAN_ENDPOINT_URL`, `ARVAN_REGION`
- **Neshan**: `NESHAN_API_KEY`
- **Developer**: `DEVELOPER_SECRET_KEY`, `KILL_SWITCH_ACTIVE`, `DEVELOPER_PHONE`, `DEVELOPER_PASSWORD`
- **Dev toggles**: `KILL_SWITCH_USE_REDIS`, `USE_REDIS_CHANNELS`, `CELERY_TASK_ALWAYS_EAGER`

---

## 10. Implementation notes / deviations from `DESIGN.md`

- LiveKit package is **`livekit-api`** (provides `from livekit import api`); token uses `with_grants`.
- Zarinpal amounts are converted Toman→Rial (×10) before the API call.
- Development settings fall back to SQLite, in-memory channels, eager Celery, and a
  disabled kill-switch Redis path so the project runs with zero external services.
- Inter-city peyk assignments auto-create a pending `TipaxShipment`.
- Heavy optional deps (livekit, firebase-admin, channels-redis, psycopg2) are imported
  lazily; the API works in dev without them installed.

*Generated for GetirStyleDeliveryUi Backend — keep in sync with the code when endpoints change.*
