# GETIR_STYLE_DELIVERY_UI — Complete System Overview

![GetirStyleDeliveryUi Logo](logo.jpg)

## Executive Summary

**GetirStyleDeliveryUi** is a comprehensive, multi-role on-demand delivery platform designed for the Iranian market. It serves multiple user personas through three specialized mobile applications and a robust Django REST API backend, all built on proven, production-ready technologies. The platform supports food delivery, grocery shopping, pharmacy services, and is architected to scale beyond its pilot phase.

---

## 1. System Architecture Overview

### Multi-App Ecosystem

```
┌─────────────────────────────────────────────────────────────────┐
│                         GETIR_STYLE_DELIVERY_UI PLATFORM                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │  GETIR_STYLE_DELIVERY_UI MAIN APP  │  │  GETIR_STYLE_DELIVERY_UI OPERATOR  │  │ GETIR_STYLE_DELIVERY_UI PEYK   │  │
│  │   (Customer)     │  │   (Management)   │  │  (Delivery)  │  │
│  │  - Browse Items  │  │  - Vendor Mgmt   │  │  - Get Orders│  │
│  │  - Place Orders  │  │  - Peyk Board    │  │  - Navigate  │  │
│  │  - Track Orders  │  │  - Offline Orders│  │  - Updates   │  │
│  │  - Pay Online    │  │  - Analytics     │  │  - Support   │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬──────┘  │
│           │                     │                     │         │
│           └─────────────────────┼─────────────────────┘         │
│                                 │                               │
│                    ┌────────────▼─────────────┐                 │
│                    │   DJANGO REST API v1     │                 │
│                    │  (Port 8000, ASGI)       │                 │
│                    └────────────┬─────────────┘                 │
│                                 │                                │
│        ┌────────────┬───────────┼───────────┬─────────────┐     │
│        │            │           │           │             │     │
│   ┌────▼─┐   ┌─────▼──┐  ┌────▼───┐  ┌───▼────┐  ┌──────▼─┐   │
│   │  DB  │   │ Redis  │  │LiveKit │  │ Arvan  │  │Firebase│   │
│   │ PG16 │   │Cache   │  │ VOIP   │  │  S3    │  │  FCM   │   │
│   └──────┘   └────────┘  └────────┘  └────────┘  └────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Applications

### 2.1 GetirStyleDeliveryUi Main App (`frontend/getir_style_delivery_ui_v2`)

**Purpose**: Customer-facing delivery ordering platform  
**Platform**: Flutter (iOS, Android, Web)  
**Language**: Dart 3.9+

#### Key Features
- **Authentication**: Phone-based login with OTP verification
- **Browse & Search**: 
  - 6 primary categories (Food, Drink, Dessert, Medic, Groceries, Taxi*)
  - Real-time search with filters (price, rating, distance, availability)
  - Vendor profiles with ratings and galleries
  - Item galleries and detailed descriptions
  
- **Shopping & Cart**:
  - Add/remove items with quantity management
  - Cart persistence across sessions
  - Promo codes and discount display
  - Real-time price calculations

- **Checkout & Payment**:
  - Address picker with Neshan maps integration
  - Multiple payment methods (Online/Zarinpal, Cash, Card in-person)
  - Order confirmation with receipt

- **Order Tracking**:
  - Real-time order status updates via WebSocket
  - Live GPS tracking of delivery driver (Peyk)
  - Estimated delivery time
  - Order history and reordering

- **Communication**:
  - Voice calls via LiveKit integration (customer ↔ peyk/vendor)
  - Call recording consent management
  - Call history logs
  - Emergency support hotline

- **User Profile**:
  - Edit personal information
  - Saved addresses
  - Payment methods
  - Order history
  - Wallet/balance (future feature)
  - Settings and preferences

- **AI Assistant** (Beta):
  - Personalized recommendations based on order history
  - Smart discount suggestions
  - Category-specific recommendations

#### Technology Stack
```
UI Framework:       Flutter + Material Design
State Management:   Provider (GetX alternative available)
HTTP Client:        Dio 5.7
Local Storage:      SharedPreferences
Secure Storage:     Flutter Secure Storage
Maps:              Flutter Map + Neshan API
Real-time:         WebSocket (web_socket_channel)
VOIP:              LiveKit Client SDK
Permissions:       Permission Handler
Geolocation:       Geolocator
UI Components:     Shadcn UI, Curved Navigation Bar, Custom Widgets
```

#### App Structure
```
getir_style_delivery_ui_v2/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # Material app config
│   ├── core/
│   │   ├── config/                  # App configuration
│   │   ├── theme/                   # GetirStyleDeliveryUi design system & colors
│   │   ├── network/                 # API client setup
│   │   ├── providers/               # Global state providers
│   │   ├── utils/                   # Helpers & formatters
│   │   ├── localization/            # i18n support (fa, en, ar, tr)
│   │   └── location/                # Device location services
│   ├── data/
│   │   ├── models/                  # Data models (User, Order, Item, etc.)
│   │   └── repositories/            # API communication layer
│   ├── features/
│   │   ├── auth/                    # Login & OTP screens
│   │   ├── home/                    # Home & category browsing
│   │   ├── search/                  # Search & filtering
│   │   ├── cart/                    # Shopping cart
│   │   ├── checkout/                # Payment & delivery info
│   │   ├── dine_in/                 # Restaurant dining tables (premium)
│   │   ├── address/                 # Address management
│   │   ├── profile/                 # User profile pages
│   │   ├── promotions/              # Promo display
│   │   ├── ai_chat/                 # AI recommendations
│   │   └── debug/                   # Developer tools
│   ├── widgets/                     # Reusable UI components
│   ├── navigation/                  # Router & navigation
│   └── l10n/                        # Localization files
├── assets/
│   ├── logo/                        # App branding
│   └── placeholders/                # UI placeholders
└── pubspec.yaml
```

---

### 2.2 GetirStyleDeliveryUi Operator App (`frontend/getir_style_delivery_ui_ops`)

**Purpose**: Operator/manager console for daily operations  
**Platform**: Flutter (iOS, Android, Web)  
**Language**: Dart 3.10+

#### Key Features
- **Vendor Management**:
  - Real-time vendor checklist (all vendors in city)
  - Toggle vendor availability
  - Update item prices in bulk
  - Monitor vendor ratings and performance

- **Peyk Board**:
  - Display available delivery drivers with status
  - Vehicle type indicator (car, motorcycle)
  - Real-time availability toggle
  - Peyk rating and performance metrics
  - Quick call button (integrated with LiveKit)

- **Order Management**:
  - View pending, accepted, preparing, picked up orders
  - Assign Peyk to orders
  - Update order status
  - Inter-city Tipax shipping handling (manual tracking code entry)
  - Offline order creation for phone-in customers

- **Analytics & Reports**:
  - Daily order count and revenue
  - Vendor performance rankings
  - Peyk productivity metrics
  - City-wide KPIs

#### Technology Stack
```
UI Framework:       Flutter + Material Design
State Management:   Provider
HTTP Client:        Dio 5.7
Real-time:         WebSocket
Fonts:             Google Fonts, Persian Fonts
```

#### App Structure
```
getir_style_delivery_ui_ops/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── theme/
│   │   ├── network/
│   │   └── providers/
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   ├── features/
│   │   ├── auth/
│   │   ├── vendors/
│   │   ├── peyks/
│   │   ├── orders/
│   │   ├── analytics/
│   │   └── profile/
│   ├── widgets/
│   └── navigation/
└── pubspec.yaml
```

---

### 2.3 GetirStyleDeliveryUi Peyk App (`frontend/getir_style_delivery_ui_peyk`)

**Purpose**: Delivery driver companion application  
**Platform**: Flutter (iOS, Android)  
**Language**: Dart 3.9+

#### Key Features
- **Authentication**:
  - Phone + password login (OTP optional)
  - Automatic token refresh
  - Logout & re-login flow

- **Dashboard**:
  - Active assignments (orders to deliver)
  - Completion rate and today's stats
  - Earnings summary

- **Order Delivery**:
  - Real-time order updates via WebSocket
  - Order details (customer, address, items)
  - Navigate to pickup location (map)
  - Navigate to delivery location
  - Confirm pickup
  - Confirm delivery
  - Take customer signature (future)

- **GPS Tracking**:
  - Background location tracking (every 10-30 seconds)
  - Send GPS to backend for live tracking visibility
  - Accuracy & battery optimization

- **Communication**:
  - Receive incoming calls from operators/vendors/customers
  - Accept/reject calls
  - Voice call via LiveKit
  - Call history

- **Performance**:
  - Daily earnings display
  - Order completion rate
  - Customer ratings
  - Complaint tracking

#### Technology Stack
```
UI Framework:       Flutter + Material Design
State Management:   Provider
HTTP Client:        Dio 5.7
Real-time:         WebSocket
Geolocation:       Geolocator (background support)
VOIP:              LiveKit Client SDK
Permissions:       Permission Handler
```

#### App Structure
```
getir_style_delivery_ui_peyk/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── theme/
│   │   ├── network/
│   │   └── providers/
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── orders/
│   │   ├── tracking/
│   │   ├── calls/
│   │   ├── profile/
│   │   └── earnings/
│   ├── widgets/
│   └── navigation/
└── pubspec.yaml
```

---

### 2.4 GetirStyleDeliveryUi Backend (`getir_style_delivery_ui_backend`)

**Purpose**: RESTful API server and real-time hub  
**Platform**: Django 5.x + Daphne ASGI  
**Language**: Python 3.12

#### Core Responsibilities

1. **User Management**
   - Phone-based authentication (JWT tokens)
   - Role-based access control (customer, peyk, vendor, operator, admin, developer)
   - User profiles (customer, peyk profile, vendor profile, operator profile)
   - Password hashing and token refresh cycles

2. **Catalog Management**
   - Category CRUD with sorting and coming-soon flags
   - Item management (create, read, update, soft delete)
   - Item galleries and vendor galleries
   - Filtering and searching across categories, cities, vendors

3. **Order Management**
   - Order state machine (pending → accepted → preparing → picked_up → delivered)
   - Order validation and transition enforcement
   - Offline orders for phone-in customers
   - Order item snapshots for price history

4. **Real-time Communication**
   - WebSocket consumers for order status broadcasts
   - Live GPS tracking stream
   - Order assignment notifications

5. **Payment Processing**
   - Zarinpal online payment gateway integration
   - Sandbox mode for development, production mode for live payments
   - Transaction status tracking and verification

6. **Delivery & Tracking**
   - Peyk assignment to orders
   - GPS snapshot storage and broadcasting
   - Inter-city Tipax shipment handling
   - Delivery confirmation flow

7. **VOIP & Communications**
   - LiveKit integration for voice calls
   - Call recording via Egress to Arvan S3
   - FCM device registration for push notifications
   - Call log storage with timestamps

8. **Notifications**
   - Firebase Cloud Messaging (FCM) integration
   - Push notifications for order updates
   - Incoming call notifications
   - Custom notification routing

9. **Reports & Analytics**
   - Pre-computed daily/weekly/monthly/yearly reports
   - Vendor revenue aggregation
   - Celery Beat scheduled tasks for report generation

10. **AI Services**
    - Recommendation engine (Release 1: ORM-based, Release 2: LLM-based)
    - Discount suggestions
    - Personalized promotions

#### Technology Stack
```
Framework:          Django 5.x + DRF 3.15+
ASGI Server:        Daphne 4.x
Real-time:          Django Channels 4.x
Database:           PostgreSQL 16
Cache/Sessions:     Redis 7.x
Task Queue:         Celery 5.x
Scheduler:          Celery Beat
VOIP:               LiveKit Server SDK
Payments:           Zarinpal API
Maps:               Neshan API
Push Notifications: Firebase Admin SDK
Storage:            Arvan Cloud S3
Auth:               djangorestframework-simplejwt
```

#### API Structure
```
getir_style_delivery_ui_backend/
├── config/
│   ├── settings/
│   │   ├── base.py          # Core Django settings
│   │   ├── development.py   # Dev overrides
│   │   └── production.py    # Prod overrides
│   ├── urls.py              # Root URL routing
│   ├── asgi.py              # Channels routing
│   ├── wsgi.py              # WSGI fallback
│   └── celery.py            # Celery config
├── apps/
│   ├── accounts/            # Users & auth
│   ├── catalog/             # Categories & items
│   ├── orders/              # Order state machine
│   ├── delivery/            # Peyk & assignments
│   ├── tracking/            # GPS & location
│   ├── payments/            # Zarinpal integration
│   ├── communications/      # LiveKit & calls
│   ├── notifications/       # FCM push
│   ├── reports/             # Analytics & reports
│   ├── ai_services/         # Recommendations
│   ├── operators/           # Operator panel views
│   └── developer/           # Admin tools & kill switch
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
├── docker-compose.yml       # Local stack
├── Dockerfile               # Container image
├── manage.py
└── DESIGN.md                # Authoritative spec
```

#### API Endpoints (High-level)
```
Authentication:
  POST   /api/v1/auth/register/
  POST   /api/v1/auth/login/
  POST   /api/v1/auth/token/refresh/

