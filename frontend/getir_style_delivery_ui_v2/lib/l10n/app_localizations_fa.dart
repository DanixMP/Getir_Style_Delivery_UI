// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'GETIR_STYLE_DELIVERY_UI';

  @override
  String get appTagline => 'سریع‌ترین تحویل در جیب شما';

  @override
  String get heroTitle => 'یک دوز شادی!';

  @override
  String get heroSubtitle =>
      'سفارش‌های GETIR_STYLE_DELIVERY_UI در چند دقیقه به درب شما می‌رسند!';

  @override
  String get addAddress => 'افزودن آدرس';

  @override
  String get noAddress => 'اطلاعات آدرس موجود نیست';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get enterPhone => 'شماره موبایل خود را وارد کنید';

  @override
  String get continueButton => 'ادامه';

  @override
  String get orContinueWith => 'یا ادامه با';

  @override
  String get troubleLoggingIn => 'مشکل در ورود دارید؟';

  @override
  String get termsAgreement =>
      'با ادامه، شما با شرایط استفاده و سیاست حریم خصوصی موافقت می‌کنید.';

  @override
  String get termsOfService => 'شرایط استفاده';

  @override
  String get privacyPolicy => 'سیاست حریم خصوصی';

  @override
  String get enterOtp => 'کد تأیید را وارد کنید';

  @override
  String otpSent(String phone) {
    return 'کد به $phone ارسال شد';
  }

  @override
  String get verify => 'تأیید';

  @override
  String get resendCode => 'ارسال مجدد کد';

  @override
  String get navHome => 'خانه';

  @override
  String get navDineIn => 'رستوران';

  @override
  String get navSearch => 'جستجو';

  @override
  String get navCategories => 'دسته‌بندی';

  @override
  String get navProfile => 'پروفایل';

  @override
  String get navOffers => 'تخفیف‌ها';

  @override
  String get navWallet => 'کیف پول';

  @override
  String get profile => 'پروفایل';

  @override
  String get login => 'ورود';

  @override
  String get manageAccount => 'مدیریت حساب و سفارش‌ها';

  @override
  String get liveSupport => 'پشتیبانی آنلاین';

  @override
  String get myAddresses => 'آدرس‌های من';

  @override
  String get favouriteProducts => 'محصولات مورد علاقه';

  @override
  String get support => 'پشتیبانی';

  @override
  String get language => 'زبان';

  @override
  String get version => 'نسخه';

  @override
  String get signOut => 'خروج';

  @override
  String get exclusiveOffer => 'پیشنهاد ویژه';

  @override
  String get offerDescription => '۵۰٪ تخفیف برای سه سفارش اول. فقط امروز!';

  @override
  String get claimNow => 'دریافت';

  @override
  String get serviceGetirStyleDeliveryUi => 'GETIR_STYLE_DELIVERY_UI';

  @override
  String get serviceGetirStyleDeliveryUiDesc => 'بیش از ۲,۰۰۰ محصول';

  @override
  String get serviceGetirStyleDeliveryUiHint => 'در چند دقیقه';

  @override
  String get serviceFinans => 'GETIR_STYLE_DELIVERY_UIفایننس';

  @override
  String get serviceMore => 'GSDU More';

  @override
  String get serviceMoreDesc => 'بیش از ۵,۰۰۰ محصول';

  @override
  String get serviceMoreHint => 'با قیمت مناسب';

  @override
  String get serviceFood => 'GETIR_STYLE_DELIVERY_UIفود';

  @override
  String get serviceRestaurant => 'GETIR_STYLE_DELIVERY_UIرستوران';

  @override
  String get serviceLocals => 'GETIR_STYLE_DELIVERY_UIلوکالز';

  @override
  String get serviceWater => 'یولدآب';

  @override
  String get serviceTaxi => 'GETIR_STYLE_DELIVERY_UIبیتاکسی';

  @override
  String get promotions => 'تخفیف‌ها';

  @override
  String get whatsNew => 'جدیدترین‌ها';

  @override
  String get searchHint => 'جستجوی محصول، رستوران...';

  @override
  String get searchPageSubtitle => 'تخفیف‌ها و کشف محصولات';

  @override
  String get browseAllProducts => 'مرور همه';

  @override
  String searchResultsFor(String query) {
    return 'نتایج «$query»';
  }

  @override
  String get recentSearches => 'جستجوهای اخیر';

  @override
  String get popularCategories => 'دسته‌بندی‌های محبوب';

  @override
  String get walletBalance => 'موجودی GETIR_STYLE_DELIVERY_UI';

  @override
  String get topUp => 'شارژ';

  @override
  String get transfer => 'انتقال';

  @override
  String get paymentMethods => 'روش‌های پرداخت';

  @override
  String get recentTransactions => 'تراکنش‌های اخیر';

  @override
  String get aiAssistant => 'هوش مصنوعی GETIR_STYLE_DELIVERY_UI';

  @override
  String get aiGreeting =>
      'سلام! من دستیار GETIR_STYLE_DELIVERY_UI هستم. چطور می‌توانم کمکتان کنم؟';

  @override
  String get aiPlaceholder => 'هر سوالی بپرسید...';

  @override
  String get suggestionOrder => 'پیگیری سفارش';

  @override
  String get suggestionDeals => 'نمایش تخفیف‌ها';

  @override
  String get suggestionSupport => 'تماس با پشتیبانی';

  @override
  String get langPersian => 'فارسی';

  @override
  String get langEnglish => 'انگلیسی';

  @override
  String get langArabic => 'عربی';

  @override
  String get langTurkish => 'ترکی';

  @override
  String get selectLanguage => 'انتخاب زبان';

  @override
  String get countryCode => '+۹۸';

  @override
  String get phonePlaceholder => '۹XX XXX XXXX';

  @override
  String get freeDelivery => 'ارسال رایگان';

  @override
  String get discount50 => '۵۰٪ تخفیف';

  @override
  String get newBadge => 'جدید';

  @override
  String get availableBalance => 'موجودی قابل استفاده';

  @override
  String get addMoney => 'افزودن موجودی';

  @override
  String get send => 'ارسال';

  @override
  String get transactionHistory => 'تاریخچه تراکنش';

  @override
  String get manageCards => 'مدیریت کارت‌ها';

  @override
  String get finansIntegration => 'یکپارچه‌سازی GETIR_STYLE_DELIVERY_UIفایننس';

  @override
  String get finansIntegrationDesc =>
      'حساب بانکی خود را متصل کنید و از هر سفارش ۱٪ بازگشت وجه بگیرید.';

  @override
  String get couponsAndOffers => 'کوپن‌ها و پیشنهادها';

  @override
  String get seeAll => 'مشاهده همه';

  @override
  String get addNew => 'افزودن';

  @override
  String get addCouponCode => 'افزودن کد تخفیف';

  @override
  String get switchService => 'همه سرویس‌ها';

  @override
  String get chooseService => 'یک سرویس انتخاب کنید';

  @override
  String get serviceHomePlaceholder => 'دسته‌بندی‌ها را ببینید و سفارش دهید.';

  @override
  String get finansTickerValue => '۴۵٫۸۲';

  @override
  String get finansTickerGold => 'XAU ۶٬۳۸۴٫۶';

  @override
  String get couponDiscountTitle => 'تخفیف ۲۰ هزار تومانی';

  @override
  String get couponDiscountDesc => 'برای سفارش‌های بالای ۱۵۰ هزار تومان';

  @override
  String get couponFreeDeliveryDesc => 'برای خرید امروز از سوپرمارکت';

  @override
  String get fastestBadge => 'سریع‌ترین';

  @override
  String get getirStyleDeliveryUiPlusBadge => 'GETIR_STYLE_DELIVERY_UI+';

  @override
  String get mainSpendingCard => 'کارت اصلی خرید';

  @override
  String get digitalWallet => 'کیف پول دیجیتال';

  @override
  String get cardMaskedVisa => '**** **** **** ۴۲۹۱';

  @override
  String get cardMaskedMaster => '**** **** **** ۸۸۰۲';

  @override
  String get groceryOrder => 'سفارش سوپرمارکت';

  @override
  String get transactionToday => 'امروز، ۱۴:۲۰';

  @override
  String get balanceAmount => '۱٬۲۵۰٬۰۰۰ تومان';

  @override
  String get transactionDebit => '- ۴۵٬۰۰۰ تومان';

  @override
  String get transactionCredit => '+ ۵۰۰٬۰۰۰ تومان';

  @override
  String get limitedTime => 'مدت محدود';

  @override
  String get paymentProviderShaparak => 'شاپرک';

  @override
  String get categoriesTitle => 'دسته‌بندی‌ها';

  @override
  String get minimumOrder => 'حداقل سفارش';

  @override
  String get deliveryLabel => 'تحویل';

  @override
  String get valuePlaceholder => '--';

  @override
  String get catBeverages => 'نوشیدنی';

  @override
  String get catSnacks => 'تنقلات';

  @override
  String get catMilkDairy => 'لبنیات';

  @override
  String get catFruitsVeggies => 'میوه و سبزی';

  @override
  String get catBreakfast => 'صبحانه';

  @override
  String get catBakedGoods => 'نان و شیرینی';

  @override
  String get catIceCream => 'بستنی';

  @override
  String get catFood => 'غذا';

  @override
  String get catReadyToEat => 'آماده مصرف';

  @override
  String get catMeatPoultry => 'گوشت و مرغ';

  @override
  String get catFitAndForm => 'فیت و فرم';

  @override
  String get catHomeCare => 'خانه و نظافت';

  @override
  String get aboutApp => 'درباره برنامه';

  @override
  String get aboutAppHeroSubtitle => 'پلتفرم تحویل آن‌-demand ایرانی';

  @override
  String get aboutDeveloper => 'درباره توسعه‌دهنده';

  @override
  String get technology => 'فناوری';

  @override
  String get stack => 'استک';

  @override
  String get stackSubtitle => 'فلاتر، جنگو، PostgreSQL، Redis، نشان، FCM';

  @override
  String get license => 'مجوز';

  @override
  String get licenseTitle => 'فقط برای آموزش';

  @override
  String get licenseSubtitle => 'شرایط استفاده از این پروژه آموزشی';

  @override
  String get licenseBody =>
      'این پروژه فقط برای اهداف آموزشی است. استفاده از آن برای کسب‌وکار یا هر هدف تجاری ممنوع است و اخلاقی نیست.';

  @override
  String get noPromotions => 'تخفیفی موجود نیست.';

  @override
  String get swipeTechStack => 'برای مشاهده استک فناوری بکشید';

  @override
  String get betaPhase => 'بتا';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName. نسخه آزمایشی (بتا).';
  }

  @override
  String get accountSection => 'حساب کاربری';

  @override
  String get editProfile => 'ویرایش پروفایل';

  @override
  String get editProfileSubtitle => 'نام، ایمیل و آواتار';

  @override
  String get myOrders => 'سفارش‌های من';

  @override
  String get myOrdersSubtitle => 'تاریخچه و وضعیت سفارش‌ها';

  @override
  String get addressManageSubtitle => 'مدیریت آدرس‌های تحویل';

  @override
  String get settingsSection => 'تنظیمات';

  @override
  String get supportSubtitle => 'راهنما و تماس با پشتیبانی';

  @override
  String get devDebugSubtitle => 'ابزارهای توسعه‌دهنده';

  @override
  String get developerRole => 'توسعه‌دهنده ارشد فلاتر';

  @override
  String get navTracking => 'پیگیری';

  @override
  String get techFlutter => 'فلاتر';

  @override
  String get techFlutterDesc => 'رابط کاربری چندسکویی مشتری';

  @override
  String get techDjango => 'جنگو';

  @override
  String get techDjangoDesc => 'API و بک‌اند بلادرنگ';

  @override
  String get techWebSocket => 'وب‌سوکت';

  @override
  String get techWebSocketDesc => 'پیگیری زنده سفارش و پیک';

  @override
  String get techNeshan => 'نقشه نشان';

  @override
  String get techNeshanDesc => 'نقشه، مسیریابی و ژئوکدینگ';

  @override
  String get techPostgres => 'PostgreSQL';

  @override
  String get techPostgresDesc => 'پایگاه داده اصلی';

  @override
  String get techPostgresDetail =>
      'سفارش‌ها، کاتالوگ، حساب‌ها، کیف پول و داده‌های رستوران در PostgreSQL با migrationهای Django ذخیره می‌شوند.';

  @override
  String get techPostgresUse1 => 'سفارش، فروشنده، محصول و میزهای dine-in';

  @override
  String get techPostgresUse2 => 'پروفایل کاربر، کیف پول و تخصیص پیک';

  @override
  String get techRedis => 'Redis و Celery';

  @override
  String get techRedisDesc => 'کش، صف و pub/sub بلادرنگ';

  @override
  String get techRedisDetail =>
      'Redis لایه Channels، نگه‌داری موقت میز رستوران و workerهای Celery برای کارهای پس‌زمینه را پشتیبانی می‌کند.';

  @override
  String get techRedisUse1 => 'لایه WebSocket برای ردیابی زنده';

  @override
  String get techRedisUse2 => 'نگه‌داری ۵ دقیقه‌ای میز dine-in';

  @override
  String get techRedisUse3 => 'کارهای پس‌زمینه با Celery';

  @override
  String get techLiveKit => 'LiveKit';

  @override
  String get techLiveKitDesc => 'تماس صوتی درون برنامه';

  @override
  String get techLiveKitDetail =>
      'اتاق‌های LiveKit مشتری و پیک را در حین تحویل وصل می‌کنند. بک‌اند توکن صادر می‌کند؛ اپ Flutter از livekit_client استفاده می‌کند.';

  @override
  String get techLiveKitUse1 => 'صفحه تماس در تب ردیابی';

  @override
  String get techLiveKitUse2 => 'API توکن در ماژول communications';

  @override
  String get techFirebase => 'Firebase FCM';

  @override
  String get techFirebaseDesc => 'اعلان push';

  @override
  String get techFirebaseDetail =>
      'firebase-admin هنگام تغییر وضعیت سفارش یا تخصیص پیک، push ارسال می‌کند. توکن دستگاه برای هر کاربر ذخیره می‌شود.';

  @override
  String get techFirebaseUse1 => 'هشدار وضعیت سفارش و تحویل';

  @override
  String get techFirebaseUse2 => 'ثبت توکن FCM در communications';

  @override
  String get techFlutterDetail =>
      'اپ مشتری (getir_style_delivery_ui_v2) و پیک (getir_style_delivery_ui_peyk) با Provider، Dio و پشتیبانی RTL/فارسی ساخته شده‌اند.';

  @override
  String get techFlutterUse1 => 'خانه، dine-in 360°، سبد و کیف پول';

  @override
  String get techFlutterUse2 => 'نقشه ردیابی زنده با flutter_map';

  @override
  String get techFlutterUse3 => 'ذخیره JWT با flutter_secure_storage';

  @override
  String get techDjangoDetail =>
      'getir_style_delivery_ui_backend API نسخه‌دار REST برای کاتالوگ، سفارش، کیف پول و ردیابی دارد. احراز هویت JWT و پنل unfold.';

  @override
  String get techDjangoUse1 => 'endpointهای کاتالوگ، سفارش و dine-in';

  @override
  String get techDjangoUse2 => 'دسترسی نقش‌محور: مشتری، فروشنده، پیک';

  @override
  String get techDjangoUse3 => 'آپلود رسانه با django-storages';

  @override
  String get techWebSocketDetail =>
      'ASGI با Django Channels جریان موقعیت پیک و وضع سفارش را منتشر می‌کند. تب ردیابی با web_socket_channel متصل می‌شود.';

  @override
  String get techWebSocketUse1 => 'موقعیت زنده پیک روی نقشه';

  @override
  String get techWebSocketUse2 => 'به‌روزرسانی وضعیت بدون polling';

  @override
  String get techNeshanDetail =>
      'کاشی‌های نشان از پروکسی بک‌اند با Api-Key لود می‌شوند. geocoding معکوس برای انتخاب آدرس و مختصات رستوران استفاده می‌شود.';

  @override
  String get techNeshanUse1 => 'انتخاب آدرس و کاشی نقشه ردیابی';

  @override
  String get techNeshanUse2 => 'پین پیش‌نمایش رستوران';

  @override
  String get techNeshanUse3 => 'پروکسی /tracking/tiles/ برای اندروید';

  @override
  String get stackPackagesLabel => 'کتابخانه‌ها و پکیج‌ها';

  @override
  String get stackUsedInLabel => 'کاربرد در GETIR_STYLE_DELIVERY_UI';

  @override
  String get stackViewDetails => 'مشاهده جزئیات';

  @override
  String get cancel => 'انصراف';

  @override
  String get confirm => 'تایید';

  @override
  String get change => 'تغییر';

  @override
  String get save => 'ذخیره';

  @override
  String get currencyToman => 'تومان';

  @override
  String get cartTitle => 'سبد خرید';

  @override
  String get cartEmpty => 'سبد خرید شما خالی است';

  @override
  String get clearCart => 'خالی کردن سبد';

  @override
  String cartTotal(int count) {
    return 'جمع کل ($count)';
  }

  @override
  String get placeOrder => 'ثبت سفارش';

  @override
  String get editCart => 'ویرایش سبد';

  @override
  String get checkoutTitle => 'پرداخت';

  @override
  String get deliveryAddress => 'آدرس تحویل';

  @override
  String get fullAddressHint => 'آدرس کامل را وارد کنید';

  @override
  String get city => 'شهر';

  @override
  String get noteOptional => 'یادداشت (اختیاری)';

  @override
  String get paymentMethod => 'روش پرداخت';

  @override
  String get walletPay => 'کیف پول';

  @override
  String get walletBalanceLoading => 'موجودی…';

  @override
  String walletBalanceLabel(String amount) {
    return 'موجودی: $amount';
  }

  @override
  String get onlinePay => 'پرداخت آنلاین';

  @override
  String get zarinpalGateway => 'درگاه زرین‌پال';

  @override
  String get payAtDoor => 'پرداخت در محل';

  @override
  String get payAtDoorSubtitle => 'نقدی هنگام تحویل';

  @override
  String get payableAmount => 'مبلغ قابل پرداخت';

  @override
  String get cartEmptyError => 'سبد خرید خالی است.';

  @override
  String get enterDeliveryAddress => 'لطفاً آدرس تحویل را وارد کنید.';

  @override
  String get orderPlacedWallet => 'سفارش ثبت شد و از کیف پول پرداخت گردید.';

  @override
  String orderPlacedOnline(String url) {
    return 'سفارش ثبت شد. برای پرداخت آنلاین: $url';
  }

  @override
  String get orderPlacedCash => 'سفارش ثبت شد. پرداخت هنگام تحویل.';

  @override
  String get orderPlaceError => 'خطا در ثبت سفارش.';

  @override
  String get vendorMismatchTitle => 'فروشنده متفاوت';

  @override
  String get vendorMismatchBody =>
      'سبد خرید شامل اقلامی از فروشنده دیگری است. سبد جدید ساخته شود؟';

  @override
  String get newCart => 'سبد جدید';

  @override
  String addedToCart(String name) {
    return '$name به سبد اضافه شد';
  }

  @override
  String get orderStatusPending => 'در انتظار';

  @override
  String get orderStatusAccepted => 'تأیید شده';

  @override
  String get orderStatusPreparing => 'در حال آماده‌سازی';

  @override
  String get orderStatusPickedUp => 'در راه';

  @override
  String get orderStatusDelivered => 'تحویل شده';

  @override
  String get orderStatusCancelled => 'لغو شده';

  @override
  String get ordersTitle => 'سفارش‌های من';

  @override
  String get noOrdersYet => 'هنوز سفارشی ثبت نکرده‌اید';

  @override
  String get orderFallback => 'سفارش';

  @override
  String get deliveryCodeLabel => 'کد تحویل:';

  @override
  String get supportHeroTitle => 'چطور می‌توانیم کمک کنیم؟';

  @override
  String get supportHeroSubtitle =>
      'تیم پشتیبانی GETIR_STYLE_DELIVERY_UI هر روز کنار شماست.';

  @override
  String get contactMethods => 'راه‌های ارتباطی';

  @override
  String get phoneContact => 'تماس تلفنی';

  @override
  String get emailContact => 'ایمیل';

  @override
  String get onlineChat => 'گفت‌وگوی آنلاین';

  @override
  String get onlineChatValue => 'پاسخ‌گویی فوری در اپ';

  @override
  String get businessHours => 'ساعات کاری';

  @override
  String get businessHoursValue => 'هر روز ۹ تا ۲۳';

  @override
  String get faqTitle => 'سوالات پرتکرار';

  @override
  String get faqTrackOrderQ => 'چطور سفارشم را پیگیری کنم؟';

  @override
  String get faqTrackOrderA =>
      'از تب پیگیری می‌توانید موقعیت پیک و مراحل سفارش را روی نقشه ببینید.';

  @override
  String get faqPaymentQ => 'روش‌های پرداخت کدام‌اند؟';

  @override
  String get faqPaymentA =>
      'کیف پول، پرداخت آنلاین و پرداخت در محل پشتیبانی می‌شوند.';

  @override
  String get faqAddressQ => 'چطور آدرس اضافه کنم؟';

  @override
  String get faqAddressA =>
      'از نوار بالای صفحه اصلی یا بخش آدرس‌های من در پروفایل.';

  @override
  String get profileUpdated => 'پروفایل به‌روزرسانی شد';

  @override
  String get profileUpdateFailed => 'به‌روزرسانی ناموفق بود';

  @override
  String get fullName => 'نام و نام خانوادگی';

  @override
  String get yourName => 'نام شما';

  @override
  String get email => 'ایمیل';

  @override
  String get selectAvatar => 'انتخاب آواتار';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String get mapPickerTitle => 'انتخاب موقعیت روی نقشه';

  @override
  String get pickOnMapHint => 'نقشه را جابه‌جا کنید یا روی نقطه دلخواه بزنید';

  @override
  String get resolvingAddress => 'در حال یافتن آدرس…';

  @override
  String get addressNotFound => 'آدرس این نقطه یافت نشد';

  @override
  String get continueCompleteAddress => 'ادامه و تکمیل آدرس';

  @override
  String get completeAddressTitle => 'تکمیل آدرس';

  @override
  String get mapLocationSelected =>
      'موقعیت روی نقشه انتخاب شد. جزئیات را در صورت نیاز اصلاح کنید.';

  @override
  String get addressTitleLabel => 'عنوان (خانه، محل کار)';

  @override
  String get fullAddressLabel => 'آدرس کامل';

  @override
  String get searchOrEditAddress => 'جستجو یا ویرایش آدرس…';

  @override
  String get saveAddress => 'ذخیره آدرس';

  @override
  String get defaultAddressSaved => 'آدرس پیش‌فرض ذخیره شد';

  @override
  String get newAddress => 'آدرس جدید';

  @override
  String get moveMapHint => 'نقشه را جابه‌جا کنید';

  @override
  String get useMyLocation => 'موقعیت من';

  @override
  String get locationUnavailable =>
      'دریافت موقعیت ممکن نشد. دسترسی موقعیت را بررسی کنید.';

  @override
  String get addressFallback => 'آدرس';

  @override
  String get discounted => 'تخفیف‌دار';

  @override
  String get todaySpecials => 'ویژه امروز';

  @override
  String deliveryMinutes(int minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get addMore => 'افزودن بیشتر';

  @override
  String get addToCart => 'افزودن به سبد';

  @override
  String get upsellTitle => 'این موارد را هم اضافه کنید';

  @override
  String get aiBannerSubtitle => 'پرسش و پاسخ هوشمند';

  @override
  String get searchCountry => 'جستجوی کشور';

  @override
  String get receivedThisMonth => 'دریافتی این ماه';

  @override
  String get paidThisMonth => 'پرداختی این ماه';

  @override
  String txnCount(int count) {
    return '$count مورد';
  }

  @override
  String get active => 'فعال';

  @override
  String get inactive => 'غیرفعال';

  @override
  String get totalTopUp => 'مجموع شارژ';

  @override
  String get lastTopUp => 'آخرین شارژ';

  @override
  String get filterAll => 'همه';

  @override
  String get filterCredit => 'واریز';

  @override
  String get filterDebit => 'برداشت';

  @override
  String get noTransactions => 'تراکنشی برای نمایش نیست';

  @override
  String get txnTypeTopup => 'شارژ کیف پول';

  @override
  String get txnTypeOrderPayment => 'پرداخت سفارش';

  @override
  String get txnTypeRefund => 'بازگشت وجه';

  @override
  String get txnTypeAdjustment => 'تعدیل موجودی';

  @override
  String get txnGeneric => 'تراکنش';

  @override
  String balanceAfter(String amount) {
    return 'موجودی: $amount';
  }

  @override
  String get topUpFailed => 'شروع شارژ کیف پول ناموفق بود.';

  @override
  String paymentLink(String url) {
    return 'لینک پرداخت: $url';
  }

  @override
  String get orderDeliveredSnackbar => 'سفارش شما تحویل داده شد ✅';

  @override
  String get callAfterPeykAssigned => 'پس از اختصاص پیک می‌توانید تماس بگیرید.';

  @override
  String get callUnavailable => 'امکان شروع تماس وجود ندارد.';

  @override
  String get etaTitle => 'تخمین زمان رسیدن';

  @override
  String get assignedPeykTitle => 'پیک اختصاص یافته';

  @override
  String get orderStatusHeader => 'وضعیت سفارش';

  @override
  String get arrivingSoon => 'به‌زودی می‌رسد';

  @override
  String etaMinutes(int minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get peykPickingUp => 'پیک در حال دریافت از فروشنده';

  @override
  String get awaitingPreparation => 'در انتظار آماده‌سازی';

  @override
  String get processing => 'در حال پردازش';

  @override
  String get peykLocationAfterPickup =>
      'موقعیت پیک پس از تحویل از فروشنده نمایش داده می‌شود';

  @override
  String get livePeykLocation => 'موقعیت زنده پیک';

  @override
  String get awaitingPeykLocation => 'در انتظار موقعیت پیک';

  @override
  String distanceLabel(String distance) {
    return 'فاصله: $distance';
  }

  @override
  String orderFromVendor(String vendor) {
    return 'سفارش از $vendor';
  }

  @override
  String get deliveryCodeTitle => 'کد تحویل سفارش';

  @override
  String get tellCodeToPeyk => 'این کد را هنگام تحویل به پیک بگویید';

  @override
  String get stepPreparing => 'آماده‌سازی';

  @override
  String get stepOnWay => 'در راه';

  @override
  String get stepDelivered => 'تحویل';

  @override
  String get noActiveOrder => 'سفارش فعالی ندارید';

  @override
  String get noActiveOrderDesc =>
      'پس از ثبت سفارش، نقشه و مراحل ارسال اینجا نمایش داده می‌شود.';

  @override
  String get yourCart => 'سبد خرید شما';

  @override
  String get getirStyleDeliveryUiCourier => 'پیک GETIR_STYLE_DELIVERY_UI';

  @override
  String get deliveringYourOrder => 'در حال رساندن سفارش شما';

  @override
  String get peykReceivingFromVendor => 'در حال دریافت سفارش از فروشنده';

  @override
  String get awaitingPeykAssignment => 'در انتظار اختصاص پیک';

  @override
  String get orderConfirmedPreparing => 'سفارش تأیید شد — در حال آماده‌سازی';

  @override
  String get orderRegistered => 'سفارش شما ثبت شد';

  @override
  String get voiceCallTitle => 'تماس صوتی';

  @override
  String get connecting => 'در حال اتصال...';

  @override
  String get callEnded => 'تماس پایان یافت';

  @override
  String get awaitingPeykConnect => 'در انتظار اتصال پیک...';

  @override
  String get callConnected => 'تماس برقرار است';

  @override
  String get callFailed => 'اتصال تماس ناموفق بود.';

  @override
  String get micPermissionRequired =>
      'برای تماس صوتی، اجازه دسترسی به میکروفون لازم است.';

  @override
  String roomLabel(String name) {
    return 'اتاق: $name';
  }

  @override
  String get muted => 'بی‌صدا';

  @override
  String get microphone => 'میکروفون';

  @override
  String get endCall => 'پایان تماس';

  @override
  String get exitCall => 'خروج';

  @override
  String get comingSoon => 'به‌زودی';

  @override
  String get genericError => 'خطا';

  @override
  String get devOtpLabel => 'کد تست (حالت توسعه)';

  @override
  String get betaOtpHint => 'در نسخه بتا کد در همین صفحه نمایش داده می‌شود';

  @override
  String devOtpSnackbar(String code) {
    return 'کد توسعه: $code';
  }

  @override
  String get devDebugTitle => 'اشکال‌زدایی توسعه';

  @override
  String get devClearSession => 'پاک کردن نشست (خروج)';

  @override
  String get dineInTitle => 'رستوران';

  @override
  String get dineInSubtitle =>
      'میز خود را در نمای ۳۶۰ انتخاب کنید و از سر میز سفارش دهید';

  @override
  String get dineInEmpty => 'هنوز رستورانی با سرویس حضوری موجود نیست';

  @override
  String get noDineInRestaurants => 'هنوز رستورانی با سرویس حضوری موجود نیست';

  @override
  String get dineInLoadError =>
      'بارگذاری رستوران‌ها ناموفق بود. برای تلاش مجدد بکشید.';

  @override
  String get loadVenueError =>
      'بارگذاری اطلاعات رستوران ناموفق بود. دوباره تلاش کنید.';

  @override
  String get enterRestaurant => 'ورود به رستوران';

  @override
  String get selectYourTable => 'انتخاب میز';

  @override
  String get selectTable => 'انتخاب میز';

  @override
  String get confirmTable => 'تأیید میز';

  @override
  String get tableOccupied => 'این میز در دسترس نیست';

  @override
  String get tableHoldFailed => 'رزرو میز ناموفق بود. میز دیگری انتخاب کنید.';

  @override
  String get dineInFulfillment => 'سفارش حضوری';

  @override
  String dineInCheckoutSummary(String table, String restaurant) {
    return '$table — $restaurant';
  }

  @override
  String dineInTableSummary(String table, String restaurant) {
    return '$table — $restaurant';
  }

  @override
  String dineInSeats(int count) {
    return '$count نفره';
  }

  @override
  String get restaurantAbout => 'درباره';

  @override
  String get restaurantAddress => 'آدرس';

  @override
  String get restaurantFeaturedMenu => 'غذاهای محبوب';

  @override
  String get restaurant360Booking => 'رزرو میز ۳۶۰°';

  @override
  String restaurantTablesAvailable(int count) {
    return '$count میز آزاد';
  }
}
