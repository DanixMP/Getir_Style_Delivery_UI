# GETIR_STYLE_DELIVERY_UI — Technical Architecture & Design

![GetirStyleDeliveryUi Logo](logo.jpg)

## Table of Contents
1. [System Design](#1-system-design)
2. [API Architecture](#2-api-architecture)
3. [Database Design](#3-database-design)
4. [Communication Protocols](#4-communication-protocols)
5. [Real-time Systems](#5-real-time-systems)
6. [Payment Integration](#6-payment-integration)
7. [VOIP & Recording](#7-voip--recording)
8. [App Connectivity](#8-app-connectivity)
9. [Deployment Architecture](#9-deployment-architecture)
10. [Performance & Scalability](#10-performance--scalability)
11. [Error Handling](#11-error-handling)
12. [Security Implementation](#12-security-implementation)

---

## 1. System Design

### 1.1 Layered Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (Flutter Apps: GetirStyleDeliveryUi v2, GetirStyleDeliveryUi Ops, GetirStyleDeliveryUi Peyk)            │
└────────────┬─────────────────────────────────────────────────┘
             │
             │ HTTP (REST) + WebSocket
             │
┌────────────▼─────────────────────────────────────────────────┐
│                   API LAYER (Django DRF)                     │
│  ├─ ViewSets (Accounts, Catalog, Orders, etc.)             │
│  ├─ Serializers (Input/Output validation)                  │
│  ├─ Permissions (RBAC checks)                              │
│  └─ Routing (REST endpoints + WebSocket consumers)         │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│                 BUSINESS LOGIC LAYER                         │
│  ├─ Services (PaymentService, TrackingService, etc.)      │
│  ├─ State Machines (Order transitions)                     │
│  ├─ Validators (Complex rules)                             │
│  ├─ Adapters (LiveKitAdapter, ZarinpalAdapter)            │
│  └─ Tasks (Celery async operations)                        │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│                  DATA ACCESS LAYER (ORM)                     │
│  ├─ Models (Django ORM)                                    │
│  ├─ Querysets (Optimized with select_related)             │
│  ├─ Migrations (Version-controlled schema)                 │
│  └─ Indexes (Database optimization)                        │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│                  PERSISTENCE LAYER                           │
│  ├─ PostgreSQL (Primary data)                              │
│  ├─ Redis (Cache + Sessions)                               │
│  ├─ Arvan S3 (Media + Recordings)                          │
│  └─ Firebase (Credentials for FCM)                         │
└──────────────────────────────────────────────────────────────┘
```

### 1.2 Component Interaction Diagram

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  GetirStyleDeliveryUi v2   │         │  GetirStyleDeliveryUi Ops  │         │GetirStyleDeliveryUi Peyk  │
│  (Customer) │         │ (Operator)  │         │ (Driver)   │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │ HTTP + WebSocket      │ HTTP + WebSocket      │ HTTP + WebSocket
       │                       │                       │
       └───────────────────────┼───────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Django DRF API    │
                    │  (Port 8000)       │
                    └──────────┬─────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
    ┌────────┐           ┌──────────┐         ┌──────────────┐
    │Database│           │  Redis   │         │  LiveKit     │
    │(PG16)  │           │  Cache   │         │  Server      │
    │        │           │          │         │  (VOIP)      │
    └────────┘           └──────────┘         └──────────────┘
        │
        │ (Celery Tasks)
        │
    ┌────────────────────┐
    │ Celery Worker +    │
    │ Celery Beat        │
    │ (Async & Reports)  │
    └────────────────────┘
        │
        │ (Firebase Admin, Zarinpal, Neshan)
        │
    ┌───────────────────────────┐
    │ External Services         │
    └───────────────────────────┘
```

---

## 2. API Architecture

### 2.1 REST API Structure

**Base URL**: `https://api.getir_style_delivery_ui.ir/api/v1/` (production)  
**Dev URL**: `http://localhost:8000/api/v1/` (local)

#### Resource Endpoints

```
Authentication & Accounts
├── POST   /auth/register/              Create customer/peyk account
├── POST   /auth/login/                 Phone + password → JWT tokens
├── POST   /auth/token/refresh/         Extend access token
├── POST   /auth/logout/                Blacklist refresh token
├── GET    /accounts/me/                Current user profile (role-aware)
├── PATCH  /accounts/me/                Update own profile fields
└── GET    /accounts/peyks/{id}/        Public peyk profile

Catalog Management
├── GET    /catalog/categories/         List all categories (includes coming_soon)
├── GET    /catalog/categories/{slug}/  Category detail with items
├── GET    /catalog/items/              List items with filters
│   └─ Query params:
│       ├─ city={name}
│       ├─ category={slug}
│       ├─ vendor={id}
│       ├─ available=true
│       ├─ ordering=cheapest|priciest|top_rated|top_choice|closest
│       ├─ search={query}
│       └─ lat={},lng={} (for closest)
├── GET    /catalog/items/{id}/         Item detail with gallery
├── POST   /catalog/items/              Create item (IsVendor)
├── PATCH  /catalog/items/{id}/         Update item (owner/operator)
├── DELETE /catalog/items/{id}/         Soft delete (is_available=False)
├── GET    /catalog/vendors/            List vendors with filters
└── GET    /catalog/vendors/{id}/       Vendor detail with gallery + items

Order Management
├── POST   /orders/                     Create new order (IsCustomer)
├── GET    /orders/                     List own orders (role-aware)
├── GET    /orders/{id}/                Order detail
├── PATCH  /orders/{id}/status/         Update order status (state machine)
├── GET    /orders/offline/             List offline orders (IsOperator)
├── POST   /orders/offline/             Create offline order (IsOperator)
└── PATCH  /orders/offline/{id}/        Update offline order (IsOperator)

Delivery & Tracking
├── GET    /delivery/assignments/       Peyk views own assignments
├── GET    /delivery/assignments/{id}/  Assignment detail
├── POST   /delivery/assignments/       Assign peyk (IsOperator)
├── PATCH  /delivery/assignments/{id}/  Update assignment (IsOperator)
├── PATCH  /delivery/tipax/{order_id}/  Enter tipax code (IsOperator)
└── PATCH  /delivery/tipax/{order_id}/confirm-drop/ Peyk confirms drop

GPS Tracking
├── POST   /tracking/location/          Peyk posts GPS update
└── GET    /tracking/location/{peyk_id}/latest/ Last known position (IsOperator)

Communications & VOIP
├── POST   /communications/call/initiate/ Create call (order-based)
├── POST   /communications/call/end/    End call & finalize log
├── POST   /communications/call/operator-initiate/ Operator calls peyk
├── POST   /communications/devices/register/ Register FCM token
└── DELETE /communications/devices/{token}/ Unregister FCM token

Payments
├── POST   /payments/initiate/          Start Zarinpal payment
├── GET    /payments/verify/            Zarinpal callback verification
└── GET    /payments/{order_id}/status/ Check payment status

Reports & Analytics
├── GET    /reports/vendor/             Vendor revenue reports (role-aware)
└── GET    /reports/operator/summary/   City-wide KPIs (IsOperator)

Operator Panel
├── GET    /operator/vendors/checklist/ All vendors + items in city
├── PATCH  /operator/items/{id}/availability/ Toggle item availability
├── PATCH  /operator/items/{id}/price/  Update item price
├── GET    /operator/peyks/             Peyk board in city
├── PATCH  /operator/peyks/{id}/availability/ Toggle peyk availability
├── POST   /operator/peyks/{id}/call/   Call peyk (proxy)
└── PATCH  /operator/orders/{id}/tipax-code/ Enter tipax code

AI & Recommendations
├── GET    /ai/recommendations/         Personalized item suggestions
└── GET    /ai/discounts/               Discount suggestions

Developer Tools
├── POST   /developer/kill-switch/activate/   Emergency API shutdown
├── POST   /developer/kill-switch/deactivate/ Re-enable API
└── GET    /developer/kill-switch/status/     Check kill-switch state
```

### 2.2 Request/Response Format

#### Standard REST Response
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "vendor": {
    "id": "vendor-id",
    "business_name": "Restaurant Name"
  },
  "status": "pending",
  "total_amount": 450000,
  "delivery_address": "123 Street, Tehran",
  "created_at": "2025-07-10T14:30:00Z",
  "updated_at": "2025-07-10T14:30:00Z"
}
```

#### Paginated List Response
```json
{
  "count": 250,
  "next": "https://api.getir_style_delivery_ui.ir/api/v1/orders/?page=2",
  "previous": null,
  "results": [
    { /* item */ },
    { /* item */ }
  ]
}
```

#### Error Response
```json
{
  "detail": "Invalid status transition.",
  "status_code": 400,
  "error_code": "INVALID_TRANSITION"
}
```

### 2.3 Authentication Flow

```
1. REGISTRATION
   POST /auth/register/
   Body: {
     "phone": "09123456789",
     "password": "securepass123",
     "full_name": "John Doe",
     "role": "customer"
   }
   Response: { "detail": "Account created. Please login." }

2. LOGIN
   POST /auth/login/
   Body: {
     "phone": "09123456789",
     "password": "securepass123"
   }
   Response: {
     "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
     "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
     "user": { "id": "uuid", "role": "customer", "full_name": "John Doe" }
   }

3. AUTHENTICATED REQUEST
   GET /api/v1/orders/
   Header: Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
   Response: { "count": 5, "results": [...] }

4. TOKEN REFRESH (every 2 hours)
   POST /api/v1/auth/token/refresh/
   Body: { "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..." }
   Response: { "access": "eyJ0eXAiOiJKV1QiLCJhbGc..." }

5. LOGOUT
   POST /api/v1/auth/logout/
   Body: { "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..." }
   Response: { "detail": "Successfully logged out." }
   (Refresh token blacklisted, cannot be reused)
```

### 2.4 Permission Classes

```python
# apps/accounts/permissions.py

class IsCustomer(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'customer'

class IsPeyk(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'peyk'

class IsVendor(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'vendor'

class IsOperator(BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ('operator', 'admin', 'developer')

class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ('admin', 'developer')

class IsDeveloper(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'developer'
```

Every viewset explicitly declares:
```python
permission_classes = [IsAuthenticated, IsCustomer]  # or other combination
```

---

## 3. Database Design

### 3.1 Schema Overview

#### User & Authentication
```sql
-- CustomUser (core identity)
CREATE TABLE accounts_customuser (
    id UUID PRIMARY KEY,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(254),
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL,  -- customer, peyk, vendor, operator, admin, developer
    city VARCHAR(100),
    password_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_staff BOOLEAN DEFAULT FALSE,
    date_joined TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    INDEX idx_phone (phone),
    INDEX idx_role (role)
);

-- PeykProfile (driver-specific)
CREATE TABLE accounts_peykprofile (
    id UUID PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL,
    peyk_code VARCHAR(10) UNIQUE NOT NULL,  -- YLK-XXXXX
    vehicle_type VARCHAR(10),  -- car, motor
    is_verified BOOLEAN,
    is_available BOOLEAN,
    rating DECIMAL(3,2),
    rating_count INTEGER,
    complaint_count INTEGER,
    created_at TIMESTAMP AUTO_NOW_ADD,
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id),
    INDEX idx_peyk_code (peyk_code),
    INDEX idx_is_available (is_available)
);

-- VendorProfile (restaurant/shop)
CREATE TABLE accounts_vendorprofile (
    id UUID PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL,
    business_name VARCHAR(200),
    category_id UUID,
    is_active BOOLEAN,
    rating DECIMAL(3,2),
    rating_count INTEGER,
    address TEXT,
    city VARCHAR(100),
    phone VARCHAR(15),
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (category_id) REFERENCES catalog_category(id),
    INDEX idx_city (city),
    INDEX idx_category (category_id)
);

-- OperatorProfile
CREATE TABLE accounts_operatorprofile (
    id UUID PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL,
    assigned_city VARCHAR(100),
    employee_id VARCHAR(20) UNIQUE,
    created_at TIMESTAMP AUTO_NOW_ADD,
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id),
    INDEX idx_assigned_city (assigned_city)
);
```

#### Catalog & Items
```sql
-- Category
CREATE TABLE catalog_category (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    slug VARCHAR(100) UNIQUE,
    icon_url VARCHAR(255),
    display_order SMALLINT,
    is_coming_soon BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP AUTO_NOW_ADD,
    INDEX idx_slug (slug),
    INDEX idx_display_order (display_order)
);

-- Item
CREATE TABLE catalog_item (
    id UUID PRIMARY KEY,
    vendor_id UUID,
    category_id UUID,
    name VARCHAR(200),
    description TEXT,
    price BIGINT,  -- Tomans
    is_available BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2),
    rating_count INTEGER,
    city VARCHAR(100),
    created_at TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    FOREIGN KEY (vendor_id) REFERENCES accounts_vendorprofile(id),
    FOREIGN KEY (category_id) REFERENCES catalog_category(id),
    INDEX idx_vendor_city (vendor_id, city),
    INDEX idx_category (category_id),
    INDEX idx_is_available (is_available)
);

-- ItemGallery
CREATE TABLE catalog_itemgallery (
    id UUID PRIMARY KEY,
    item_id UUID,
    image VARCHAR(255),  -- S3 path
    is_primary BOOLEAN,
    order SMALLINT,
    uploaded_at TIMESTAMP AUTO_NOW_ADD,
    FOREIGN KEY (item_id) REFERENCES catalog_item(id),
    INDEX idx_item (item_id)
);
```

#### Orders
```sql
-- Order (main order document)
CREATE TABLE orders_order (
    id UUID PRIMARY KEY,
    customer_id UUID,
    vendor_id UUID,
    status VARCHAR(20),  -- pending, accepted, preparing, picked_up, delivered, cancelled
    delivery_type VARCHAR(20),  -- in_city, inter_city
    payment_method VARCHAR(20),  -- online, cash, card_in_person
    total_amount BIGINT,
    delivery_address TEXT,
    delivery_city VARCHAR(100),
    customer_notes TEXT,
    created_at TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    FOREIGN KEY (customer_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (vendor_id) REFERENCES accounts_vendorprofile(id),
    INDEX idx_customer_status (customer_id, status),
    INDEX idx_vendor_status (vendor_id, status),
    INDEX idx_created_at (created_at)
);

-- OrderItem (line items)
CREATE TABLE orders_orderitem (
    id UUID PRIMARY KEY,
    order_id UUID,
    item_id UUID,
    quantity INTEGER,
    unit_price BIGINT,
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    FOREIGN KEY (item_id) REFERENCES catalog_item(id)
);

-- OfflineOrder (phone-in orders)
CREATE TABLE orders_offlineorder (
    id UUID PRIMARY KEY,
    operator_id UUID,
    customer_phone VARCHAR(15),
    customer_name VARCHAR(100),
    vendor_id UUID,
    items_description TEXT,
    total_amount BIGINT,
    delivery_address TEXT,
    status VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    FOREIGN KEY (operator_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (vendor_id) REFERENCES accounts_vendorprofile(id),
    INDEX idx_status (status)
);
```

#### Delivery & Tracking
```sql
-- PeykAssignment
CREATE TABLE delivery_peykassignment (
    id UUID PRIMARY KEY,
    order_id UUID UNIQUE,
    peyk_id UUID,
    assigned_at TIMESTAMP AUTO_NOW_ADD,
    picked_up_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    estimated_delivery TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    FOREIGN KEY (peyk_id) REFERENCES accounts_customuser(id),
    INDEX idx_peyk (peyk_id),
    INDEX idx_assigned_at (assigned_at)
);

-- GPSSnapshot
CREATE TABLE tracking_gpssnapshot (
    id UUID PRIMARY KEY,
    peyk_id UUID,
    order_id UUID,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    timestamp TIMESTAMP AUTO_NOW_ADD,
    FOREIGN KEY (peyk_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    INDEX idx_peyk_timestamp (peyk_id, timestamp DESC),
    INDEX idx_order_timestamp (order_id, timestamp DESC)
);

-- TipaxShipment (inter-city delivery)
CREATE TABLE delivery_tipaxshipment (
    id UUID PRIMARY KEY,
    order_id UUID UNIQUE,
    peyk_id UUID,
    tipax_branch_name VARCHAR(200),
    tipax_tracking_code VARCHAR(100),
    dropped_at TIMESTAMP NULL,
    code_entered_by_id UUID NULL,
    code_entered_at TIMESTAMP NULL,
    created_at TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    FOREIGN KEY (peyk_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (code_entered_by_id) REFERENCES accounts_customuser(id)
);
```

#### Communications & Payments
```sql
-- CallLog
CREATE TABLE communications_calllog (
    id UUID PRIMARY KEY,
    order_id UUID NULL,
    caller_id UUID,
    receiver_id UUID,
    channel_name VARCHAR(200),
    livekit_room_name VARCHAR(200),
    egress_id VARCHAR(200),
    recording_path VARCHAR(500),
    started_at TIMESTAMP AUTO_NOW_ADD,
    ended_at TIMESTAMP NULL,
    duration_seconds INTEGER DEFAULT 0,
    initiated_by_operator BOOLEAN DEFAULT FALSE,
    consent_acknowledged BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    FOREIGN KEY (caller_id) REFERENCES accounts_customuser(id),
    FOREIGN KEY (receiver_id) REFERENCES accounts_customuser(id),
    INDEX idx_caller (caller_id),
    INDEX idx_receiver (receiver_id)
);

-- FCMDevice
CREATE TABLE communications_fcmdevice (
    id UUID PRIMARY KEY,
    user_id UUID,
    fcm_token TEXT UNIQUE,
    device_type VARCHAR(10),  -- android, ios
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP AUTO_NOW_ADD,
    updated_at TIMESTAMP AUTO_NOW,
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id),
    INDEX idx_user (user_id)
);

-- ZarinpalTransaction
CREATE TABLE payments_zarinpaltransaction (
    id UUID PRIMARY KEY,
    order_id UUID,
    amount BIGINT,
    authority VARCHAR(100) UNIQUE,
    status VARCHAR(20),  -- pending, verified, failed
    ref_id VARCHAR(100),
    payment_method VARCHAR(20),
    created_at TIMESTAMP AUTO_NOW_ADD,
    verified_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders_order(id),
    INDEX idx_status (status)
);
```

#### Reports
```sql
-- VendorReport
CREATE TABLE reports_vendorreport (
    id UUID PRIMARY KEY,
    vendor_id UUID,
    period VARCHAR(10),  -- daily, weekly, monthly, yearly
    period_start DATE,
    period_end DATE,
    total_orders INTEGER DEFAULT 0,
    total_revenue BIGINT DEFAULT 0,
    avg_order_value BIGINT DEFAULT 0,
    generated_at TIMESTAMP AUTO_NOW_ADD,
    FOREIGN KEY (vendor_id) REFERENCES accounts_vendorprofile(id),
    UNIQUE (vendor_id, period, period_start),
    INDEX idx_vendor_period (vendor_id, period, period_start DESC)
);
```

### 3.2 Query Optimization Strategies

#### N+1 Prevention
```python
# ✅ GOOD: Use select_related for ForeignKey
orders = Order.objects.filter(status='pending').select_related(
    'customer', 'vendor', 'assignment__peyk'
)

# ✅ GOOD: Use prefetch_related for reverse relations
vendors = VendorProfile.objects.prefetch_related(
    'items', 'gallery', 'reports'
)

# ❌ BAD: Will generate N queries for each order
orders = Order.objects.all()
for order in orders:
    print(order.vendor.business_name)  # SQL query per order
```

#### Indexes
```sql
-- Critical indexes for query speed
CREATE INDEX idx_order_status ON orders_order(status);
CREATE INDEX idx_order_customer_created ON orders_order(customer_id, created_at DESC);
CREATE INDEX idx_item_vendor_available ON catalog_item(vendor_id, is_available);
CREATE INDEX idx_gps_peyk_timestamp ON tracking_gpssnapshot(peyk_id, timestamp DESC);
CREATE INDEX idx_user_phone ON accounts_customuser(phone);
```

---

## 4. Communication Protocols

### 4.1 HTTP/HTTPS

**Protocol**: HTTP/2 (dev), HTTPS (prod)  
**Port**: 8000 (dev), 443 (prod)  
**Method**: REST (standard HTTP verbs: GET, POST, PATCH, DELETE)

#### Headers
```
Request:
  Authorization: Bearer <JWT_token>
  Content-Type: application/json
  Accept: application/json
  Accept-Language: fa

Response:
  Content-Type: application/json
  X-Request-ID: <unique-id>
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 999
  X-RateLimit-Reset: 1720000000
```

### 4.2 WebSocket

**Protocol**: WebSocket (WSS in production)  
**Port**: 8000 (same as HTTP, via ASGI)  
**Auth**: JWT token passed in query param or header during handshake

#### Order Status Updates
```
Endpoint: ws://localhost:8000/ws/orders/{order_id}/

Connect:
  client → server: (establishes connection with JWT auth)
  
Broadcast on status change:
  server → clients: {
    "type": "order.status",
    "order_id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "picked_up",
    "updated_at": "2025-07-10T15:45:00Z"
  }

Disconnect:
  client → server: (closed connection)
```

#### GPS Tracking Stream
```
Endpoint: ws://localhost:8000/ws/tracking/{order_id}/

Broadcast on GPS update:
  server → clients: {
    "type": "location.update",
    "peyk_id": "peyk-uuid",
    "latitude": 35.6892,
    "longitude": 51.3890,
    "timestamp": "2025-07-10T15:45:30Z"
  }
```

### 4.3 WebSocket Consumer Implementation

```python
# apps/orders/consumers.py
from channels.generic.websocket import AsyncWebsocketConsumer
import json

class OrderStatusConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Validate JWT from query param
        # Extract order_id from URL
        # Check user has permission to view this order
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.group_name = f'order_{self.order_id}'
        
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def order_status(self, event):
        # Broadcast received from signal
        await self.send(text_data=json.dumps({
            'type': event['type'],
            'order_id': event['order_id'],
            'status': event['status'],
            'updated_at': event['updated_at']
        }))
```

### 4.4 Routing Configuration

```python
# config/asgi.py
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from django.core.asgi import get_asgi_application
from apps.orders.routing import websocket_urlpatterns as orders_ws
from apps.tracking.routing import websocket_urlpatterns as tracking_ws

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            orders_ws + tracking_ws
        )
    ),
})
```

---

## 5. Real-time Systems

### 5.1 Order Status Broadcast

**Flow**:
```
1. ENDPOINT: PATCH /api/v1/orders/{id}/status/
   Body: { "status": "preparing" }

2. VIEW LOGIC:
   ├─ Validate transition with state machine
   ├─ Update order.status in DB
   ├─ Signal emitted on model save
   └─ Signal triggers channel broadcast

3. SIGNAL HANDLER:
   from django.db.models.signals import post_save
   from django.dispatch import receiver
   
   @receiver(post_save, sender=Order)
   def order_status_changed(sender, instance, **kwargs):
       async_to_sync(channel_layer.group_send)(
           f'order_{instance.id}',
           {
               'type': 'order.status',
               'order_id': str(instance.id),
               'status': instance.status,
               'updated_at': instance.updated_at.isoformat()
           }
       )

4. BROADCAST:
   ├─ Connected customers → receive update
   ├─ Connected peyks → receive update
   ├─ Connected operators → receive update
   └─ FCM push to offline users

5. CLIENT RECEIVES:
   {
     "type": "order.status",
     "order_id": "550e8400-e29b-41d4-a716-446655440000",
     "status": "preparing",
     "updated_at": "2025-07-10T15:45:00Z"
   }
```

### 5.2 GPS Tracking Stream

**Flow**:
```
1. PEYK APP: Sends GPS every 10-30 seconds
   POST /api/v1/tracking/location/
   Body: {
     "latitude": 35.6892,
     "longitude": 51.3890,
     "order_id": "order-uuid-or-null"
   }

2. BACKEND SAVES:
   ├─ Create GPSSnapshot in DB
   ├─ Signal triggers broadcast
   └─ Old snapshots kept for history/audit

3. BROADCAST TO TRACKING CHANNEL:
   async_to_sync(channel_layer.group_send)(
       f'tracking_order_{order_id}',
       {
           'type': 'location.update',
           'peyk_id': str(peyk_id),
           'latitude': 35.6892,
           'longitude': 51.3890,
           'timestamp': now.isoformat()
       }
   )

4. CUSTOMER RECEIVES IN REAL-TIME:
   ├─ GetirStyleDeliveryUi v2 app: Updates map with live pin
   └─ UI refreshes every WebSocket message

5. STORAGE:
   ├─ GPSSnapshot kept for 30 days (configurable)
   └─ Historical tracking data for disputes/audits
```

### 5.3 Channel Layer Configuration

```python
# settings/base.py
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [("127.0.0.1", 6379)],
            "capacity": 1500,  # Max messages per group
            "expiry": 10,      # Message TTL (seconds)
        },
    },
}
```

---

## 6. Payment Integration

### 6.1 Zarinpal Flow

**Sandbox**: `https://sandbox.zarinpal.com/pg/v4/payment/*`  
**Production**: `https://www.zarinpal.com/pg/v4/payment/*`

#### Request Payment
```
1. ENDPOINT: POST /api/v1/payments/initiate/
   Auth: IsCustomer
   Body: { "order_id": "order-uuid" }

2. BACKEND:
   ├─ Fetch Order object
   ├─ Validate order.payment_method == 'online'
   ├─ Call Zarinpal RequestPayment API:
   │
   │  POST https://sandbox.zarinpal.com/pg/v4/payment/request.json
   │  {
   │    "merchant_id": settings.ZARINPAL_MERCHANT_ID,
   │    "amount": order.total_amount,  # Tomans
   │    "description": f"Order {order.id}",
   │    "callback_url": "https://api.getir_style_delivery_ui.ir/api/v1/payments/verify/",
   │    "metadata": {"order_id": order.id}
   │  }
   │
   ├─ Zarinpal responds: { "authority": "A00000000000000000000000000..." }
   ├─ Create ZarinpalTransaction(status='pending', authority=...)
   └─ Return payment URL to client:
      {
        "payment_url": "https://sandbox.zarinpal.com/pg/StartPay/A00000000000000000000000000...",
        "authority": "A00000000000000000000000000..."
      }

3. CLIENT:
   ├─ Redirect to payment_url
   ├─ User enters card details on Zarinpal page
   └─ User confirms payment (or cancels)

4. ZARINPAL REDIRECTS BACK:
   GET https://api.getir_style_delivery_ui.ir/api/v1/payments/verify/?Authority=A00000000000000000000000000...&Status=OK

5. BACKEND VERIFIES:
   ├─ Parse Authority and Status from query params
   ├─ Call Zarinpal PaymentVerification API:
   │
   │  POST https://sandbox.zarinpal.com/pg/v4/payment/verify.json
   │  {
   │    "merchant_id": settings.ZARINPAL_MERCHANT_ID,
   │    "amount": order.total_amount,
   │    "authority": "A00000000000000000000000000..."
   │  }
   │
   ├─ If response.status == 100 or 101: Payment successful
   ├─ Update ZarinpalTransaction(status='verified', ref_id=response.ref_id)
   ├─ Update Order.payment_status = 'verified'
   ├─ Trigger order notifications (FCM to vendor + peyk)
   └─ Redirect client to success page

6. ASYNC FOLLOW-UP (Celery task):
   ├─ Send FCM notification to vendor: "New order #{order_id}"
   ├─ Send FCM notification to operator: "New order in city"
   └─ Add to operator board for assignment
```

### 6.2 Payment State Machine

```
pending ──(payment successful)──→ verified ✓ (order proceeds)
   ↓
   └─────(payment failed)────→ failed ✗ (customer retries)
```

### 6.3 Environment Configuration

```bash
# .env.development
ZARINPAL_MERCHANT_ID=YOUR_TEST_MERCHANT_ID
ZARINPAL_SANDBOX=true
ZARINPAL_CALLBACK_URL=http://localhost:8000/api/v1/payments/verify/

# .env.production
ZARINPAL_MERCHANT_ID=YOUR_PROD_MERCHANT_ID
ZARINPAL_SANDBOX=false
ZARINPAL_CALLBACK_URL=https://api.getir_style_delivery_ui.ir/api/v1/payments/verify/
```

---

## 7. VOIP & Recording

### 7.1 LiveKit Integration

**Development**: `ws://localhost:7880` (--dev mode)  
**Production**: `https://livekit.getir_style_delivery_ui.ir:7880` (self-hosted or cloud)

#### Token Generation
```python
# apps/communications/voip_adapter.py
from livekit import api
from django.conf import settings

class LiveKitAdapter:
    def generate_token(self, channel: str, user_id: str, user_name: str, expiry_seconds: int) -> str:
        """
        Generate a signed JWT token for WebRTC connection.
        
        Args:
            channel: Room name (e.g., "order_<order_id>")
            user_id: User UUID
            user_name: Display name
            expiry_seconds: Token lifetime
        """
        token = api.AccessToken(
            settings.LIVEKIT_API_KEY,  # devkey (dev) or prod key
            settings.LIVEKIT_API_SECRET  # secret (dev) or prod secret
        )
        token.with_identity(user_id)  # Unique identifier
        token.with_name(user_name)     # Display name
        token.with_ttl(timedelta(seconds=expiry_seconds))
        token.add_grants(api.VideoGrants(
            room_join=True,
            room=channel,
            can_publish=True,
            can_subscribe=True
        ))
        return token.to_jwt()
```

#### Call Initiation
```
1. ENDPOINT: POST /api/v1/communications/call/initiate/
   Auth: IsAuthenticated
   Body: {
     "order_id": "order-uuid",
     "consent_acknowledged": true
   }

2. BACKEND LOGIC:
   ├─ Validate order exists
   ├─ Check user role (customer/peyk on order, or operator)
   ├─ Verify consent_acknowledged == true
   ├─ Generate channel_name = f"order_{order.id}"
   ├─ Call LiveKitAdapter.generate_token():
   │   token = livekit.api.AccessToken(API_KEY, API_SECRET)
   │   token.with_identity(user_id)
   │   token.add_grants(VideoGrants(room=channel_name))
   │   return token.to_jwt()
   ├─ Create CallLog(status='active', consent_acknowledged=true)
   ├─ If LIVEKIT_RECORDING_ENABLED:
   │   - Call LiveKitAdapter.start_recording()
   │   - Store egress_id in CallLog
   ├─ FCM push to receiver:
   │   title: "Incoming call",
   │   data: {
   │     "token": "<livekit_token>",
   │     "channel_name": "order_<order_id>",
   │     "caller_name": "<name>",
   │     "call_log_id": "<call_id>"
   │   }
   └─ Return to caller:
      {
        "token": "<livekit_token>",
        "channel_name": "order_<order_id>",
        "livekit_url": "ws://localhost:7880",
        "call_log_id": "<call_id>"
      }

3. CLIENT APP:
   ├─ Receives token + channel_name
   ├─ Establishes WebRTC connection to LiveKit
   ├─ Joins room: channel_name
   ├─ Publishes/subscribes audio/video
   └─ Call active until one party hangs up

4. BACKEND (on end):
   ├─ ENDPOINT: POST /api/v1/communications/call/end/
   │   Body: { "call_log_id": "<call_id>" }
   ├─ Update CallLog(ended_at=now, duration_seconds=...)
   ├─ Call LiveKitAdapter.stop_recording(egress_id)
   ├─ Save recording_path from Egress response
   └─ Store URL in CallLog for playback
```

### 7.2 Recording with Egress

```python
def start_recording(self, channel: str, order_id: str) -> str | None:
    """Start Egress recording for a LiveKit room."""
    if not settings.LIVEKIT_RECORDING_ENABLED:
        return None
    
    from livekit.api import EgressServiceClient, RoomCompositeEgress
    
    client = EgressServiceClient(
        url=settings.LIVEKIT_URL,
        api_key=settings.LIVEKIT_API_KEY,
        api_secret=settings.LIVEKIT_API_SECRET
    )
    
    output_s3 = {
        "bucket": settings.ARVAN_BUCKET_NAME,
        "access_key": settings.ARVAN_ACCESS_KEY,
        "secret": settings.ARVAN_SECRET_KEY,
        "endpoint": settings.ARVAN_ENDPOINT_URL,
        "region": settings.ARVAN_REGION,
        "key_file": f"recordings/order_{order_id}_{channel}.mp4"
    }
    
    egress = RoomCompositeEgress(
        room_name=channel,
        output_s3=output_s3
    )
    
    response = client.start_egress(egress)
    return response.egress_id  # Store for later stop

def stop_recording(self, egress_id: str) -> None:
    """Stop and finalize Egress recording."""
    if not egress_id:
        return
    
    client = EgressServiceClient(...)
    client.stop_egress(egress_id)
    # Recording finalized to S3
```

### 7.3 Frontend Implementation (Flutter)

```dart
// frontend/getir_style_delivery_ui_v2/lib/data/repositories/communications_repository.dart

class CommunicationsRepository {
  Future<LiveKitCallResponse> initiateCall(String orderId, bool consentAcknowledged) async {
    final response = await apiClient.post(
      '/communications/call/initiate/',
      data: {
        'order_id': orderId,
        'consent_acknowledged': consentAcknowledged,
      },
    );
    return LiveKitCallResponse.fromJson(response);
  }

  Future<void> endCall(String callLogId) async {
    await apiClient.post(
      '/communications/call/end/',
      data: { 'call_log_id': callLogId },
    );
  }
}

// Inside call screen widget
final callResponse = await communicationsRepo.initiateCall(orderId, true);

// Connect to LiveKit
final room = Room();
await room.connect(
  callResponse.livelinkUrl,
  callResponse.token,
);

// Join room
await room.localParticipant?.publishAudioTrack(audioTrack);
await room.localParticipant?.publishVideoTrack(videoTrack);

// Listen for remote participants
room.onParticipantAdded.listen((remoteParticipant) {
  // Render video from remote peer
});
```

---

## 8. App Connectivity

### 8.1 GetirStyleDeliveryUi v2 (Customer) Connections

```
┌──────────────────────────────────────┐
│      GETIR_STYLE_DELIVERY_UI MAIN APP (Customer)       │
│        (Flutter - GetirStyleDeliveryUi v2)          │
└──────┬───────────────────────────────┘
       │
       ├─ HTTP/REST
       │  ├─ Register/Login
       │  ├─ Browse categories/items
       │  ├─ Create/view orders
       │  ├─ Payment initiation
       │  ├─ Track order status (polling)
       │  └─ AI recommendations
       │
       ├─ WebSocket (live updates)
       │  ├─ Order status broadcasts
       │  └─ GPS tracking stream
       │
       ├─ LiveKit (VOIP)
       │  ├─ Call to vendor
       │  └─ Call to peyk
       │
       ├─ Neshan Maps API (HTTP)
       │  ├─ Address geocoding
       │  └─ Map rendering
       │
       ├─ Firebase Admin (push notifications)
       │  └─ Incoming call alerts, order updates
       │
       └─ Zarinpal (payment)
          ├─ Payment gateway redirect
          └─ Callback verification
```

### 8.2 GetirStyleDeliveryUi Ops (Operator) Connections

```
┌──────────────────────────────────────┐
│     GETIR_STYLE_DELIVERY_UI OPERATOR APP (Manager)     │
│        (Flutter - GetirStyleDeliveryUi Ops)         │
└──────┬───────────────────────────────┘
       │
       ├─ HTTP/REST
       │  ├─ Login
       │  ├─ Fetch vendor checklist
       │  ├─ Update item prices/availability
       │  ├─ Peyk board (available drivers)
       │  ├─ Assign peyk to orders
       │  ├─ Create offline orders
       │  ├─ Enter tipax tracking codes
       │  ├─ View analytics & reports
       │  └─ Call logs
       │
       ├─ WebSocket
       │  ├─ Real-time order status
       │  └─ Peyk availability changes
       │
       ├─ LiveKit (VOIP)
       │  └─ Direct call to peyk
       │
       └─ Firebase Admin (push notifications)
          ├─ New order alerts
          └─ System notifications
```

### 8.3 GetirStyleDeliveryUi Peyk (Driver) Connections

```
┌──────────────────────────────────────┐
│      GETIR_STYLE_DELIVERY_UI PEYK APP (Driver)        │
│      (Flutter - GetirStyleDeliveryUi Peyk)         │
└──────┬───────────────────────────────┘
       │
       ├─ HTTP/REST
       │  ├─ Login
       │  ├─ View assigned orders
       │  ├─ Update order status (picked up, delivered)
       │  ├─ Post GPS location
       │  ├─ View earnings
       │  ├─ View ratings/complaints
       │  └─ Confirm tipax drop-off
       │
       ├─ WebSocket
       │  └─ New order assignments (real-time)
       │
       ├─ Geolocator (device)
       │  └─ Background GPS tracking
       │
       ├─ LiveKit (VOIP)
       │  ├─ Receive calls from customers
       │  └─ Receive calls from operators
       │
       └─ Firebase Admin (push notifications)
          ├─ Incoming calls
          └─ New orders, order updates
```

### 8.4 Network Request Examples

#### Customer browsing items (GetirStyleDeliveryUi v2)
```
GET /api/v1/catalog/items/?city=Tehran&category=getir_style_delivery_ui-food&ordering=top_rated
Headers:
  Authorization: Bearer <jwt_token>
  Content-Type: application/json

Response (200 OK):
{
  "count": 542,
  "next": "...",
  "results": [
    {
      "id": "item-uuid",
      "vendor": {
        "id": "vendor-uuid",
        "business_name": "Restaurant Name"
      },
      "name": "Kebab Koobideh",
      "price": 95000,
      "rating": 4.8,
      "rating_count": 234,
      "gallery": [
        { "image": "https://arvan.../item_gallery/abc.jpg" }
      ]
    },
    ...
  ]
}
```

#### Customer placing order (GetirStyleDeliveryUi v2)
```
POST /api/v1/orders/
Headers: Authorization: Bearer <jwt_token>
Body:
{
  "vendor_id": "vendor-uuid",
  "delivery_address": "123 Street, Tehran",
  "delivery_city": "Tehran",
  "delivery_type": "in_city",
  "payment_method": "online",
  "items": [
    { "item_id": "item-uuid", "quantity": 2 }
  ]
}

Response (201 Created):
{
  "id": "order-uuid",
  "status": "pending",
  "total_amount": 450000,
  "created_at": "2025-07-10T14:30:00Z"
}

Client then:
  1. WebSocket connect: ws://localhost:8000/ws/orders/order-uuid/
  2. Listen for status updates
  3. POST /api/v1/payments/initiate/ with order_id
```

#### Peyk confirms order pickup (GetirStyleDeliveryUi Peyk)
```
PATCH /api/v1/orders/order-uuid/status/
Headers: Authorization: Bearer <jwt_token>
Body: { "status": "picked_up" }

Response (200 OK):
{
  "id": "order-uuid",
  "status": "picked_up",
  "updated_at": "2025-07-10T15:15:00Z"
}

Backend:
  1. Validates transition with state machine
  2. Updates Order.status in DB
  3. Signal triggers WebSocket broadcast
  4. FCM push to customer: "Order picked up!"
  5. FCM push to operator: "Order in transit"
```

---

## 9. Deployment Architecture

### 9.1 Docker Compose (Local)

```yaml
version: '3.9'

services:
  # PostgreSQL database
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: getir_style_delivery_ui_db
      POSTGRES_USER: getir_style_delivery_ui_user
      POSTGRES_PASSWORD: getir_style_delivery_ui_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U getir_style_delivery_ui_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis cache & session store
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # LiveKit VOIP server
  livekit:
    image: livekit/livekit-server:latest
    command: --dev --bind 0.0.0.0
    ports:
      - "7880:7880"
      - "7881:7881"
      - "7882:7882/udp"

  # Django ASGI app
  web:
    build: .
    command: daphne -b 0.0.0.0 -p 8000 config.asgi:application
    environment:
      - DEBUG=True
      - DATABASE_URL=postgres://getir_style_delivery_ui_user:getir_style_delivery_ui_pass@postgres:5432/getir_style_delivery_ui_db
      - REDIS_URL=redis://redis:6379/0
      - LIVEKIT_URL=ws://livekit:7880
      - LIVEKIT_API_KEY=devkey
      - LIVEKIT_API_SECRET=secret
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./getir_style_delivery_ui_backend:/app
      - media_files:/app/media

  # Celery worker
  celery:
    build: .
    command: celery -A config worker --loglevel=info
    environment:
      - DATABASE_URL=postgres://getir_style_delivery_ui_user:getir_style_delivery_ui_pass@postgres:5432/getir_style_delivery_ui_db
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis
    volumes:
      - ./getir_style_delivery_ui_backend:/app

  # Celery Beat scheduler
  celery-beat:
    build: .
    command: celery -A config beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    environment:
      - DATABASE_URL=postgres://getir_style_delivery_ui_user:getir_style_delivery_ui_pass@postgres:5432/getir_style_delivery_ui_db
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis
    volumes:
      - ./getir_style_delivery_ui_backend:/app

volumes:
  postgres_data:
  media_files:
```

### 9.2 Production Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   PRODUCTION ENVIRONMENT                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Nginx Reverse Proxy                     │   │
│  │  (SSL/TLS termination, static file serving)         │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        Daphne ASGI Server (Gunicorn Fallback)       │   │
│  │  (Django ASGI app, WebSocket, async handlers)       │   │
│  │  (Multiple instances for load balancing)            │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                  │
│        ┌──────────────────┼──────────────────┐              │
│        │                  │                  │              │
│        ▼                  ▼                  ▼              │
│   ┌────────┐         ┌────────┐        ┌──────────┐       │
│   │  PG    │         │ Redis  │        │ LiveKit  │       │
│   │ (RDS)  │         │(ElastiC)        │(EC2)     │       │
│   └────────┘         └────────┘        └──────────┘       │
│        │                  │                  │              │
│        └──────────────────┼──────────────────┘              │
│                           │                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Celery Workers + Celery Beat                │   │
│  │  (Background tasks, scheduled reports)              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         S3-compatible (Arvan)                        │   │
│  │  (Media files, call recordings)                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Load Balancer (AWS ALB / HAProxy)
    ├─ SSL certificate
    ├─ Health checks
    └─ Automatic failover
```

### 9.3 Kubernetes Deployment (Optional Future)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: getir_style_delivery_ui-backend
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: django
        image: getir_style_delivery_ui/backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: getir_style_delivery_ui-secrets
              key: db-url
        - name: REDIS_URL
          valueFrom:
            configMapKeyRef:
              name: getir_style_delivery_ui-config
              key: redis-url
        livenessProbe:
          httpGet:
            path: /health/
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

## 10. Performance & Scalability

### 10.1 Optimization Strategies

#### Database
- Indexes on frequently queried fields
- Query optimization with select_related, prefetch_related
- Connection pooling via PgBouncer
- Read replicas for reporting queries
- Partitioning large tables (e.g., GPSSnapshot by date)

#### Caching
```python
from django.views.decorators.cache import cache_page
from django.core.cache import cache

# Cache category list for 1 hour
@cache_page(60 * 60)
def get_categories(request):
    return Response(CategorySerializer(Category.objects.all(), many=True).data)

# Cache user's recommendations for 30 minutes
def get_recommendations(user):
    cache_key = f"recommendations:{user.id}"
    cached = cache.get(cache_key)
    if cached:
        return cached
    
    recommendations = compute_recommendations(user)
    cache.set(cache_key, recommendations, 60 * 30)
    return recommendations
```

#### API Response Compression
```python
# settings/base.py
MIDDLEWARE = [
    'django.middleware.gzip.GZipMiddleware',  # Compress responses > 1KB
    ...
]
```

#### Pagination
```python
# Default page size: 20 items
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# Client request: GET /api/v1/orders/?page=2
# Response includes: count, next, previous, results
```

### 10.2 Load Testing Targets

- **Concurrent Users**: 500
- **Peak Orders/Hour**: 1000
- **API Latency (p99)**: < 500ms
- **WebSocket Connections**: 100+ per node
- **Uptime**: 99.5%

### 10.3 Scaling Checklist

```
Vertical Scaling (current approach for pilot):
  ✓ Larger VPS (more CPU, RAM)
  ✓ Faster disk (SSD)
  ✓ Database tuning

Horizontal Scaling (future):
  ⏳ Multiple app servers behind load balancer
  ⏳ Database replication (primary + read replicas)
  ⏳ Redis cluster instead of single instance
  ⏳ CDN for static assets
  ⏳ Geo-distributed LiveKit servers
  ⏳ Sharded database (by city)
```

---

## 11. Error Handling

### 11.1 HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | Successful GET, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid order status transition |
| 401 | Unauthorized | Missing JWT token |
| 403 | Forbidden | User lacks permission (IsCustomer required) |
| 404 | Not Found | Order ID doesn't exist |
| 409 | Conflict | State machine violation |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected error |
| 503 | Service Unavailable | Kill switch active |

### 11.2 Error Response Format

```json
{
  "detail": "Invalid status transition.",
  "status_code": 400,
  "error_code": "INVALID_TRANSITION"
}
```

### 11.3 Common Error Scenarios

```python
# Order state machine violation
if not order.can_transition_to(new_status, actor_role):
    return Response(
        {"detail": "Invalid status transition.", "error_code": "INVALID_TRANSITION"},
        status=status.HTTP_400_BAD_REQUEST
    )

# User lacks permission
if not user.role in ('operator', 'admin'):
    return Response(
        {"detail": "Only operators can perform this action.", "error_code": "PERMISSION_DENIED"},
        status=status.HTTP_403_FORBIDDEN
    )

# Zarinpal payment failure
try:
    response = zarinpal.verify_payment(authority, amount)
except ZarinpalError as e:
    return Response(
        {"detail": "Payment verification failed.", "error_code": "PAYMENT_FAILED"},
        status=status.HTTP_400_BAD_REQUEST
    )

# LiveKit connection error
try:
    token = livekit_adapter.generate_token(channel, user_id, name, 3600)
except Exception as e:
    log.error(f"LiveKit error: {e}")
    return Response(
        {"detail": "Call service temporarily unavailable.", "error_code": "VOIP_ERROR"},
        status=status.HTTP_503_SERVICE_UNAVAILABLE
    )
```

---

## 12. Security Implementation

### 12.1 Authentication

```python
# JWT Configuration
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=2),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': settings.SECRET_KEY,
}

# Token Usage
access_token: 2-hour lifetime (auto-refresh)
refresh_token: 30-day lifetime (user stores securely)
blacklist: All revoked tokens
```

### 12.2 Authorization

```python
# Every ViewSet declares permissions explicitly
class OrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsCustomerOrOperator]
    
    def list(self, request):
        # Customers see only their orders
        # Operators see all orders
        pass
    
    def create(self, request):
        permission_classes = [IsCustomer]  # Only customers can create
```

### 12.3 Input Validation

```python
class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['vendor_id', 'delivery_address', 'items']
    
    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError("Order must contain at least one item.")
        return value
    
    def validate_delivery_address(self, value):
        if len(value) < 10:
            raise serializers.ValidationError("Address too short.")
        return value
```

### 12.4 HTTPS & SSL

```
Production:
  ├─ SSL/TLS certificates (Let's Encrypt or Arvan)
  ├─ HTTPS forced (redirect HTTP → HTTPS)
  ├─ HSTS headers (Strict-Transport-Security)
  ├─ Secure cookies (HttpOnly, SameSite)
  └─ TLS 1.3 minimum

Development:
  └─ HTTP OK (localhost only)
```

### 12.5 PII & Data Protection

```python
# Call recording consent
class CallLog(models.Model):
    consent_acknowledged = models.BooleanField(default=False)
    # Only record if user explicitly consents

# Soft delete for sensitive data
class Order(models.Model):
    is_deleted = models.BooleanField(default=False)
    # Never hard-delete orders (audit trail)

# Encryption at rest
# Firebase credentials: stored encrypted in .env
# API keys: stored in secure key management (AWS Secrets Manager)
```

### 12.6 Kill Switch

```python
# Emergency API shutdown
class KillSwitchMiddleware:
    def __call__(self, request):
        if redis.get('getir_style_delivery_ui:kill_switch') == '1':
            return JsonResponse(
                {"detail": "API temporarily unavailable."},
                status=503
            )
        return self.get_response(request)

# Toggle via developer endpoint
POST /api/v1/developer/kill-switch/activate/
Header: X-Developer-Key: <DEVELOPER_SECRET_KEY>

POST /api/v1/developer/kill-switch/deactivate/
Header: X-Developer-Key: <DEVELOPER_SECRET_KEY>
```

---

## Quick Reference

### Key Endpoints Summary

```
Auth:           POST /auth/login/, POST /auth/token/refresh/
Catalog:        GET /catalog/categories/, GET /catalog/items/
Orders:         POST /orders/, PATCH /orders/{id}/status/
Delivery:       POST /delivery/assignments/, GET /tracking/location/
VOIP:           POST /communications/call/initiate/, POST /communications/call/end/
Payments:       POST /payments/initiate/, GET /payments/verify/
WebSocket:      ws://localhost:8000/ws/orders/{order_id}/, ws://localhost:8000/ws/tracking/{order_id}/
```

### Environment Variables

```bash
# Core
SECRET_KEY=...
DEBUG=True/False

# Database
POSTGRES_DB=getir_style_delivery_ui_db
POSTGRES_USER=getir_style_delivery_ui_user
POSTGRES_PASSWORD=...
DATABASE_URL=postgres://...

# Cache
REDIS_URL=redis://...

# VOIP
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret

# Payments
ZARINPAL_MERCHANT_ID=...
ZARINPAL_SANDBOX=true/false

# Storage
ARVAN_BUCKET_NAME=getir_style_delivery_ui-media
ARVAN_ACCESS_KEY=...
ARVAN_SECRET_KEY=...

# Firebase
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json

# Developer
DEVELOPER_SECRET_KEY=...
KILL_SWITCH_ACTIVE=false
```

---

**Version**: 1.0  
**Last Updated**: July 2025  
**For**: GetirStyleDeliveryUi Multi-App Delivery Platform  
**Status**: Production Technical Specification