Accounts:
  GET    /api/v1/accounts/me/
  PATCH  /api/v1/accounts/me/
  GET    /api/v1/accounts/peyks/{id}/

Catalog:
  GET    /api/v1/catalog/categories/
  GET    /api/v1/catalog/items/
  POST   /api/v1/catalog/items/

Orders:
  POST   /api/v1/orders/
  GET    /api/v1/orders/
  GET    /api/v1/orders/{id}/
  PATCH  /api/v1/orders/{id}/status/

Delivery:
  GET    /api/v1/delivery/assignments/
  POST   /api/v1/delivery/assignments/
  PATCH  /api/v1/delivery/tipax/{order_id}/

Tracking:
  POST   /api/v1/tracking/location/
  GET    /api/v1/tracking/location/{peyk_id}/latest/

Communications:
  POST   /api/v1/communications/call/initiate/
  POST   /api/v1/communications/call/end/
  POST   /api/v1/communications/devices/register/

Payments:
  POST   /api/v1/payments/initiate/
  GET    /api/v1/payments/verify/
  GET    /api/v1/payments/{order_id}/status/

Operator:
  GET    /api/v1/operator/vendors/checklist/
  GET    /api/v1/operator/peyks/
  GET    /api/v1/operator/offline-orders/
  PATCH  /api/v1/operator/orders/{id}/tipax-code/

