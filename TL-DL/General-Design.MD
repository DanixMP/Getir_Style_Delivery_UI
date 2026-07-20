# GETIR_STYLE_DELIVERY_UI — General App Design & User Experience Guide

![GetirStyleDeliveryUi Logo](logo.jpg)

## Welcome to GetirStyleDeliveryUi

GetirStyleDeliveryUi is a beautiful, multi-purpose delivery app designed for the Iranian market. It combines a sleek customer experience with powerful tools for business owners and delivery drivers. This guide explains what you see, how to use it, and what happens behind the scenes.

---

## 1. Design & Visual Identity

### Color Palette

| Color | Usage | Hex | Purpose |
|-------|-------|-----|---------|
| **Gold** | Primary accents, logo, highlights | `#D4AF37` | Premium feel, brand recognition |
| **Purple** | Background, sections, headers | `#6B2C91` | Modern, elegant, professional |
| **White** | Cards, surfaces, text background | `#FFFFFF` | Clarity, readability |
| **Dark Gray** | Text, borders | `#2D2D2D` | High contrast for readability |
| **Light Gray** | Disabled states, secondary text | `#CCCCCC` | Subtle hierarchy |
| **Green** | Success, confirmed, active | `#4CAF50` | Positive feedback |
| **Red** | Warnings, cancellations | `#F44336` | Urgent attention |
| **Orange** | Pending, in progress | `#FF9800` | Active/ongoing states |
| **Blue** | Information, links | `#2196F3` | Additional details |

### Typography

- **Primary Font**: Google Fonts (Farsi-optimized)
- **Display Font**: Persian Fonts (titles and headings)
- **Font Sizes**:
  - **Headings**: 24-28px (bold)
  - **Subheadings**: 18-20px (semi-bold)
  - **Body Text**: 14-16px (regular)
  - **Small Text**: 12px (captions)

### Design Elements

- **Rounded Corners**: All cards and buttons have 12px border radius (modern, friendly)
- **Shadows**: Subtle drop shadows for depth (4px blur, 20% opacity)
- **Icons**: Simple, filled icons for categories and actions
- **Spacing**: Consistent 8px grid (8, 16, 24, 32px gaps)
- **Animations**: Smooth transitions (200-300ms) for button presses and navigation

---

## 2. GetirStyleDeliveryUi Main App (Customer Experience)

### 2.1 Splash & Login Screen

**What You See:**
- Large GetirStyleDeliveryUi logo (gold "Y" on purple gradient background)
- App name "GETIR_STYLE_DELIVERY_UI" (Farsi) prominently displayed
- Welcoming tagline: "Everything You Need, Delivered Fast"

