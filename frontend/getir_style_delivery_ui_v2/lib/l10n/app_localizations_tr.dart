// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'GETIR_STYLE_DELIVERY_UI';

  @override
  String get appTagline => 'Cebinizdeki en hızlı teslimat';

  @override
  String get heroTitle => 'Bir doz mutluluk!';

  @override
  String get heroSubtitle =>
      'GetirStyleDeliveryUi siparişleri dakikalar içinde kapınızda!';

  @override
  String get addAddress => 'Adres ekle';

  @override
  String get noAddress => 'Adres bilgisi yok';

  @override
  String get welcomeBack => 'Tekrar hoş geldiniz';

  @override
  String get enterPhone => 'Devam etmek için telefon numaranızı girin';

  @override
  String get continueButton => 'Devam';

  @override
  String get orContinueWith => 'VEYA ŞUNUNLA DEVAM ET';

  @override
  String get troubleLoggingIn => 'Giriş yapmakta sorun mu yaşıyorsunuz?';

  @override
  String get termsAgreement =>
      'Devam ederek Hizmet Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.';

  @override
  String get termsOfService => 'Hizmet Şartları';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get enterOtp => 'Doğrulama kodunu girin';

  @override
  String otpSent(String phone) {
    return '$phone numarasına kod gönderdik';
  }

  @override
  String get verify => 'Doğrula';

  @override
  String get resendCode => 'Kodu tekrar gönder';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navDineIn => 'Restoran';

  @override
  String get navSearch => 'Ara';

  @override
  String get navCategories => 'Kategoriler';

  @override
  String get navProfile => 'Profil';

  @override
  String get navOffers => 'Fırsatlar';

  @override
  String get navWallet => 'Cüzdan';

  @override
  String get profile => 'Profil';

  @override
  String get login => 'Giriş';

  @override
  String get manageAccount => 'Hesabınızı ve siparişlerinizi yönetin';

  @override
  String get liveSupport => 'Canlı Destek';

  @override
  String get myAddresses => 'Adreslerim';

  @override
  String get favouriteProducts => 'Favori Ürünler';

  @override
  String get support => 'Destek';

  @override
  String get language => 'Dil';

  @override
  String get version => 'Sürüm';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get exclusiveOffer => 'Özel Teklif';

  @override
  String get offerDescription =>
      'İlk üç siparişinizde %50 indirim. Sadece bugün!';

  @override
  String get claimNow => 'Hemen Al';

  @override
  String get serviceGetirStyleDeliveryUi => 'GETIR_STYLE_DELIVERY_UI';

  @override
  String get serviceGetirStyleDeliveryUiDesc => '2.000+ ürün';

  @override
  String get serviceGetirStyleDeliveryUiHint => 'dakikalar içinde';

  @override
  String get serviceFinans => 'GSDU Finans';

  @override
  String get serviceMore => 'GSDU More';

  @override
  String get serviceMoreDesc => '5.000+ ürün';

  @override
  String get serviceMoreHint => 'uygun fiyatlarla';

  @override
  String get serviceFood => 'GSDU Food';

  @override
  String get serviceRestaurant => 'GSDU Restaurant';

  @override
  String get serviceLocals => 'GSDU Locals';

  @override
  String get serviceWater => 'GSDU Water';

  @override
  String get serviceTaxi => 'GSDU Bitaksi';

  @override
  String get promotions => 'Kampanyalar';

  @override
  String get whatsNew => 'Yenilikler';

  @override
  String get searchHint => 'Ürün, restoran ara...';

  @override
  String get searchPageSubtitle => 'Fırsatlar, indirimler ve keşfet';

  @override
  String get browseAllProducts => 'Tümünü gez';

  @override
  String searchResultsFor(String query) {
    return '«$query» sonuçları';
  }

  @override
  String get recentSearches => 'Son Aramalar';

  @override
  String get popularCategories => 'Popüler Kategoriler';

  @override
  String get walletBalance => 'GETIR_STYLE_DELIVERY_UI Bakiyesi';

  @override
  String get topUp => 'Yükle';

  @override
  String get transfer => 'Transfer';

  @override
  String get paymentMethods => 'Ödeme Yöntemleri';

  @override
  String get recentTransactions => 'Son İşlemler';

  @override
  String get aiAssistant => 'GETIR_STYLE_DELIVERY_UI AI';

  @override
  String get aiGreeting =>
      'Merhaba! Ben GetirStyleDeliveryUi asistanınızım. Size nasıl yardımcı olabilirim?';

  @override
  String get aiPlaceholder => 'Bana bir şey sorun...';

  @override
  String get suggestionOrder => 'Siparişimi takip et';

  @override
  String get suggestionDeals => 'Fırsatları göster';

  @override
  String get suggestionSupport => 'Destek ile iletişim';

  @override
  String get langPersian => 'Farsça';

  @override
  String get langEnglish => 'İngilizce';

  @override
  String get langArabic => 'Arapça';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get countryCode => '+98';

  @override
  String get phonePlaceholder => '9XX XXX XXXX';

  @override
  String get freeDelivery => 'Ücretsiz Teslimat';

  @override
  String get discount50 => '%50 İNDİRİM';

  @override
  String get newBadge => 'YENİ';

  @override
  String get availableBalance => 'Kullanılabilir Bakiye';

  @override
  String get addMoney => 'Para Ekle';

  @override
  String get send => 'Gönder';

  @override
  String get transactionHistory => 'İşlem Geçmişi';

  @override
  String get manageCards => 'Kartları Yönet';

  @override
  String get finansIntegration => 'GSDU Finans Entegrasyonu';

  @override
  String get finansIntegrationDesc =>
      'Banka hesabınızı bağlayın, her siparişte %1 nakit iade kazanın.';

  @override
  String get couponsAndOffers => 'Kuponlar ve Teklifler';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get addNew => 'Yeni Ekle';

  @override
  String get addCouponCode => 'Kupon Kodu Ekle';

  @override
  String get switchService => 'Tüm Hizmetler';

  @override
  String get chooseService => 'Başlamak için bir hizmet seçin';

  @override
  String get serviceHomePlaceholder =>
      'Kategorilere göz atın ve sipariş verin.';

  @override
  String get finansTickerValue => '45,82';

  @override
  String get finansTickerGold => 'XAU 6.384,6';

  @override
  String get couponDiscountTitle => '20 TL İndirim';

  @override
  String get couponDiscountDesc => '150 TL üzeri siparişlerde';

  @override
  String get couponFreeDeliveryDesc => 'Bugünün market alışverişi için geçerli';

  @override
  String get fastestBadge => 'En Hızlı';

  @override
  String get getirStyleDeliveryUiPlusBadge => 'GETIR_STYLE_DELIVERY_UI+';

  @override
  String get mainSpendingCard => 'Ana Harcama Kartı';

  @override
  String get digitalWallet => 'Dijital Cüzdan';

  @override
  String get cardMaskedVisa => '**** **** **** 4291';

  @override
  String get cardMaskedMaster => '**** **** **** 8802';

  @override
  String get groceryOrder => 'Market Siparişi';

  @override
  String get transactionToday => 'Bugün, 14:20';

  @override
  String get balanceAmount => '1.250.000 Toman';

  @override
  String get transactionDebit => '- 45.000 Toman';

  @override
  String get transactionCredit => '+ 500.000 Toman';

  @override
  String get limitedTime => 'Sınırlı Süre';

  @override
  String get paymentProviderShaparak => 'Shaparak';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String get minimumOrder => 'Minimum';

  @override
  String get deliveryLabel => 'Teslimat';

  @override
  String get valuePlaceholder => '--';

  @override
  String get catBeverages => 'İçecekler';

  @override
  String get catSnacks => 'Atıştırmalık';

  @override
  String get catMilkDairy => 'Süt ve Süt Ürünleri';

  @override
  String get catFruitsVeggies => 'Meyve ve Sebze';

  @override
  String get catBreakfast => 'Kahvaltı';

  @override
  String get catBakedGoods => 'Fırın Ürünleri';

  @override
  String get catIceCream => 'Dondurma';

  @override
  String get catFood => 'Yemek';

  @override
  String get catReadyToEat => 'Hazır Yemek';

  @override
  String get catMeatPoultry => 'Et ve Kümes Hayvanları';

  @override
  String get catFitAndForm => 'Fit ve Form';

  @override
  String get catHomeCare => 'Ev Bakımı';

  @override
  String get aboutApp => 'Uygulama Hakkında';

  @override
  String get aboutAppHeroSubtitle => 'İranlı talep üzerine teslimat platformu';

  @override
  String get aboutDeveloper => 'Geliştirici Hakkında';

  @override
  String get technology => 'Teknoloji';

  @override
  String get stack => 'Stack';

  @override
  String get stackSubtitle => 'Flutter, Django, WebSocket ve haritalar';

  @override
  String get license => 'Lisans';

  @override
  String get licenseTitle => 'Yalnızca eğitim amaçlı';

  @override
  String get licenseSubtitle => 'Bu eğitim projesinin koşulları';

  @override
  String get licenseBody =>
      'Bu proje yalnızca eğitim amaçlıdır. İşletmelerde veya herhangi bir ticari amaçla kullanmak yasaktır ve etik değildir.';

  @override
  String get noPromotions => 'Kampanya bulunmuyor.';

  @override
  String get swipeTechStack => 'Yığını keşfetmek için kaydırın';

  @override
  String get betaPhase => 'Beta';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName. Beta sürümü.';
  }

  @override
  String get accountSection => 'Hesap';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get editProfileSubtitle => 'Ad, e-posta ve avatar';

  @override
  String get myOrders => 'Siparişlerim';

  @override
  String get myOrdersSubtitle => 'Sipariş geçmişi ve durumu';

  @override
  String get addressManageSubtitle => 'Teslimat adreslerini yönet';

  @override
  String get settingsSection => 'Ayarlar';

  @override
  String get supportSubtitle => 'Yardım ve destek';

  @override
  String get devDebugSubtitle => 'Geliştirici araçları';

  @override
  String get developerRole => 'Kıdemli Flutter Geliştirici';

  @override
  String get navTracking => 'Takip';

  @override
  String get techFlutter => 'Flutter';

  @override
  String get techFlutterDesc => 'Çok platformlu müşteri uygulaması';

  @override
  String get techDjango => 'Django';

  @override
  String get techDjangoDesc => 'REST API ve gerçek zamanlı backend';

  @override
  String get techWebSocket => 'WebSocket';

  @override
  String get techWebSocketDesc => 'Canlı sipariş ve kurye takibi';

  @override
  String get techNeshan => 'Neshan Haritalar';

  @override
  String get techNeshanDesc => 'Harita, rota ve geokodlama';

  @override
  String get techPostgres => 'PostgreSQL';

  @override
  String get techPostgresDesc => 'Ana ilişkisel veritabanı';

  @override
  String get techPostgresDetail =>
      'Siparişler, katalog, hesaplar, cüzdan ve restoran verileri PostgreSQL\'de Django ORM ile saklanır.';

  @override
  String get techPostgresUse1 =>
      'Siparişler, satıcılar, ürünler, dine-in masaları';

  @override
  String get techPostgresUse2 =>
      'Kullanıcı profilleri, cüzdan, kurye atamaları';

  @override
  String get techRedis => 'Redis ve Celery';

  @override
  String get techRedisDesc => 'Önbellek, kuyruk ve pub/sub';

  @override
  String get techRedisDetail =>
      'Redis Channels katmanı, dine-in masa tutma ve Celery arka plan işlerini destekler.';

  @override
  String get techRedisUse1 => 'Canlı takip için WebSocket katmanı';

  @override
  String get techRedisUse2 => '5 dakikalık dine-in masa tutma';

  @override
  String get techRedisUse3 => 'Celery ile arka plan görevleri';

  @override
  String get techLiveKit => 'LiveKit';

  @override
  String get techLiveKitDesc => 'Uygulama içi sesli arama';

  @override
  String get techLiveKitDetail =>
      'LiveKit odaları müşteri ve kuryeyi teslimat sırasında bağlar. Backend token üretir; Flutter livekit_client kullanır.';

  @override
  String get techLiveKitUse1 => 'Takip sekmesinde sesli arama';

  @override
  String get techLiveKitUse2 => 'communications modülünde token API';

  @override
  String get techFirebase => 'Firebase FCM';

  @override
  String get techFirebaseDesc => 'Push bildirimleri';

  @override
  String get techFirebaseDetail =>
      'firebase-admin sipariş durumu değişince veya kurye atanınca FCM gönderir.';

  @override
  String get techFirebaseUse1 => 'Sipariş ve teslimat uyarıları';

  @override
  String get techFirebaseUse2 => 'Kullanıcı başına FCM token kaydı';

  @override
  String get techFlutterDetail =>
      'getir_style_delivery_ui_v2 ve getir_style_delivery_ui_peyk uygulamaları Provider, Dio ve RTL desteği ile Flutter\'da yazıldı.';

  @override
  String get techFlutterUse1 => 'Ana sayfa, dine-in 360°, sepet, cüzdan';

  @override
  String get techFlutterUse2 => 'flutter_map ile canlı takip haritası';

  @override
  String get techFlutterUse3 => 'flutter_secure_storage ile JWT';

  @override
  String get techDjangoDetail =>
      'getir_style_delivery_ui_backend /api/v1/ altında REST sunar; JWT auth ve django-unfold admin.';

  @override
  String get techDjangoUse1 => 'Katalog, sipariş, dine-in, cüzdan uçları';

  @override
  String get techDjangoUse2 => 'Müşteri, satıcı, kurye rol tabanlı erişim';

  @override
  String get techDjangoUse3 => 'django-storages ile medya yükleme';

  @override
  String get techWebSocketDetail =>
      'Django Channels kurye konumu ve sipariş durumunu yayınlar. Takip sekmesi web_socket_channel kullanır.';

  @override
  String get techWebSocketUse1 => 'Haritada canlı kurye konumu';

  @override
  String get techWebSocketUse2 => 'Polling olmadan durum güncellemesi';

  @override
  String get techNeshanDetail =>
      'Neshan karoları backend proxy üzerinden yüklenir. Adres seçici için ters geokodlama.';

  @override
  String get techNeshanUse1 => 'Adres seçici ve takip haritası karoları';

  @override
  String get techNeshanUse2 => 'Restoran önizleme pini';

  @override
  String get techNeshanUse3 => 'Android için /tracking/tiles/ proxy';

  @override
  String get stackPackagesLabel => 'Kütüphaneler ve paketler';

  @override
  String get stackUsedInLabel => 'GetirStyleDeliveryUi\'da kullanım';

  @override
  String get stackViewDetails => 'Detayları gör';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Onayla';

  @override
  String get change => 'Değiştir';

  @override
  String get save => 'Kaydet';

  @override
  String get currencyToman => 'Toman';

  @override
  String get cartTitle => 'Alışveriş Sepeti';

  @override
  String get cartEmpty => 'Sepetiniz boş';

  @override
  String get clearCart => 'Sepeti temizle';

  @override
  String cartTotal(int count) {
    return 'Toplam ($count)';
  }

  @override
  String get placeOrder => 'Sipariş ver';

  @override
  String get editCart => 'Sepeti düzenle';

  @override
  String get checkoutTitle => 'Ödeme';

  @override
  String get deliveryAddress => 'Teslimat adresi';

  @override
  String get fullAddressHint => 'Tam adresi girin';

  @override
  String get city => 'Şehir';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String get paymentMethod => 'Ödeme yöntemi';

  @override
  String get walletPay => 'Cüzdan';

  @override
  String get walletBalanceLoading => 'Bakiye…';

  @override
  String walletBalanceLabel(String amount) {
    return 'Bakiye: $amount';
  }

  @override
  String get onlinePay => 'Online ödeme';

  @override
  String get zarinpalGateway => 'Zarinpal ödeme';

  @override
  String get payAtDoor => 'Kapıda ödeme';

  @override
  String get payAtDoorSubtitle => 'Teslimatta nakit';

  @override
  String get payableAmount => 'Ödenecek tutar';

  @override
  String get cartEmptyError => 'Sepetiniz boş.';

  @override
  String get enterDeliveryAddress => 'Lütfen teslimat adresi girin.';

  @override
  String get orderPlacedWallet => 'Sipariş alındı ve cüzdandan ödendi.';

  @override
  String orderPlacedOnline(String url) {
    return 'Sipariş alındı. Online ödeme: $url';
  }

  @override
  String get orderPlacedCash => 'Sipariş alındı. Kapıda ödeme.';

  @override
  String get orderPlaceError => 'Sipariş oluşturulamadı.';

  @override
  String get vendorMismatchTitle => 'Farklı satıcı';

  @override
  String get vendorMismatchBody =>
      'Sepette başka satıcıdan ürünler var. Yeni sepet oluşturulsun mu?';

  @override
  String get newCart => 'Yeni sepet';

  @override
  String addedToCart(String name) {
    return '$name sepete eklendi';
  }

  @override
  String get orderStatusPending => 'Beklemede';

  @override
  String get orderStatusAccepted => 'Onaylandı';

  @override
  String get orderStatusPreparing => 'Hazırlanıyor';

  @override
  String get orderStatusPickedUp => 'GetirStyleDeliveryUi';

  @override
  String get orderStatusDelivered => 'Teslim edildi';

  @override
  String get orderStatusCancelled => 'İptal edildi';

  @override
  String get ordersTitle => 'Siparişlerim';

  @override
  String get noOrdersYet => 'Henüz sipariş vermediniz';

  @override
  String get orderFallback => 'Sipariş';

  @override
  String get deliveryCodeLabel => 'Teslimat kodu:';

  @override
  String get supportHeroTitle => 'Size nasıl yardımcı olabiliriz?';

  @override
  String get supportHeroSubtitle =>
      'GetirStyleDeliveryUi destek ekibi her gün yanınızda.';

  @override
  String get contactMethods => 'İletişim yolları';

  @override
  String get phoneContact => 'Telefon';

  @override
  String get emailContact => 'E-posta';

  @override
  String get onlineChat => 'Online sohbet';

  @override
  String get onlineChatValue => 'Uygulamada anında yanıt';

  @override
  String get businessHours => 'Çalışma saatleri';

  @override
  String get businessHoursValue => 'Her gün 09:00 – 23:00';

  @override
  String get faqTitle => 'Sık sorulan sorular';

  @override
  String get faqTrackOrderQ => 'Siparişimi nasıl takip ederim?';

  @override
  String get faqTrackOrderA =>
      'Takip sekmesinden kurye konumunu ve sipariş aşamalarını haritada görebilirsiniz.';

  @override
  String get faqPaymentQ => 'Hangi ödeme yöntemleri var?';

  @override
  String get faqPaymentA => 'Cüzdan, online ödeme ve kapıda ödeme desteklenir.';

  @override
  String get faqAddressQ => 'Nasıl adres eklerim?';

  @override
  String get faqAddressA =>
      'Ana sayfadaki üst çubuktan veya profildeki Adreslerim bölümünden.';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String get profileUpdateFailed => 'Güncelleme başarısız';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get yourName => 'Adınız';

  @override
  String get email => 'E-posta';

  @override
  String get selectAvatar => 'Avatar seç';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get mapPickerTitle => 'Haritada konum seç';

  @override
  String get pickOnMapHint =>
      'Haritayı kaydırın veya istediğiniz noktaya dokunun';

  @override
  String get resolvingAddress => 'Adres aranıyor…';

  @override
  String get addressNotFound => 'Bu nokta için adres bulunamadı';

  @override
  String get continueCompleteAddress => 'Devam et ve adresi tamamla';

  @override
  String get completeAddressTitle => 'Adresi tamamla';

  @override
  String get mapLocationSelected =>
      'Haritada konum seçildi. Gerekirse ayrıntıları düzenleyin.';

  @override
  String get addressTitleLabel => 'Başlık (ev, iş)';

  @override
  String get fullAddressLabel => 'Tam adres';

  @override
  String get searchOrEditAddress => 'Adres ara veya düzenle…';

  @override
  String get saveAddress => 'Adresi kaydet';

  @override
  String get defaultAddressSaved => 'Varsayılan adres kaydedildi';

  @override
  String get newAddress => 'Yeni adres';

  @override
  String get moveMapHint => 'Haritayı kaydırın';

  @override
  String get useMyLocation => 'Konumumu kullan';

  @override
  String get locationUnavailable =>
      'Konumunuz alınamadı. İzinleri kontrol edip tekrar deneyin.';

  @override
  String get addressFallback => 'Adres';

  @override
  String get discounted => 'İndirimli';

  @override
  String get todaySpecials => 'Bugünün özel ürünleri';

  @override
  String deliveryMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get addMore => 'Daha fazla ekle';

  @override
  String get addToCart => 'Sepete ekle';

  @override
  String get upsellTitle => 'Bunları da ekleyebilirsiniz';

  @override
  String get aiBannerSubtitle => 'Akıllı soru-cevap';

  @override
  String get searchCountry => 'Ülke ara';

  @override
  String get receivedThisMonth => 'Bu ay alınan';

  @override
  String get paidThisMonth => 'Bu ay ödenen';

  @override
  String txnCount(int count) {
    return '$count kayıt';
  }

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Pasif';

  @override
  String get totalTopUp => 'Toplam yükleme';

  @override
  String get lastTopUp => 'Son yükleme';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterCredit => 'Yatırma';

  @override
  String get filterDebit => 'Çekme';

  @override
  String get noTransactions => 'Gösterilecek işlem yok';

  @override
  String get txnTypeTopup => 'Cüzdan yükleme';

  @override
  String get txnTypeOrderPayment => 'Sipariş ödemesi';

  @override
  String get txnTypeRefund => 'İade';

  @override
  String get txnTypeAdjustment => 'Bakiye düzeltmesi';

  @override
  String get txnGeneric => 'İşlem';

  @override
  String balanceAfter(String amount) {
    return 'Bakiye: $amount';
  }

  @override
  String get topUpFailed => 'Cüzdan yüklemesi başlatılamadı.';

  @override
  String paymentLink(String url) {
    return 'Ödeme bağlantısı: $url';
  }

  @override
  String get orderDeliveredSnackbar => 'Siparişiniz teslim edildi ✅';

  @override
  String get callAfterPeykAssigned => 'Kurye atandıktan sonra arayabilirsiniz.';

  @override
  String get callUnavailable => 'Arama başlatılamıyor.';

  @override
  String get etaTitle => 'Tahmini varış';

  @override
  String get assignedPeykTitle => 'Kurye atandı';

  @override
  String get orderStatusHeader => 'Sipariş durumu';

  @override
  String get arrivingSoon => 'Yakında geliyor';

  @override
  String etaMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get peykPickingUp => 'Kurye satıcıdan alıyor';

  @override
  String get awaitingPreparation => 'Hazırlık bekleniyor';

  @override
  String get processing => 'İşleniyor';

  @override
  String get peykLocationAfterPickup =>
      'Kurye konumu satıcıdan alındıktan sonra görünür';

  @override
  String get livePeykLocation => 'Canlı kurye konumu';

  @override
  String get awaitingPeykLocation => 'Kurye konumu bekleniyor';

  @override
  String distanceLabel(String distance) {
    return 'Mesafe: $distance';
  }

  @override
  String orderFromVendor(String vendor) {
    return '$vendor siparişi';
  }

  @override
  String get deliveryCodeTitle => 'Teslimat kodu';

  @override
  String get tellCodeToPeyk => 'Teslimatta bu kodu kuryeye söyleyin';

  @override
  String get stepPreparing => 'Hazırlık';

  @override
  String get stepOnWay => 'GetirStyleDeliveryUi';

  @override
  String get stepDelivered => 'Teslim';

  @override
  String get noActiveOrder => 'Aktif sipariş yok';

  @override
  String get noActiveOrderDesc =>
      'Sipariş verdikten sonra harita ve teslimat aşamaları burada görünür.';

  @override
  String get yourCart => 'Sepetiniz';

  @override
  String get getirStyleDeliveryUiCourier => 'GetirStyleDeliveryUi kuryesi';

  @override
  String get deliveringYourOrder => 'Siparişiniz teslim ediliyor';

  @override
  String get peykReceivingFromVendor => 'Kurye siparişi satıcıdan alıyor';

  @override
  String get awaitingPeykAssignment => 'Kurye ataması bekleniyor';

  @override
  String get orderConfirmedPreparing => 'Sipariş onaylandı — hazırlanıyor';

  @override
  String get orderRegistered => 'Siparişiniz alındı';

  @override
  String get voiceCallTitle => 'Sesli arama';

  @override
  String get connecting => 'Bağlanıyor…';

  @override
  String get callEnded => 'Arama sona erdi';

  @override
  String get awaitingPeykConnect => 'Kurye bağlantısı bekleniyor…';

  @override
  String get callConnected => 'Arama bağlandı';

  @override
  String get callFailed => 'Arama bağlantısı başarısız.';

  @override
  String get micPermissionRequired => 'Sesli arama için mikrofon izni gerekli.';

  @override
  String roomLabel(String name) {
    return 'Oda: $name';
  }

  @override
  String get muted => 'Sessiz';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get endCall => 'Aramayı bitir';

  @override
  String get exitCall => 'Çık';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get genericError => 'Hata';

  @override
  String get devOtpLabel => 'Test kodu (geliştirme)';

  @override
  String get betaOtpHint => 'Beta sürümünde kod bu ekranda gösterilir';

  @override
  String devOtpSnackbar(String code) {
    return 'Geliştirme OTP: $code';
  }

  @override
  String get devDebugTitle => 'Geliştirici Hata Ayıklama';

  @override
  String get devClearSession => 'Oturumu temizle (çıkış)';

  @override
  String get dineInTitle => 'Restoranda';

  @override
  String get dineInSubtitle =>
      '360° görünümde masanızı seçin ve yerinizden sipariş verin';

  @override
  String get dineInEmpty => 'Henüz restoran içi servis yok';

  @override
  String get noDineInRestaurants => 'Henüz restoran içi servis yok';

  @override
  String get dineInLoadError =>
      'Restoranlar yüklenemedi. Yenilemek için çekin.';

  @override
  String get loadVenueError =>
      'Restoran bilgileri yüklenemedi. Tekrar deneyin.';

  @override
  String get enterRestaurant => 'Restorana gir';

  @override
  String get selectYourTable => 'Masanızı seçin';

  @override
  String get selectTable => 'Masanızı seçin';

  @override
  String get confirmTable => 'Masayı onayla';

  @override
  String get tableOccupied => 'Bu masa müsait değil';

  @override
  String get tableHoldFailed =>
      'Masa rezerve edilemedi. Başka bir masa deneyin.';

  @override
  String get dineInFulfillment => 'Restoranda';

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
    return '$count kişilik';
  }

  @override
  String get restaurantAbout => 'Hakkında';

  @override
  String get restaurantAddress => 'Adres';

  @override
  String get restaurantFeaturedMenu => 'Popüler yemekler';

  @override
  String get restaurant360Booking => '360° masa rezervasyonu';

  @override
  String restaurantTablesAvailable(int count) {
    return '$count masa müsait';
  }
}
