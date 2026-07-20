"""
Populate the database with Tehran demo data for the GetirStyleDeliveryUi v2 Flutter app.

Idempotent: safe to re-run (uses get_or_create on phone / business_name keys).

Demo customer login: 09121111111 / demo1234
"""
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.accounts.models import OperatorProfile, VendorProfile
from apps.catalog.models import Category, DiningTable, HomeBanner, HomeFeaturedItem, Item, VenuePanorama
from apps.orders.models import Order, OrderItem

User = get_user_model()

DEMO_CUSTOMER = {'phone': '09121111111', 'password': 'demo1234', 'full_name': 'علی مشتری'}

DEMO_PANORAMA_URL = (
  'https://photo-sphere-viewer-data.netlify.app/assets/sphere.jpg'
)

# (phone, name, address, description, lat, lng, cover_url, panorama_url)
RESTAURANTS = [
  (
    '09122222001', 'رستوران سنتی هفت‌خوان', 'خیابان ولیعصر، تهران',
    'غذاهای ایرانی اصیل در فضایی سنتی — رزرو میز با نمای ۳۶۰°',
    '35.721900', '51.334700',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80',
    DEMO_PANORAMA_URL,
  ),
  (
    '09122222011', 'رستوران دریایی آبشار', 'بلوار دریا، شمال تهران',
    'غذاهای دریایی تازه با نمای دریا و فضای دریایی',
    '35.804000', '51.434000',
    'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=1200&q=80',
    'https://cdn.aframe.io/360-image-gallery-boilerplate/img/city.jpg',
  ),
  (
    '09122222012', 'کافه رستوران آسمان', 'برج میلاد، تهران',
    'فود مدرن و قهوه تخصصی با نمای پانورامای شهر',
    '35.744800', '51.375300',
    'https://images.unsplash.com/photo-1550966841-3edb53c0884a?w=1200&q=80',
    DEMO_PANORAMA_URL,
  ),
  (
    '09122222013', 'لا پاستا', 'جردن، بلوار نلسون ماندela',
    'آشپزخانه ایتالیایی — پاستا تازه و پیتزا تنوری',
    '35.757500', '51.412000',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200&q=80',
    'https://cdn.aframe.io/360-image-gallery-boilerplate/img/sechelt.jpg',
  ),
  (
    '09122222014', 'خانه گیلان', 'پاسداران، تهران',
    'طعم اصیل شمال — ماهی دودی، برنج طارم و خورشت‌های محلی',
    '35.768000', '51.465000',
    'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=1200&q=80',
    DEMO_PANORAMA_URL,
  ),
]

DINE_IN_TABLES = [
  ('Table 1', -90, 0, 2),
  ('Table 2', -45, -5, 4),
  ('Table 3', 0, 0, 2),
  ('Table 4', 45, -5, 4),
  ('Table 5', 90, 0, 6),
  ('Table 6', 135, -8, 2),
  ('Table 7', 180, 0, 4),
  ('Table 8', -135, -5, 2),
]

VENDORS = [
  # (phone, business_name, category_slug, address, description)
  ('09122222002', 'پیتزا پارما', 'getir_style_delivery_ui-food', 'جردن، تهران', 'پیتزا و فست‌فود ایتالیایی'),
  ('09122222003', 'آبمیوه بستنی میوه‌ای', 'getir_style_delivery_ui-drink', 'سعادت‌آباد، تهران', 'آبمیوه تازه و بستنی'),
  ('09122222004', 'کافه دون', 'getir_style_delivery_ui-drink', 'ونک، تهران', 'قهوه تخصصی و نوشیدنی گرم'),
  ('09122222005', 'شیرینی‌سرای نادری', 'getir_style_delivery_ui-dessert', 'میدان ونک، تهران', 'شیرینی و کیک خانگی'),
  ('09122222006', 'بستنی ۹۹', 'getir_style_delivery_ui-dessert', 'پاسداران، تهران', 'بستنی سنتی و مدرن'),
  ('09122222007', 'داروخانه شبانه‌روزی سلامت', 'getir_style_delivery_ui-medic', 'تهرانپارس، تهران', 'دارو و محصولات بهداشتی'),
  ('09122222008', 'داروخانه دکتر احمدی', 'getir_style_delivery_ui-medic', 'شریعتی، تهران', 'داروخانه معتبر شمال تهران'),
  ('09122222009', 'سوپرمارکت رفاه', 'getir_style_delivery_ui-groceries', 'یوسف‌آباد، تهران', 'خواربار و مواد غذایی'),
  ('09122222010', 'میوه و سبزیجات تازه', 'getir_style_delivery_ui-groceries', 'جنت‌آباد، تهران', 'میوه و سبزی روز'),
]