**Login Flow:**
1. **Phone Number Entry** - Type your 11-digit Iranian phone number (09xxxxxxxxx)
2. **Password Entry** - Enter secure password
3. **Login** - Tap "بیایید شروع کنیم" (Let's Get Started)
4. **Success** - Taken to Home Screen

**What's Happening:**
- Your phone number is verified on the server
- Your password is securely encrypted
- A session token is created (you stay logged in for 30 days)
- Your profile is loaded with your saved addresses and preferences

---

### 2.2 Home Screen - Main Menu

**Top Section:**
- **Your Location Badge** - Shows current city (e.g., "Tehran")
- **Address Dropdown** - Select from saved addresses or "Use Current Location"
- **Search Bar** - "جستجو برای یک سفارش" (Search for an order)
- **Bell Icon** - Notifications (new offers, order updates, calls)

**Main Categories Grid (6 Categories):**

Each category is a large, tappable card with:
- **Icon** (category-specific)
- **Category Name** (Farsi)
- **"Order Now"** or **"Coming Soon"** badge

| Category | Icon | Color | Status |
|----------|------|-------|--------|
| **GetirStyleDeliveryUi Food** | 🍽️ | Purple-to-Gold gradient | Active |
| **GetirStyleDeliveryUi Drink** | 🥤 | Blue gradient | Active |
| **GetirStyleDeliveryUi Dessert** | 🍰 | Pink gradient | Active |
| **GetirStyleDeliveryUi Medic** | 💊 | Green gradient | Active |
| **GetirStyleDeliveryUi Groceries** | 🛒 | Orange gradient | Active |
| **GetirStyleDeliveryUi Taxi** | 🚕 | Gray (grayed out) | Coming Soon |

**Coming Soon Categories:**
- Taxi category appears grayed out with a "چیزی که کمتر از این نیست" (Coming Soon) badge
- Tapping shows: "This service will be available soon. Tap to join the waiting list."

**Bottom Navigation (Always Visible):**
- 🏠 **Home** (active indicator)
- 🔍 **Search**
- 🛒 **Cart** (with badge showing item count)
- 👤 **Profile**
- ☰ **Menu**

---

### 2.3 Category Browse - Vendor Listing

**What You See After Selecting a Category:**

**Filter Bar at Top:**
- **Sorting Options:**
  - "جدیدترین" (Newest)
  - "ارزانترین" (Cheapest)
  - "گرانترین" (Most Expensive)
  - "بیشترین امتیاز" (Top Rated)
  - "نزدیکترین" (Closest)

**Vendor Cards (Scrollable List):**

Each vendor card shows:
- **Vendor Photo** (background banner)
- **Vendor Name** (bold, 18px)
- **Delivery Badge** (e.g., "15-25 دقیقه" - 15-25 minutes)
- **Rating Stars** (⭐4.8 - 234 reviews)
- **Categories** (e.g., "کباب کوبیده, تاس کباب")
- **Distance** (e.g., "2.3 کیلومتر")
- **Delivery Fee** (e.g., "۱۵۰۰ تومان" - 1500 Tomans)
- **"باز" or "بسته"** (Open/Closed status - green if open, red if closed)

**Scrolling:**
- Cards scroll horizontally through entire category
- Infinite scroll - loads more vendors as you reach the bottom

---

### 2.4 Vendor Detail Screen

**Header Section:**
- **Large Vendor Image** (scrollable gallery)
- **Vendor Name** (gold text overlay)
- **Star Rating** (⭐⭐⭐⭐⭐ 4.8)
- **Distance** (2.3 km)
- **Delivery Time** (15-25 minutes)
- **Call Button** (📞 - initiates live call to vendor)

**Menu Tabs:**
- **منو** (Menu) - Items
- **درباره** (About) - Vendor info
- **نقد و نظر** (Reviews) - Customer reviews

**Menu Section (Default Tab):**

**Items Listed as Cards:**
Each item card shows:
- **Item Image** (scrollable gallery if multiple)
- **Item Name** (18px, bold)
- **Item Description** (12px, gray text)
- **Price** (18px, gold, bold) - e.g., "۹۵۰۰۰ تومان"
- **"+" Button** - Add to cart

**Item Search Bar:**
- "جستجو در منو" (Search menu)
- Filters items as you type

**About Tab:**
- Vendor description
- Address
- Phone number (with call button)
- Operating hours
- Category tags
- Photo gallery

**Reviews Tab:**
- Customer reviews (newest first)
- Star rating
- Review text
- Customer name + avatar
- Date

---

### 2.5 Item Detail Modal

**When You Tap an Item:**

A beautiful modal slides up showing:
- **Large Item Image** (high quality)
- **Item Name** (gold heading)
- **Price** (prominent gold text)
- **Description** (2-3 lines of detail)
- **Rating** (⭐4.9 - 145 people rated)
- **Quantity Selector** (- and + buttons with number)
- **Special Instructions Field** (textarea: "بدون پیاز لطفا" = "No onion please")
- **Add to Cart Button** (large purple button at bottom)
- **Call Vendor Button** (smaller option)

---

### 2.6 Shopping Cart

**Cart Screen (Bottom tab icon 🛒):**

**Header:**
- "سبد خرید" (Shopping Cart)
- "پاک کردن" (Clear Cart) button

**Vendor Name** (purple header section)
- Shows which vendor your items are from
- Cannot mix vendors (must checkout first to order from different vendor)

**Item List:**
Each item in cart shows:
- **Item Image** (small thumbnail)
- **Item Name**
- **Price per unit**
- **Quantity Controls** (-, number, +)
- **Total for this item** (quantity × price)
- **Delete Button** (trash icon)

**Bottom Summary Section:**
- **Subtotal**: "جمع": ۴۵۰۰۰۰ تومان
- **Delivery Fee**: "هزینه تحویل": ۱۵۰۰ تومان
- **Promo Code** (optional text field)
- **Estimated Total**: "جمع نهایی": ۴۶۵۰۰۰ تومان
- **Checkout Button** (large, gold)

---

### 2.7 Checkout Screen

**Three-Step Process:**

#### Step 1: Delivery Address
- **Address Picker** (shows saved addresses)
- **Current Location** (auto-detect)
- **Add New Address** button
  - Opens map picker
  - Long-press or search to select location
  - Enter address name (e.g., "دفتر", "خانه")
  - Save for future orders

**Selected Address Preview:**
- "تهران، خیابان جمهوری، پلاک ۱۲۳"
- "فاصله تقریبی: ۲۵۰ متر"

#### Step 2: Payment Method
Radio button options:
- **💳 پرداخت آنلاین (Online via Zarinpal)**
  - Secure credit/debit card payment
  - Real-time verification
  - Instant order confirmation
  
- **💵 نقد (Cash)**
  - Pay driver upon delivery
  - Driver will have change
  
- **🏧 کارت درب منزل (Card at Door)**
  - Debit/credit card payment with driver
  - Driver has card reader

#### Step 3: Order Summary
- Vendor name and image
- All items with prices
- Delivery address
- Delivery fee
- Total amount (gold, bold, 24px)
- **Delivery Notes** (optional textarea)
  - "لطفا در ساعت مشخصی تحویل بدهید" (Please deliver at specific time)

**Final Button:**
- **"تایید و پرداخت" (Confirm & Pay)** - Large purple button

---

### 2.8 Real-Time Order Tracking

**After Order Placed:**

**Order Status Live Updates:**

The order card shows live status with beautiful animations:

```
⏳ درحال پذیرفتن (Pending)
   └─ Vendor checking order
       ↓ (auto-updates when vendor accepts)

✅ پذیرفته شد (Accepted)
   └─ Vendor confirmed order
       ↓ (auto-updates when cooking starts)

👨‍🍳 تهیه شدن (Preparing)
   └─ Vendor is cooking/preparing
       ↓ (auto-updates when peyk arrives)

📦 برداشته شد (Picked Up)
   └─ Delivery driver picked up order
       ↓ (shows real-time GPS tracking)

🚗 در راه است (In Transit)
   └─ Driver moving to your location
       ↓ (auto-updates when delivered)

✅ تحویل داده شد (Delivered)
   └─ Order completed!
```

**Order Card Components:**

- **Status Indicator** (animated circle with color)
  - Gray: Pending
  - Orange: Processing
  - Blue: In Transit
  - Green: Delivered
  
- **Estimated Delivery Time**
  - "تقریبا ۲۳ دقیقه دیگر" (About 23 minutes)
  - Counts down in real-time
  
- **Live Location Map**
  - Shows driver's current location (red pin)
  - Your destination (green pin)
  - Route between them (blue line)
  - Updates every 5-10 seconds
  
- **Driver Card** (when assigned)
  - Driver photo (small circular avatar)
  - Driver name: "علی محمدی"
  - Vehicle type: "موتور" (Motorcycle) or "ماشین" (Car)
  - Peyk code: "YLK-A3X9M"
  - Rating: ⭐4.9
  - **Call Button** (📞 - tap to call driver)
  
- **Estimated Delivery Address**
  - Full address shown
  - "الزام شناسایی کننده" if building/gate number needed
  
- **Order Items Summary**
  - Collapsed view showing total items
  - Tap to expand and see all items

**Updates Happen in Real-Time:**
- No need to refresh
- Push notifications when status changes
- Sound alert (optional)
- Map animates as driver moves

---

### 2.9 In-App Call System

**How to Make a Call:**

#### Option 1: Call from Vendor Detail Screen
1. Go to vendor detail screen
2. Tap **📞 Call** button at top
3. A popup appears: "Call Restaurant?"
4. Tap "بله، تماس بگیر" (Yes, Call)
5. Connection established to vendor's line

#### Option 2: Call from Order Tracking
1. While tracking order
2. When driver is assigned, you see driver card
3. Tap **📞 Call Driver** button
4. Connection established

**What the Call Experience Looks Like:**

**Incoming Call Screen (if they call you):**
```
┌────────────────────────────┐
│    علی محمدی               │
│    فروشگاه غذایی          │
│                            │
│    [📞]                    │
│                            │
│  ┌─────────────┬──────────┐│
│  │   📞 پاسخ   │  🚫 رد  ││
│  └─────────────┴──────────┘│
└────────────────────────────┘
```

**Active Call Screen:**
```
┌────────────────────────────┐
│   🔴 تماس فعال (01:23)     │
│                            │
│    علی محمدی               │
│    فروشگاه غذایی          │
│                            │
│  ┌──────────────────────┐  │
│  │  🔇 بی صدا | 🔊 بلند │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │   ☎️ پایان تماس      │  │
│  └──────────────────────┘  │
└────────────────────────────┘
```

**What's Happening Behind the Scenes (You Don't See):**
- A secure connection is established via LiveKit
- Your audio is encrypted end-to-end
- The call may be recorded (with consent notification)
- Both parties hear crystal clear audio
- No middle-man interception
- Call history is saved in your profile