Reports:
  GET    /api/v1/reports/vendor/
  GET    /api/v1/reports/operator/summary/

AI:
  GET    /api/v1/ai/recommendations/
  GET    /api/v1/ai/discounts/

WebSocket:
  ws://   /ws/orders/{order_id}/
  ws://   /ws/tracking/{order_id}/
```

---

## 3. Key Features by User Role

### 3.1 Customer

| Feature | Description | Status |
|---------|-------------|--------|
| Browse Categories | View 6+ categories with icons | ✅ Active |
| Search & Filter | Full-text search, price range, distance | ✅ Active |
| Add to Cart | Manage item quantities | ✅ Active |
| Checkout | Address selection, payment method | ✅ Active |
| Track Order | Real-time status + GPS tracking | ✅ Active |
| Pay Online | Zarinpal integration (sandbox/prod) | ✅ Active |
| Voice Call | Call vendor/peyk via LiveKit | ✅ Active |
| User Profile | Edit name, avatar, saved addresses | ✅ Active |
| Order History | Previous orders, reorder button | ✅ Active |
| AI Recommendations | Personalized suggestions | 🧪 Beta |
| Wallet | Future payment method | ⏳ Coming |
| Loyalty Program | Future rewards/points | ⏳ Coming |

### 3.2 Delivery Driver (Peyk)

| Feature | Description | Status |
|---------|-------------|--------|
| Accept Orders | Real-time available assignments | ✅ Active |
| Navigate | Map routing to pickup & delivery | ✅ Active |
| GPS Tracking | Background location broadcast | ✅ Active |
| Confirm Pickup | Mark order as picked up | ✅ Active |
| Confirm Delivery | Mark order as delivered | ✅ Active |
| Receive Calls | Incoming calls from operators/customers | ✅ Active |
| Voice Call | Answer calls via LiveKit | ✅ Active |
| Earnings | Daily & lifetime totals | ✅ Active |
| Performance | Rating, complaint tracking | ✅ Active |
| Profile | Vehicle info, availability toggle | ✅ Active |
| Taxi Rides | Future: Request-based ride dispatch | ⏳ Coming |

### 3.3 Operator (Manager)

| Feature | Description | Status |
|---------|-------------|--------|
| Vendor Checklist | Monitor all vendors in city | ✅ Active |
| Toggle Vendor | Pause/enable vendors | ✅ Active |
| Update Prices | Bulk item price updates | ✅ Active |
| Peyk Board | View available drivers | ✅ Active |
| Assign Peyk | Manually assign to orders | ✅ Active |
| Call Peyk | Direct voice call to driver | ✅ Active |
| Order Management | Update order status | ✅ Active |
| Offline Orders | Phone-in customer orders | ✅ Active |
| Tipax Tracking | Inter-city shipment codes | ✅ Active |
| Analytics | Daily KPIs & vendor reports | ✅ Active |
| Vendor Reports | Revenue & performance data | ✅ Active |

### 3.4 Vendor (Restaurant/Shop)

| Feature | Description | Status |
|---------|-------------|--------|
| Item CRUD | Create/edit menu items | ✅ Active |
| Gallery | Upload item & venue photos | ✅ Active |
| Availability | Toggle item availability | ✅ Active |
| Pricing | Update prices in real-time | ✅ Active |
| Order Notifications | FCM alerts for new orders | ✅ Active |
| Accept/Reject | Respond to orders | ✅ Active |
| Preparation Status | Mark as preparing | ✅ Active |
| Revenue Reports | Pre-computed daily/weekly/monthly | ✅ Active |
| Ratings | Track customer feedback | ✅ Active |
| Support | Contact operator/admin | ✅ Active |

### 3.5 Admin/Developer

| Feature | Description | Status |
|---------|-------------|--------|
| User Management | Create/edit all user roles | ✅ Active |
| Category Management | Add/edit categories | ✅ Active |
| System Monitoring | API health, queue status | ✅ Active |
| Kill Switch | Emergency API shutdown | ✅ Active |
| Reports | All system reports | ✅ Active |
| Logs | API request logs | ✅ Active |
| Settings | Global configuration | ✅ Active |

---

## 4. Order Lifecycle

```
┌────────────────────────────────────────────────────────────────┐
│                     ORDER STATE MACHINE                        │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CUSTOMER PLACES ORDER                                         │
│           │                                                     │
│           ▼                                                     │
│       [PENDING] ◄─────── Customer can cancel                  │
│           │                                                     │
│     (Vendor/Operator accepts)                                  │
│           ▼                                                     │
│      [ACCEPTED] ◄─────── Vendor/Operator can cancel            │
│           │                                                     │
│     (Vendor preparing)                                         │
│           ▼                                                     │
│      [PREPARING]                                               │
│           │                                                     │
│     (Peyk picks up from vendor)                                │
│           ▼                                                     │
│      [PICKED UP]                                               │
│           │                                                     │
│     (Peyk arrives at customer)                                 │
│           ▼                                                     │
│      [DELIVERED] ✓ COMPLETE                                    │
│                                                                  │
│  OR ANY TIME → [CANCELLED]                                     │
│                                                                  │
└────────────────────────────────────────────────────────────────┘
```

**Key Points**:
- Server enforces all transitions via state machine validation
- Each transition requires specific role permissions
- WebSocket broadcasts status changes to relevant parties
- GPS tracking active from pickup → delivery
- Payment finalized after delivery confirmation

---

## 5. Data Models Overview

### Core Entities

```
CustomUser
├── phone (unique, login identifier)
├── full_name
├── role (customer|peyk|vendor|operator|admin|developer)
├── city
├── created_at / updated_at