ITEMS_BY_SLUG = {
  'getir_style_delivery_ui-restaurant': [],  # per-restaurant menus in RESTAURANT_ITEMS
  'getir_style_delivery_ui-food': [
    ('چلو کباب کوبیده', 'دو سیخ کوبیده با برنج ایرانی', 185000, 4.8),
    ('زرشک پلو با مرغ', 'ران مرغ سرخ‌شده با زرشک', 165000, 4.6),
    ('قرمه سبزی', 'خورشت قرمه سبزی با گوشت گوسفندی', 145000, 4.7),
    ('پیتزا مخصوص', 'پیتزا ۳۰ سانتی با پنیر موزارلا', 220000, 4.5),
    ('برگر دوبل', 'دو عدد همبرگر با سس مخصوص', 175000, 4.4),
    ('سالاد سزار', 'کاهو، مرغ گریل و سس سزار', 95000, 4.3),
  ],
  'getir_style_delivery_ui-drink': [
    ('آب پرتقال تازه', '۳۵۰ میلی‌لیتر آبمیوه طبیعی', 45000, 4.5),
    ('موهیتو نعنا', 'نوشیدنی خنک با نعنا تازه', 55000, 4.6),
    ('لاته کارامل', 'قهوه اسپرسو با شیر و سس کارامل', 75000, 4.7),
    ('اسموتی توت‌فرنگی', 'اسموتی میوه‌ای بدون شکر', 65000, 4.4),
    ('دوغ محلی', 'دوغ خانگی ۵۰۰ میلی‌لیتر', 25000, 4.2),
  ],
  'getir_style_delivery_ui-dessert': [
    ('باقلوا پسته‌ای', 'باقلوای تبریزی با پسته درجه یک', 120000, 4.9),
    ('کیک شکلاتی', 'کیک شکلاتی ۴ نفره', 185000, 4.6),
    ('بستنی سنتی زعفرانی', 'بستنی سنتی با زعفران اعلا', 55000, 4.8),
    ('پشمک وانیلی', 'پشمک تازه وانیلی', 35000, 4.3),
    ('دسر مخصوص', 'دسر شکلاتی با میوه فصل', 85000, 4.5),
  ],
  'getir_style_delivery_ui-medic': [
    ('ماسک N95', 'بسته ۵ عددی ماسک N95', 95000, 4.5),
    ('ویتامین D', 'مکمل ویتامین D ۶۰ عددی', 185000, 4.6),
    ('دستگاه فشارسنج', 'فشارسنج دیجیتال بازویی', 1250000, 4.7),
    ('کرم ضدآفتاب', 'کرم SPF50 مناسب پوست حساس', 245000, 4.4),
    ('شربت سرفه کودک', 'شربت گیاهی سرفه', 78000, 4.3),
  ],
  'getir_style_delivery_ui-groceries': [
    ('شیر پاستوریزه ۱ لیتری', 'شیر کم‌چرب تازه', 42000, 4.5),
    ('نان لواش بسته‌ای', 'نان لواش ۵ عددی', 28000, 4.2),
    ('سیب زمینی ۱ کیلو', 'سیب زمینی درجه یک', 35000, 4.4),
    ('گوجه فرنگی ۱ کیلو', 'گوجه تازه محلی', 48000, 4.3),
    ('ماست پروبیوتیک', 'ماست ۹۰۰ گرمی', 55000, 4.6),
    ('تخم‌مرغ ۱۵ تایی', 'تخم‌مرغ محلی', 95000, 4.5),
    ('برنج هاشمی ۵ کیلو', 'برنج درجه یک شمال', 850000, 4.8),
    ('روغن آفتابگردان', 'روغن ۱.۸ لیتری', 285000, 4.4),
    ('نوشابه خانواده', 'نوشابه ۱.۵ لیتری', 38000, 4.1),
    ('چیپس مزه‌دار', 'چیپس ۱۵۰ گرمی', 45000, 4.0),
    ('شکلات تلخ', 'شکلات ۷۰٪ کاکائو', 125000, 4.6),
    ('دستمال کاغذی', 'بسته ۳ عددی', 65000, 4.2),
  ],
}