**Call Consent:**
- Before calling, you see: "این تماس ممکن است ضبط شود" (This call may be recorded)
- You must tap "موافق" (I Agree) to proceed
- This protects both you and the vendor

**After Call Ends:**
- Call duration shown: "مدت تماس: 02:45"
- Option to rate the call
- Option to report issues

---

### 2.10 User Profile Screen

**Profile Navigation (Bottom tab 👤):**

**Header Section:**
- **Large Avatar** (user photo or avatar icon)
- **User Name** (e.g., "محمد علی")
- **Phone Number** (e.g., "09123456789")
- **Edit Profile** button

**Profile Sections:**

1. **آدرس های ذخیره شده** (Saved Addresses)
   - List of all saved locations
   - "خانه" (Home)
   - "دفتر" (Office)
   - "والدین" (Parents)
   - Add new address button (+)

2. **سفارش های من** (My Orders)
   - Recent orders (newest first)
   - Tap to view details/track
   - Reorder button (repeat order)
   - "دیدن همه" (View All) link

3. **روش های پرداخت** (Payment Methods)
   - Saved credit cards (masked: **** **** **** 1234)
   - Default payment method marked
   - Add new card button
   - Edit/delete options

4. **تنظیمات** (Settings)
   - **زبان** (Language): فارسی, English, العربية, Türkçe
   - **اطلاع رسانی** (Notifications): Toggle push notifications
   - **دسترسی مکان** (Location): Always/While Using/Never
   - **حالت شب** (Dark Mode): Toggle