PeykProfile (OneToOne with CustomUser)
├── peyk_code (YLK-XXXXX, auto-generated)
├── vehicle_type (car|motor)
├── is_verified
├── is_available
├── rating / rating_count
├── complaint_count
├── photo

VendorProfile (OneToOne with CustomUser)
├── business_name
├── category (FK)
├── is_active
├── rating / rating_count
├── address / city / phone
├── logo
├── description

Category
├── name
├── slug (unique)
├── icon_url
├── display_order
├── is_coming_soon (Taxi = true)
├── is_active

Item
├── vendor (FK)
├── category (FK)
├── name / description
├── price (Tomans, BigInt)
├── is_available
├── rating / rating_count
├── city

Order
├── customer (FK)
├── vendor (FK)
├── status (state machine)
├── delivery_type (in_city|inter_city)
├── payment_method (online|cash|card_in_person)
├── total_amount (Tomans)
├── delivery_address / delivery_city
├── customer_notes
├── created_at / updated_at

OrderItem
├── order (FK)
├── item (FK)
├── quantity
├── unit_price (snapshot)

PeykAssignment
├── order (OneToOne)
├── peyk (FK)
├── assigned_at / picked_up_at / delivered_at

GPSSnapshot
├── peyk (FK)
├── order (FK, nullable)
├── latitude / longitude
├── timestamp