RESTAURANT_ITEMS = {
  'رستوران سنتی هفت‌خوان': [
    ('چلو کباب کوبیده', 'دو سیخ کوبیده با برنج ایرانی', 185000, 4.8),
    ('زرشک پلو با مرغ', 'ران مرغ سرخ‌شده با زرشک', 165000, 4.6),
    ('قرمه سبزی', 'خورشت قرمه سبزی با گوشت گوسفندی', 145000, 4.7),
    ('سالاد شیرازی', 'خیار، گوجه و پیاز تازه', 45000, 4.4),
  ],
  'رستوران دریایی آبشار': [
    ('ماهی شکم‌پر', 'ماهی تازه شمال با سبزی و گردو', 245000, 4.9),
    ('میگو سوخاری', 'میگو تازه با سس مخصوص', 195000, 4.7),
    ('خوراک ماهی قزل‌آلا', 'فیله ماهی کبابی با سبزی', 210000, 4.8),
    ('سوپ دریایی', 'سوپ میگو و سبزیجات', 85000, 4.5),
  ],
  'کافه رستوران آسمان': [
    ('استیک ریبای', 'استیک ۳۰۰ گرمی با سس قارچ', 385000, 4.9),
    ('برگر گourmet', 'گوشت Angus با پنیر بلو', 195000, 4.7),
    ('پاستا آلفردو', 'فتوچینی با سس خامه‌ای', 165000, 4.6),
    ('چیزکیک نیویورکی', 'دسر کلاسیک با توت‌فرنگی', 95000, 4.8),
  ],
  'لا پاستا': [
    ('پاستا بولونز', 'اسپاگتی با سس گوشت ایتالیایی', 175000, 4.8),
    ('پیتزا مارگاریتا', 'پیتزا چوبی با ریحان تازه', 155000, 4.7),
    ('راويولی اسفناج', 'پاستا دست‌ساز با پنیر ریکوتا', 185000, 4.6),
    ('تیramisu', 'دسر ایتالیایی کلاسیک', 85000, 4.9),
  ],
  'خانه گیلان': [
    ('ماهی سفید کبابی', 'ماهی تازه با رب انار', 225000, 4.9),
    ('باقالی پلو با ماهیچه', 'برنج طارم با ماهیچه گوسفندی', 265000, 4.8),
    ('خورشت باقلا قاتق', 'خورشت محلی با تخم‌مرغ و سیر', 135000, 4.7),
    ('کلوچه فومن', 'شیرینی محلی گیلان', 55000, 4.5),
  ],
}