5. **راهنما و پشتیبانی** (Help & Support)
   - **درباره برنامه** (About)
   - **شرایط و ضوابط** (Terms & Conditions)
   - **سیاست حریم خصوصی** (Privacy Policy)
   - **تماس با ما** (Contact Us)
   - **نسخه** (Version): 1.0.0 (Build 1)

6. **خروج** (Logout)
   - Taps here to sign out
   - Confirmation: "آیا مطمئن اید؟" (Are you sure?)

---

### 2.11 Promotions & AI Recommendations

**Promotional Banner (Home Screen):**
- Rotating carousel of active offers
- "۲۰% تخفیف روی تمام پیتزا" (20% off all pizzas)
- "کتاب بخور، یکی رایگان بخور" (Buy one, get one free)
- Expiration date shown
- Tap to apply to cart

**AI Recommendations (Home Screen - Below Categories):**
- Personalized section: "برای تو پیشنهاد شده" (Recommended for You)
- Shows items you've ordered before
- Shows popular items in your category preferences
- Shows discounted items matching your taste

**Smart Suggestions (On Search):**
- As you search, AI suggests items
- "جستجوی محبوب: کباب کوبیده" (Popular search: Kebab Koobideh)
- Quick access to top-rated items

---

## 3. GetirStyleDeliveryUi Operator App (Business Manager Experience)

### 3.1 Operator Dashboard

**What Operators Do:**
- Manage vendors in their city
- Monitor delivery drivers
- Handle customer phone orders
- Track analytics

**Main Screen Layout:**

**Header:**
- "اپراتور GETIR_STYLE_DELIVERY_UI" (GetirStyleDeliveryUi Operator)
- City name: "تهران - منطقه ۲"
- Time and alerts

**Navigation Tabs:**
1. 🏢 **Vendors** (Vendor Management)
2. 🚗 **Peyks** (Driver Board)
3. 📋 **Orders** (Order Management)
4. 📊 **Reports** (Analytics)
5. ⚙️ **Settings** (Admin Settings)

---

### 3.2 Vendor Checklist

**Vendor Management Tab:**