CallLog
├── order (FK, nullable)
├── caller / receiver (FK)
├── channel_name
├── livekit_room_name
├── egress_id (recording)
├── started_at / ended_at / duration_seconds
├── consent_acknowledged

FCMDevice
├── user (FK)
├── fcm_token (unique)
├── device_type (android|ios)
├── is_active

ZarinpalTransaction
├── order (FK)
├── amount (Tomans)
├── authority / ref_id
├── status (pending|verified|failed)

VendorReport
├── vendor (FK)
├── period (daily|weekly|monthly|yearly)
├── period_start / period_end
├── total_orders / total_revenue / avg_order_value
```

---

## 6. Integration Points

### External Services

| Service | Purpose | Endpoint | Status |
|---------|---------|----------|--------|
| **Zarinpal** | Online payments | `zarinpal.com/pg/v4/payment/*` | ✅ Integrated |
| **LiveKit** | VOIP & recording | `localhost:7880` (dev) | ✅ Integrated |
| **Firebase Admin** | Push notifications | FCM API | ✅ Integrated |
| **Arvan Cloud** | Media & recordings | S3-compatible endpoint | ✅ Integrated |
| **Neshan** | Maps & geocoding | `api.neshan.org` | ✅ Integrated |
| **PostgreSQL** | Data persistence | Localhost:5432 | ✅ Integrated |
| **Redis** | Cache & sessions | Localhost:6379 | ✅ Integrated |

---

## 7. Security & Compliance

### Authentication
- JWT tokens (djangorestframework-simplejwt)
- 2-hour access token lifetime
- 30-day refresh token lifetime
- Token blacklist on logout
- Phone-based OTP verification

### Authorization
- Role-based access control (RBAC)
- Permission classes on every viewset
- Explicit `IsCustomer`, `IsPeyk`, `IsVendor`, `IsOperator`, `IsAdmin`, `IsDeveloper`
- No reliance on defaults

### Data Protection
- HTTPS in production
- PostgreSQL encryption at rest
- Secure storage of FCM & Firebase credentials
- PII handling compliant with Iranian privacy standards
- Call recording with explicit consent tracking

### API Security
- CORS properly configured per environment
- CSRF protection on state-changing endpoints
- Rate limiting (via middleware/app)
- Input validation at system boundaries
- SQL injection prevention (ORM only)
- XSS prevention (REST API, no server rendering)

---

## 8. DevOps & Deployment

### Local Development
```bash
# Stack setup
docker-compose up -d

# Services
- PostgreSQL:  localhost:5432
- Redis:       localhost:6379
- Django:      localhost:8000
- LiveKit:     localhost:7880 (--dev mode)
- Flutter:     runs on phone/emulator
```

### Containerization
```dockerfile
# Backend Dockerfile
FROM python:3.12-slim
RUN apt-get update && apt-get install -y postgresql-client
COPY requirements/production.txt .
RUN pip install -r production.txt
COPY getir_style_delivery_ui_backend/ /app
EXPOSE 8000
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "config.asgi:application"]
```

### Production Deployment
- Daphne ASGI server (auto-reloading in dev, production-grade in prod)
- Gunicorn fallback (optional, for non-WebSocket endpoints)
- Celery workers for async tasks
- Celery Beat for scheduled reports
- Nginx reverse proxy
- SSL/TLS certificates

---

## 9. Monitoring & Analytics

### Key Metrics
- **Daily Active Users**: Customers + Peyks + Operators
- **Order Volume**: Total orders, cancellations, delivery rate
- **Revenue**: Total platform revenue, vendor breakdown
- **VOIP Quality**: Call duration, connection issues, recording success
- **Delivery Time**: Average time from order → delivery
- **Driver Performance**: Rating, on-time delivery %, complaints
- **System Health**: API response times, error rates, uptime

### Reporting
- **Vendor Reports**: Daily/weekly/monthly revenue (pre-computed by Celery Beat)
- **Operator Dashboard**: City-wide KPIs
- **Admin Console**: System-wide analytics

---

## 10. Future Roadmap

### Phase 2 (Taxi Service)
- Enable GetirStyleDeliveryUi Taxi category
- Pickup location selection
- Destination address input
- Estimated fare calculation
- Taxi driver assignment

### Phase 3 (Premium Features)
- Dine-in restaurant reservations
- Table selection at venues
- Restaurant panorama tours
- Loyalty program
- Gift cards

### Phase 4 (Platform Extensions)
- Wallet & prepaid balance
- Subscription plans
- Vendor analytics dashboard
- Driver app incentive programs
- Real-time surge pricing

### Phase 5 (AI & Intelligence)
- LLM-based recommendations (Claude/GPT)
- Demand forecasting
- Dynamic pricing
- Fraud detection

---

## 11. Troubleshooting & Support

### Common Issues

**Q: Why is my order not updating?**  
A: Check WebSocket connection. If offline, order fetches on reconnect.

**Q: Payment shows "pending" — is it verified?**  
A: Wait 30 seconds for Zarinpal callback. Check /api/v1/payments/{order_id}/status/.

**Q: LiveKit voice call won't connect**  
A: Verify LIVEKIT_URL env var matches server address. Check firewall ports 7880-7882.

**Q: GPS tracking not working**  
A: Peyk app must have location permission. Check /api/v1/tracking/location/ POST succeeds.

**Q: Peyk not visible on Operator board**  
A: Peyk must set `is_available=true`. Verify user has `peyk` role.

---

## 12. Contact & Resources

- **Project Root**: `D:\Projects\Programming\Flutter\B-Project\v4`
- **Backend Spec**: [DESIGN.md](../getir_style_delivery_ui_backend/DESIGN.md)
- **Main App**: `frontend/getir_style_delivery_ui_v2`
- **Operator App**: `frontend/getir_style_delivery_ui_ops`
- **Peyk App**: `frontend/getir_style_delivery_ui_peyk`
- **Backend**: `getir_style_delivery_ui_backend`

---

**Version**: 1.0  
**Last Updated**: July 2025  
**Status**: Production Ready (Pilot Scale)  
**Target Users**: < 500 concurrent users  
**Primary Language**: Persian (fa)  
**Supported Markets**: Iran (Tehran + Regional)