class Command(BaseCommand):
  help = 'Seed demo vendors, items, and a test customer for the Flutter app.'

  def add_arguments(self, parser):
    parser.add_argument(
      '--flush-demo',
      action='store_true',
      help='Delete demo vendors/items before re-seeding.',
    )

  @transaction.atomic
  def handle(self, *args, **options):
    call_command('loaddata', 'categories', verbosity=0)

    if options['flush_demo']:
      self._flush_demo()

    customer = self._ensure_customer()
    vendors = self._ensure_vendors()
    vendors.extend(self._ensure_restaurants())
    item_count = self._ensure_items(vendors)
    dine_in_count = self._ensure_dine_in(vendors)
    order_count = self._ensure_sample_orders(customer, vendors)
    promo_count = self._ensure_home_promos()

    self.stdout.write(self.style.SUCCESS(
      f'Demo data ready: 1 customer, {len(vendors)} vendors, '
      f'{item_count} items, {dine_in_count} dine-in tables, {order_count} orders, {promo_count} home promos.\n'
      f'Login: phone={DEMO_CUSTOMER["phone"]} password={DEMO_CUSTOMER["password"]}'
    ))

  def _flush_demo(self):
    restaurant_phones = [r[0] for r in RESTAURANTS]
    phones = [DEMO_CUSTOMER['phone']] + restaurant_phones + [v[0] for v in VENDORS]
    VendorProfile.objects.filter(user__phone__in=phones).delete()
    Item.objects.filter(vendor__user__phone__in=phones).delete()
    User.objects.filter(phone__in=phones).delete()
    self.stdout.write('Flushed previous demo users/vendors/items.')

  def _ensure_customer(self):
    user, created = User.objects.get_or_create(
      phone=DEMO_CUSTOMER['phone'],
      defaults={'full_name': DEMO_CUSTOMER['full_name'], 'role': 'customer', 'city': 'Tehran'},
    )
    if created or not user.check_password(DEMO_CUSTOMER['password']):
      user.set_password(DEMO_CUSTOMER['password'])
      user.city = 'Tehran'
      user.full_name = DEMO_CUSTOMER['full_name']
      user.save()
    return user

  def _ensure_vendors(self):
    vendors = []
    for phone, name, slug, address, desc in VENDORS:
      cat = Category.objects.get(slug=slug)
      user, _ = User.objects.get_or_create(
        phone=phone,
        defaults={'full_name': name, 'role': 'vendor', 'city': 'Tehran'},
      )
      if not user.check_password('vendor1234'):
        user.set_password('vendor1234')
        user.save()
      vendor, _ = VendorProfile.objects.get_or_create(
        user=user,
        defaults={
          'business_name': name,
          'category': cat,
          'address': address,
          'city': 'Tehran',
          'phone': phone,
          'description': desc,
          'rating': Decimal('4.60'),
          'rating_count': 120,
        },
      )
      vendors.append(vendor)
    return vendors

  def _ensure_restaurants(self):
    cat = Category.objects.get(slug='getir_style_delivery_ui-restaurant')
    vendors = []
    for phone, name, address, desc, lat, lng, cover, pano_url in RESTAURANTS:
      user, _ = User.objects.get_or_create(
        phone=phone,
        defaults={'full_name': name, 'role': 'vendor', 'city': 'Tehran'},
      )
      if not user.check_password('vendor1234'):
        user.set_password('vendor1234')
        user.save()
      vendor, _ = VendorProfile.objects.get_or_create(
        user=user,
        defaults={
          'business_name': name,
          'category': cat,
          'address': address,
          'city': 'Tehran',
          'phone': phone,
          'description': desc,
          'rating': Decimal('4.75'),
          'rating_count': 240,
          'supports_dine_in': True,
          'latitude': Decimal(lat),
          'longitude': Decimal(lng),
          'cover_image_url': cover,
        },
      )
      vendor.category = cat
      vendor.business_name = name
      vendor.address = address
      vendor.description = desc
      vendor.supports_dine_in = True
      vendor.latitude = Decimal(lat)
      vendor.longitude = Decimal(lng)
      vendor.cover_image_url = cover
      vendor.save()
      self._ensure_restaurant_panorama(vendor, pano_url)
      vendors.append(vendor)
    return vendors

  def _ensure_restaurant_panorama(self, vendor, panorama_url):
    panorama, _ = VenuePanorama.objects.get_or_create(
      vendor=vendor,
      title='Main dining hall',
      defaults={
        'image_url': panorama_url,
        'initial_yaw': 0,
        'is_active': True,
      },
    )
    if panorama.image_url != panorama_url:
      panorama.image_url = panorama_url
      panorama.is_active = True
      panorama.save(update_fields=['image_url', 'is_active'])
    for label, yaw, pitch, cap in DINE_IN_TABLES:
      DiningTable.objects.get_or_create(
        vendor=vendor,
        label=label,
        defaults={
          'panorama': panorama,
          'hotspot_yaw': yaw,
          'hotspot_pitch': pitch,
          'capacity': cap,
          'status': 'available',
        },
      )

  def _ensure_dine_in(self, vendors):
    dine_in_vendors = [v for v in vendors if v.supports_dine_in]
    if not dine_in_vendors:
      return 0
    total = 0
    for vendor in dine_in_vendors:
      total += DiningTable.objects.filter(vendor=vendor).count()
    return total

  def _ensure_items(self, vendors):
    count = 0
    for vendor in vendors:
      slug = vendor.category.slug if vendor.category else 'getir_style_delivery_ui-food'
      if slug == 'getir_style_delivery_ui-restaurant':
        catalog = RESTAURANT_ITEMS.get(vendor.business_name, [])
      else:
        catalog = ITEMS_BY_SLUG.get(slug, ITEMS_BY_SLUG['getir_style_delivery_ui-food'])
      for idx, (name, desc, price, rating) in enumerate(catalog):
        _, created = Item.objects.get_or_create(
          vendor=vendor,
          name=name,
          defaults={
            'category': vendor.category,
            'description': desc,
            'price': price,
            'city': 'Tehran',
            'rating': Decimal(str(rating)),
            'rating_count': 40 + idx * 5,
            'is_available': True,
          },
        )
        if created:
          count += 1
    return Item.objects.filter(vendor__in=vendors).count()

  def _ensure_sample_orders(self, customer, vendors):
    if Order.objects.filter(customer=customer).exists():
      return Order.objects.filter(customer=customer).count()

    grocery = next(v for v in vendors if v.category and v.category.slug == 'getir_style_delivery_ui-groceries')
    food = next(v for v in vendors if v.category and v.category.slug == 'getir_style_delivery_ui-food')

    orders_data = [
      (grocery, 'delivered', [('شیر پاستوریزه ۱ لیتری', 2), ('نان لواش بسته‌ای', 3)]),
      (food, 'preparing', [('چلو کباب کوبیده', 1), ('زرشک پلو با مرغ', 1)]),
      (food, 'pending', [('پیتزا مخصوص', 1)]),
    ]

    for vendor, status, lines in orders_data:
      total = 0
      order = Order.objects.create(
        customer=customer,
        vendor=vendor,
        delivery_type='in_city',
        payment_method='cash',
        delivery_address='خیابان ولیعصر، پلاک ۱۲۳',
        delivery_city='Tehran',
        customer_notes='',
        status=status,
        total_amount=0,
      )
      for item_name, qty in lines:
        item = Item.objects.get(vendor=vendor, name=item_name)
        OrderItem.objects.create(
          order=order,
          item=item,
          quantity=qty,
          unit_price=item.price,
        )
        total += item.price * qty
      order.total_amount = total
      order.save(update_fields=['total_amount'])

    return Order.objects.filter(customer=customer).count()

  def _ensure_home_promos(self):
    count = 0
    banners = [
      ('ارسال رایگان امروز', 'سفارش بالای ۳۰۰ هزار تومان', 'getir_style_delivery_ui-food', 0),
      ('تخفیف سوپرمارکت', 'تا ۲۰٪ روی خواربار', 'getir_style_delivery_ui-groceries', 1),
    ]
    for title, subtitle, slug, order in banners:
      _, created = HomeBanner.objects.get_or_create(
        title=title,
        defaults={
          'subtitle': subtitle,
          'category_slug': slug,
          'city': '',
          'display_order': order,
          'is_active': True,
        },
      )
      if created:
        count += 1

    pizza = Item.objects.filter(name='پیتزا مخصوص').first()
    kebab = Item.objects.filter(name='چلو کباب کوبیده').first()
    milk = Item.objects.filter(name='شیر پاستوریزه ۱ لیتری').first()
    if pizza:
      _, created = HomeFeaturedItem.objects.get_or_create(
        item=pizza,
        section=HomeFeaturedItem.SECTION_DISCOUNTED,
        defaults={
          'sale_price': 189000,
          'badge_text': 'ویژه',
          'city': '',
          'display_order': 0,
        },
      )
      if created:
        count += 1
    if kebab:
      _, created = HomeFeaturedItem.objects.get_or_create(
        item=kebab,
        section=HomeFeaturedItem.SECTION_TODAY_SPECIAL,
        defaults={
          'badge_text': 'امروز',
          'city': '',
          'display_order': 0,
        },
      )
      if created:
        count += 1
    if milk:
      _, created = HomeFeaturedItem.objects.get_or_create(
        item=milk,
        section=HomeFeaturedItem.SECTION_DISCOUNTED,
        defaults={
          'sale_price': 35000,
          'badge_text': '۲۰٪',
          'city': '',
          'display_order': 1,
        },
      )
      if created:
        count += 1
    return count