**Live Vendor List:**
Each vendor card shows:
- **Vendor Name** (bold)
- **Status Badge**
  - 🟢 "باز و فعال" (Open & Active) - Green
  - 🟡 "تعطیل موقت" (Temporarily Closed) - Yellow
  - 🔴 "بسته" (Closed) - Red
  
- **Today's Orders** - e.g., "۴۲ سفارش"
- **Today's Revenue** - e.g., "۱۲۵۰۰۰۰ تومان"
- **Active Items** - e.g., "۴۵ آیتم"
- **Toggle Switch** - Turn vendor on/off
- **Quick Actions**
  - 📝 Edit menu
  - 📞 Call vendor
  - 👁️ View vendor page

**Item Management:**
- Tap vendor to expand
- See all items with prices
- Toggle item availability (in/out of stock)
- Quick edit prices
- Mark items as "فروخته شد" (Sold Out)

---

### 3.3 Peyk Board (Driver Management)

**Driver Management Tab:**

**Available Drivers Grid:**

Each driver card shows:
- **Driver Avatar** (circular photo)
- **Driver Name** (e.g., "علی محمدی")
- **Peyk Code** (e.g., "YLK-A3X9M")
- **Vehicle Type** Icon
  - 🏍️ Motor
  - 🚗 Car
- **Current Status**
  - 🟢 "در دسترس" (Available)
  - 🟠 "مشغول" (Busy)
  - 🔴 "آفلاین" (Offline)
- **Rating** (⭐4.8 - 156 ratings)
- **Today's Deliveries** (e.g., "۲۳ سفارش")
- **Quick Call Button** (📞)

**Assign Order to Driver:**
1. Tap unassigned order
2. Choose from available drivers
3. Driver gets push notification
4. Driver can accept/reject
5. Order updates in real-time

**Driver Performance:**
- Tap driver card to see:
  - Daily earnings
  - On-time delivery rate
  - Customer rating
  - Complaints
  - Call history

---

### 3.4 Order Management

**Order Management Tab:**

**Order Status Columns (Kanban-style):**

```
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   درحال      │   پذیرفته    │   تهیه       │   برداشته    │   تحویل      │
│   پذیرفتن    │   شده        │   شدن       │   شد         │   داده شد    │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ [Order #1]  │ [Order #5]  │ [Order #7]  │ [Order #12] │ [Order #20] │
│ [Order #2]  │ [Order #6]  │ [Order #8]  │ [Order #14] │ [Order #22] │
│ [Order #3]  │             │ [Order #9]  │ [Order #16] │             │
│             │             │             │             │             │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

Each order card shows:
- Order ID: "#۲۴۵۱"
- Customer name: "محمد علی"
- Items count: "۳ مورد"
- Total amount: "۴۵۰۰۰۰ تومان"
- Delivery address (snippet)
- Assigned driver (if any)

**Drag & Drop:**
- Operators can drag orders between columns
- Drag from "Pending" to "Accepted"
- Drag from "Preparing" to "Picked Up"

**Phone Orders (Offline Orders):**
- "ثبت سفارش تلفنی" (Register Phone Order) button
- Fill form:
  - Customer phone
  - Customer name
  - Items description (free text)
  - Total amount
  - Delivery address
  - Notes
- Saves as offline order

**Tipax Tracking (Inter-city):**
- For orders going to other cities
- Operator enters tracking code after peyk confirms drop-off
- "کد تپاکس: TIP-۱۲۳۴۵۶"
- Saves for customer reference

---

### 3.5 Analytics & Reports

**Reports Tab:**

**Daily Dashboard:**
- **Total Orders**: ۴۵۲ سفارش
- **Total Revenue**: ۲۳۵۰۰۰۰۰ تومان
- **Average Order Value**: ۵۲۰۰۰ تومان
- **Delivery Success Rate**: ۹۸.۲%
- **Average Delivery Time**: ۲۳ دقیقه

**Charts:**
- **Order Trend** (line chart: orders per hour)
- **Category Breakdown** (pie chart: orders by category)
- **Top Vendors** (bar chart: revenue by vendor)
- **Peak Hours** (heatmap: busiest times)

**Vendor Rankings:**
1. فروشگاه علی (Ali's Store) - ۶۸ orders, ۳۲۰۰۰۰۰ تومان
2. رستوران نیلوفر (Niloofar Restaurant) - ۴۵ orders, ۲۴۵۰۰۰۰ تومان
3. کافه شاخ‌های (Coffee House) - ۳۲ orders, ۱۸۵۰۰۰۰ تومان

---

## 4. GetirStyleDeliveryUi Peyk App (Delivery Driver Experience)

### 4.1 Driver Home Screen

**Driver Dashboard:**

**Today's Summary (Top Card):**
- **Today's Orders**: ۲۳ سفارش
- **Completed**: ۱۹ ✅
- **In Progress**: ۳ 🚗
- **Earnings So Far**: ۶۵۰۰۰۰ تومان
- **Rating**: ⭐4.8

**Active Assignments:**

Current order card shows:
- **Order ID**: #۲۴۱
- **Customer Name**: "فاطمه علی"
- **Pickup Location** (vendor)
  - "رستوران محمد، تهران"
  - "۵۰۰ متری" (500m away)
- **Dropoff Location** (customer)
  - "خیابان جمهوری، پلاک ۱۲۳"
  - "۳.۲ کیلومتر" (3.2 km away)
- **Estimated Time**: "۲۵ دقیقه"
- **Status**: "برو برای برداشتن" (Go pick up)
- **Large Map** showing route
- **Call Customer** button (📞)

**Action Buttons:**
- **✅ برداشتم** (Confirm Pickup) - After picking up from vendor
- **✅ تحویل دادم** (Confirm Delivery) - After arriving at customer

**Available Orders Queue (if not assigned):**
- List of available orders
- "قبول کردن" (Accept) buttons
- Shows distance, payment, estimated time

---

### 4.2 Real-Time GPS Tracking (Driver Side)

**What's Being Tracked:**

The app automatically sends driver's location every 10-30 seconds to the backend:
- **Current coordinates** (latitude, longitude)
- **Accuracy** (how precise the location is)
- **Speed** (how fast you're moving)
- **Timestamp** (exact time of location)

**What the Customer Sees:**
- Red pin on map showing your exact position
- Blue line showing your route
- Animated movement as you drive
- Estimated arrival time (updates as you get closer)

**How It Works (Seamlessly):**
1. You accept an order
2. App runs in background
3. Every 10 seconds, sends your location
4. Customer's map updates in real-time
5. No battery drain (optimized location service)
6. Works even with screen off

**Battery Optimization:**
- Uses GPS only while on delivery
- Switches to WiFi location when indoors
- Stops tracking after delivery
- Battery usage: ~5-8% per hour

---

### 4.3 Driver Communication

**Incoming Calls:**

When customer or operator calls:

```
┌────────────────────────────┐
│    محمد علی                │
│    مشتری                   │
│                            │
│    [📞]                    │
│                            │
│  ┌─────────────┬──────────┐│
│  │   📞 پاسخ   │  🚫 رد  ││
│  └─────────────┴──────────┘│
└────────────────────────────┘
```

- Accept call (📞 button)
- Reject call (X button)
- Decline during driving (safety)
- Call history saved

**What's Private:**
- Only app-to-app calling (numbers not shared)
- Call may be recorded (notification shown)
- Both parties' privacy protected
- Call duration tracked

---

### 4.4 Driver Earnings & Performance

**Earnings Tab:**

**Today's Earnings:**
- Base delivery fees: ۵۲۰۰۰۰ تومان
- Tips received: ۸۵۰۰۰ تومان
- **Total Today**: ۶۰۵۰۰۰ تومان

**This Week:**
- ۷ days × average = ~۴۲۰۰۰۰۰ تومان

**Performance Metrics:**
- **Rating**: ⭐4.8 (based on 156 deliveries)
- **On-Time Delivery**: ۹۷.۲%
- **Cancellation Rate**: ۱.۲%
- **Complaints**: ۲ (resolved)

**Payment Methods:**
- Daily payment transfer to bank account
- Weekly summary
- Payable to: "علی محمدی - شماره حساب: ۱۲۳۴۵۶"

---

## 5. Real-Time Location & GPS Tracking

### How Real-Time Location Works (User Perspective)

**The Magic Behind the Scenes:**

```
Driver's Phone                Server                Customer's Phone
     │                          │                           │
     │─── GPS Signal ───────────│                           │
     │                          │                           │
     │    (every 10 sec)        │                           │
     │                          │────── Broadcast ─────────→│
     │                          │     New Location          │
     │                          │                           │
     │                      [WebSocket]                     │
     │                          │                           │
     │                          │   ← Map Updates ←────────│
     │                          │    in Real-Time           │
     │
     └─── (Secure Encrypted Channel) ───────────────────────┘
```

**What You See (As Customer):**
1. Place order
2. Order accepted
3. Driver assigned (you see driver's photo)
4. Driver heads to restaurant
5. Red pin appears on map
6. Pin moves smoothly as driver drives
7. Estimated time updates in real-time
8. "Driver is 2.5 km away, arriving in ~12 minutes"
9. As driver gets closer, updates become more frequent
10. "Driver arrived!" when at your location

**What You See (As Driver):**
1. Accept order
2. App auto-starts tracking
3. You don't need to do anything
4. Continue driving normally
5. App sends location in background
6. Battery-efficient
7. Works even with screen off
8. Customer sees live map in their app

**Privacy Protection:**
- Your exact home address is **never shared** with driver
- Driver only sees a pin on the map
- Once delivery complete, tracking stops
- Location data deleted after 7 days
- Only you, driver, and operator can see live location

---

### What's Happening Technically (Not Visible to You)

**The Connection:**
- Secure encrypted channel (end-to-end)
- No middle-person can intercept
- Data validated at every step
- Automatic reconnection if internet drops

**Updates Speed:**
- Every 10-30 seconds (driver's phone)
- Broadcast to all connected users (customer, operator)
- <1 second latency (instant update)
- Works on 4G/5G and WiFi

**Accuracy:**
- Uses GPS (outside buildings)
- Falls back to WiFi triangulation (inside)
- GPS accuracy: ±5-10 meters
- Good enough for delivery routing

---

## 6. In-App Voice Call System

### How In-App Calls Work

**Setup (Happens Automatically):**
- When you tap **Call**, a connection is established
- No need to dial numbers
- Call routing through secure servers
- Encryption applied automatically
- Your actual phone number is never shared

**Call Flow:**

```
Customer Taps "Call Vendor"
           │
           ▼
    [Connection Request]
           │
           ▼
Vendor Receives Notification
           │
           ▼
  Vendor Taps "Answer"
           │
           ▼
  [Audio Stream Starts]
           │
           ▼
Crystal Clear Conversation
   (Encrypted, Secure)
           │
           ▼
     Either Side Ends Call
           │
           ▼
  Call Summary Shown
  Duration: 02:45
  Both Can Rate Call
```

**What Makes It Special:**
- **No Phone Number Sharing** - Complete privacy
- **Encryption** - Nobody can listen in
- **Call Recording** - Optional, with consent
- **Clear Audio** - High-quality voice
- **History** - All calls saved in app
- **Rating** - Rate call quality after

**Call Scenarios:**

1. **Customer Calls Vendor:**
   - "Are these items fresh?"
   - "Can you add extra sauce?"
   - "I'll be home in 10 minutes"

2. **Vendor Calls Customer:**
   - "Out of kebab, want something else?"
   - "Your order is ready for pickup"
   - "Do you need extra items?"

3. **Customer Calls Driver:**
   - "Where are you?"
   - "Building code is 1234"
   - "I'm ready to receive"

4. **Driver Calls Customer:**
   - "I'm outside your building"
   - "Doorbell doesn't work, coming to window"
   - "Which door should I use?"

5. **Operator Calls Driver:**
   - "New order assigned to you"
   - "Can you take this route instead?"
   - "Check the order details"

**Safety Features:**
- Both parties must consent to recording
- Call quality monitored automatically
- Offensive behavior reported/blocked
- Call history for dispute resolution

---

## 7. Notification & Push Alerts

### What Notifications Look Like

**Order Status Updates:**
- 🔔 "Your order has been accepted!"
- 🔔 "Chef is preparing your order"
- 🔔 "Your order is on the way!"
- 🔔 "Driver is 5 minutes away"
- 🔔 "Your order has arrived!"

**Incoming Calls:**
- 📞 "Incoming call from Ali (Restaurant)"
- 📞 "Incoming call from Driver"
- 📞 "Incoming call from Operator"

**Promotions:**
- 🎉 "New offer: 20% off pizzas!"
- 🎉 "You're a top customer! Enjoy 500 Tomans credit"

**General:**
- ⚠️ "Order cancelled. Refund processing..."
- ✅ "Payment verified successfully"
- 🔐 "Someone logged in from a new device"

**Customization:**
- Turn notifications on/off in Settings
- Choose notification sounds
- Choose notification vibration
- Do Not Disturb mode scheduling

---

## 8. Payment & Security

### Payment Methods (User View)

**When Checking Out, Choose:**

1. **💳 Online Payment (Zarinpal)**
   - Tap "Online Payment"
   - Redirected to secure payment page
   - Enter card details
   - Choose installment option (if available)
   - Confirm payment
   - Return to app (payment verified)
   - ✅ Instant order confirmation

2. **💵 Cash on Delivery**
   - Pay driver directly
   - Driver has change
   - Receipt provided
   - No online risk

3. **🏧 Card with Driver**
   - Driver has mobile card reader
   - Pay when order arrives
   - Secure transaction
   - Receipt emailed

### Security Features

**Your Data is Protected:**
- 🔒 SSL encryption (all data encrypted)
- 🔒 Secure servers (data stored securely)
- 🔒 Payment PCI compliant (card data safe)
- 🔒 Account protection (strong passwords)
- 🔒 Two-factor optional (extra security)

**What We Don't Share:**
- ✅ Your password (even we can't see it)
- ✅ Your card details (stored encrypted)
- ✅ Your actual phone number (with vendors)
- ✅ Your home address (with driver, partially masked)
- ✅ Your location history (deleted after 7 days)

**Your Privacy:**
- "Privacy Policy" explains everything
- We never sell your data
- You can delete your account anytime
- You can request data export

---

## 9. Key Menu Screens Summary

### Navigation Flow

```
Login Screen
    │
    ▼
Home Screen (Categories)
    │
    ├─→ Browse → Vendor → Item → Add to Cart
    │
    ├─→ Search → Find Items → Add to Cart
    │
    ├─→ Cart → Checkout → Payment → Order Tracking
    │
    ├─→ Profile
    │   ├─ Saved Addresses
    │   ├─ Order History
    │   ├─ Payment Methods
    │   ├─ Settings
    │   └─ Help
    │
    └─→ Menu (Secondary)
        ├─ My Orders
        ├─ Settings
        ├─ Help & Support
        └─ Logout
```

### Color Coding by Status

| Status | Color | Icon | Meaning |
|--------|-------|------|---------|
| Pending/Processing | Orange | ⏳ | Waiting for vendor |
| Active/In Progress | Blue | 🔄 | Order is moving |
| Success/Completed | Green | ✅ | Order delivered |
| Cancelled/Failed | Red | ❌ | Order couldn't complete |
| Closed/Unavailable | Gray | 🚫 | Not available |

---

## 10. User Experience Principles

### Design Philosophy

**Beauty + Simplicity:**
- Clean interfaces without clutter
- Intuitive navigation (always know where you are)
- One action per screen (focus on task)
- Consistent design language (same buttons, colors, fonts)

**Speed:**
- Fast load times (optimized images)
- Smooth animations (no jank)
- Real-time updates (live maps, status)
- Minimal taps to complete task (3-4 max)

**Reliability:**
- Automatic syncing (changes saved instantly)
- Offline support (view cached data if offline)
- Auto-recovery (reconnect if connection drops)
- Never lose data (always backed up)

**Accessibility:**
- Large readable text (14px minimum)
- High contrast (white text on dark background)
- Farsi-first design (RTL language support)
- Dark mode available (eye comfort)

**Trust:**
- Transparent pricing (no hidden fees)
- Clear status updates (always know what's happening)
- Call recording transparency (you're informed)
- Privacy-first (your data is your own)

---

## 11. Quick Tips for Users

### Customer Tips
- **Save Addresses** for faster checkout
- **Use Promo Codes** for discounts
- **Rate Restaurants** to help others
- **Enable Location** for accurate tracking
- **Allow Notifications** for order updates

### Operator Tips
- **Check Vendor Board** regularly for new orders
- **Monitor Driver Availability** to optimize routes
- **Track Analytics** to find peak hours
- **Call Vendors** for quick issue resolution
- **Keep Notes** on vendor special handling

### Driver Tips
- **Keep App Updated** for best performance
- **Charge Phone Fully** for long shifts
- **Check Orders** immediately after accepting
- **Call for Directions** if address unclear
- **Rate Customers** to help other drivers

---

**Version**: 1.0  
**Last Updated**: July 2025  
**Platform**: iOS, Android, Web  
**Primary Language**: Persian (Farsi)  
**Design Philosophy**: Simple, Fast, Beautiful, Trustworthy

