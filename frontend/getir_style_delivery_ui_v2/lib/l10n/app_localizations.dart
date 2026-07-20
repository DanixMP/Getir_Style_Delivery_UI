import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GETIR_STYLE_DELIVERY_UI'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Fastest delivery in your pocket'**
  String get appTagline;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'A dose of happiness!'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GetirStyleDeliveryUi orders are at your door within minutes!'**
  String get heroSubtitle;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No Address Information'**
  String get noAddress;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get enterPhone;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @troubleLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Trouble logging in?'**
  String get troubleLoggingIn;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy.'**
  String get termsAgreement;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String otpSent(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDineIn.
  ///
  /// In en, this message translates to:
  /// **'Dine-in'**
  String get navDineIn;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get navOffers;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and orders'**
  String get manageAccount;

  /// No description provided for @liveSupport.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get liveSupport;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @favouriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favourite Products'**
  String get favouriteProducts;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @exclusiveOffer.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offer'**
  String get exclusiveOffer;

  /// No description provided for @offerDescription.
  ///
  /// In en, this message translates to:
  /// **'Get 50% off on your first three orders. Only today!'**
  String get offerDescription;

  /// No description provided for @claimNow.
  ///
  /// In en, this message translates to:
  /// **'Claim Now'**
  String get claimNow;

  /// No description provided for @serviceGetirStyleDeliveryUi.
  ///
  /// In en, this message translates to:
  /// **'GETIR_STYLE_DELIVERY_UI'**
  String get serviceGetirStyleDeliveryUi;

  /// No description provided for @serviceGetirStyleDeliveryUiDesc.
  ///
  /// In en, this message translates to:
  /// **'2,000+ products'**
  String get serviceGetirStyleDeliveryUiDesc;

  /// No description provided for @serviceGetirStyleDeliveryUiHint.
  ///
  /// In en, this message translates to:
  /// **'within minutes'**
  String get serviceGetirStyleDeliveryUiHint;

  /// No description provided for @serviceFinans.
  ///
  /// In en, this message translates to:
  /// **'GSDU Finans'**
  String get serviceFinans;

  /// No description provided for @serviceMore.
  ///
  /// In en, this message translates to:
  /// **'GSDU More'**
  String get serviceMore;

  /// No description provided for @serviceMoreDesc.
  ///
  /// In en, this message translates to:
  /// **'5,000+ products'**
  String get serviceMoreDesc;

  /// No description provided for @serviceMoreHint.
  ///
  /// In en, this message translates to:
  /// **'with affordable prices'**
  String get serviceMoreHint;

  /// No description provided for @serviceFood.
  ///
  /// In en, this message translates to:
  /// **'GSDU Food'**
  String get serviceFood;

  /// No description provided for @serviceRestaurant.
  ///
  /// In en, this message translates to:
  /// **'GSDU Restaurant'**
  String get serviceRestaurant;

  /// No description provided for @serviceLocals.
  ///
  /// In en, this message translates to:
  /// **'GSDU Locals'**
  String get serviceLocals;

  /// No description provided for @serviceWater.
  ///
  /// In en, this message translates to:
  /// **'GSDU Water'**
  String get serviceWater;

  /// No description provided for @serviceTaxi.
  ///
  /// In en, this message translates to:
  /// **'GSDU Bitaksi'**
  String get serviceTaxi;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whatsNew;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, restaurants...'**
  String get searchHint;

  /// No description provided for @searchPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deals, discounts & discover'**
  String get searchPageSubtitle;

  /// No description provided for @browseAllProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get browseAllProducts;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String searchResultsFor(String query);

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @popularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get popularCategories;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'GETIR_STYLE_DELIVERY_UI Balance'**
  String get walletBalance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'GETIR_STYLE_DELIVERY_UI AI'**
  String get aiAssistant;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your GetirStyleDeliveryUi assistant. How can I help you today?'**
  String get aiGreeting;

  /// No description provided for @aiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get aiPlaceholder;

  /// No description provided for @suggestionOrder.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get suggestionOrder;

  /// No description provided for @suggestionDeals.
  ///
  /// In en, this message translates to:
  /// **'Show me deals'**
  String get suggestionDeals;

  /// No description provided for @suggestionSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get suggestionSupport;

  /// No description provided for @langPersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get langPersian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'+98'**
  String get countryCode;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'9XX XXX XXXX'**
  String get phonePlaceholder;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @discount50.
  ///
  /// In en, this message translates to:
  /// **'50% OFF'**
  String get discount50;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @manageCards.
  ///
  /// In en, this message translates to:
  /// **'Manage Cards'**
  String get manageCards;

  /// No description provided for @finansIntegration.
  ///
  /// In en, this message translates to:
  /// **'GSDU Finans Integration'**
  String get finansIntegration;

  /// No description provided for @finansIntegrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account for 1% cashback on every order.'**
  String get finansIntegrationDesc;

  /// No description provided for @couponsAndOffers.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get couponsAndOffers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @addCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Add Coupon Code'**
  String get addCouponCode;

  /// No description provided for @switchService.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get switchService;

  /// No description provided for @chooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose a service to get started'**
  String get chooseService;

  /// No description provided for @serviceHomePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Browse categories and start ordering.'**
  String get serviceHomePlaceholder;

  /// No description provided for @finansTickerValue.
  ///
  /// In en, this message translates to:
  /// **'45.82'**
  String get finansTickerValue;

  /// No description provided for @finansTickerGold.
  ///
  /// In en, this message translates to:
  /// **'XAU 6,384.6'**
  String get finansTickerGold;

  /// No description provided for @couponDiscountTitle.
  ///
  /// In en, this message translates to:
  /// **'20 TL Discount'**
  String get couponDiscountTitle;

  /// No description provided for @couponDiscountDesc.
  ///
  /// In en, this message translates to:
  /// **'On orders over 150 TL'**
  String get couponDiscountDesc;

  /// No description provided for @couponFreeDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Valid for today\'s market shop'**
  String get couponFreeDeliveryDesc;

  /// No description provided for @fastestBadge.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastestBadge;

  /// No description provided for @getirStyleDeliveryUiPlusBadge.
  ///
  /// In en, this message translates to:
  /// **'GETIR_STYLE_DELIVERY_UI+'**
  String get getirStyleDeliveryUiPlusBadge;

  /// No description provided for @mainSpendingCard.
  ///
  /// In en, this message translates to:
  /// **'Main Spending Card'**
  String get mainSpendingCard;

  /// No description provided for @digitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// No description provided for @cardMaskedVisa.
  ///
  /// In en, this message translates to:
  /// **'**** **** **** 4291'**
  String get cardMaskedVisa;

  /// No description provided for @cardMaskedMaster.
  ///
  /// In en, this message translates to:
  /// **'**** **** **** 8802'**
  String get cardMaskedMaster;

  /// No description provided for @groceryOrder.
  ///
  /// In en, this message translates to:
  /// **'Grocery Order'**
  String get groceryOrder;

  /// No description provided for @transactionToday.
  ///
  /// In en, this message translates to:
  /// **'Today, 14:20'**
  String get transactionToday;

  /// No description provided for @balanceAmount.
  ///
  /// In en, this message translates to:
  /// **'1,250,000 Toman'**
  String get balanceAmount;

  /// No description provided for @transactionDebit.
  ///
  /// In en, this message translates to:
  /// **'- 45,000 Toman'**
  String get transactionDebit;

  /// No description provided for @transactionCredit.
  ///
  /// In en, this message translates to:
  /// **'+ 500,000 Toman'**
  String get transactionCredit;

  /// No description provided for @limitedTime.
  ///
  /// In en, this message translates to:
  /// **'Limited Time'**
  String get limitedTime;

  /// No description provided for @paymentProviderShaparak.
  ///
  /// In en, this message translates to:
  /// **'Shaparak'**
  String get paymentProviderShaparak;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @minimumOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimumOrder;

  /// No description provided for @deliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryLabel;

  /// No description provided for @valuePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get valuePlaceholder;

  /// No description provided for @catBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get catBeverages;

  /// No description provided for @catSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get catSnacks;

  /// No description provided for @catMilkDairy.
  ///
  /// In en, this message translates to:
  /// **'Milk & Dairy'**
  String get catMilkDairy;

  /// No description provided for @catFruitsVeggies.
  ///
  /// In en, this message translates to:
  /// **'Fruits & Veg...'**
  String get catFruitsVeggies;

  /// No description provided for @catBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get catBreakfast;

  /// No description provided for @catBakedGoods.
  ///
  /// In en, this message translates to:
  /// **'Baked Goods'**
  String get catBakedGoods;

  /// No description provided for @catIceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get catIceCream;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catReadyToEat.
  ///
  /// In en, this message translates to:
  /// **'Ready to Eat'**
  String get catReadyToEat;

  /// No description provided for @catMeatPoultry.
  ///
  /// In en, this message translates to:
  /// **'Meat, Poultr...'**
  String get catMeatPoultry;

  /// No description provided for @catFitAndForm.
  ///
  /// In en, this message translates to:
  /// **'Fit & Form'**
  String get catFitAndForm;

  /// No description provided for @catHomeCare.
  ///
  /// In en, this message translates to:
  /// **'Home Care'**
  String get catHomeCare;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Iranian on-demand delivery platform'**
  String get aboutAppHeroSubtitle;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About the Developer'**
  String get aboutDeveloper;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @stack.
  ///
  /// In en, this message translates to:
  /// **'Stack'**
  String get stack;

  /// No description provided for @stackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter, Django, PostgreSQL, Redis, Neshan, FCM'**
  String get stackSubtitle;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @licenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Training use only'**
  String get licenseTitle;

  /// No description provided for @licenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Terms for this training project'**
  String get licenseSubtitle;

  /// No description provided for @licenseBody.
  ///
  /// In en, this message translates to:
  /// **'This project is just for training purposes. Using this for businesses or any commercial purpose is prohibited and is not ethical.'**
  String get licenseBody;

  /// No description provided for @noPromotions.
  ///
  /// In en, this message translates to:
  /// **'No promotions available.'**
  String get noPromotions;

  /// No description provided for @swipeTechStack.
  ///
  /// In en, this message translates to:
  /// **'Swipe to explore the stack'**
  String get swipeTechStack;

  /// No description provided for @betaPhase.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get betaPhase;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} {appName}. Beta release.'**
  String aboutCopyright(int year, String appName);

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email and avatar'**
  String get editProfileSubtitle;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order history and status'**
  String get myOrdersSubtitle;

  /// No description provided for @addressManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery addresses'**
  String get addressManageSubtitle;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help and contact support'**
  String get supportSubtitle;

  /// No description provided for @devDebugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get devDebugSubtitle;

  /// No description provided for @developerRole.
  ///
  /// In en, this message translates to:
  /// **'Lead Flutter Developer'**
  String get developerRole;

  /// No description provided for @navTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @techFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get techFlutter;

  /// No description provided for @techFlutterDesc.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform customer app UI'**
  String get techFlutterDesc;

  /// No description provided for @techDjango.
  ///
  /// In en, this message translates to:
  /// **'Django'**
  String get techDjango;

  /// No description provided for @techDjangoDesc.
  ///
  /// In en, this message translates to:
  /// **'REST API and real-time backend'**
  String get techDjangoDesc;

  /// No description provided for @techWebSocket.
  ///
  /// In en, this message translates to:
  /// **'WebSocket'**
  String get techWebSocket;

  /// No description provided for @techWebSocketDesc.
  ///
  /// In en, this message translates to:
  /// **'Live order and courier tracking'**
  String get techWebSocketDesc;

  /// No description provided for @techNeshan.
  ///
  /// In en, this message translates to:
  /// **'Neshan Maps'**
  String get techNeshan;

  /// No description provided for @techNeshanDesc.
  ///
  /// In en, this message translates to:
  /// **'Maps, routing and geocoding'**
  String get techNeshanDesc;

  /// No description provided for @techPostgres.
  ///
  /// In en, this message translates to:
  /// **'PostgreSQL'**
  String get techPostgres;

  /// No description provided for @techPostgresDesc.
  ///
  /// In en, this message translates to:
  /// **'Primary relational database'**
  String get techPostgresDesc;

  /// No description provided for @techPostgresDetail.
  ///
  /// In en, this message translates to:
  /// **'All orders, catalog, accounts, wallet balances, and dine-in venue data are stored in PostgreSQL with Django ORM migrations.'**
  String get techPostgresDetail;

  /// No description provided for @techPostgresUse1.
  ///
  /// In en, this message translates to:
  /// **'Orders, vendors, items, and dine-in tables'**
  String get techPostgresUse1;

  /// No description provided for @techPostgresUse2.
  ///
  /// In en, this message translates to:
  /// **'User profiles, wallet, and delivery assignments'**
  String get techPostgresUse2;

  /// No description provided for @techRedis.
  ///
  /// In en, this message translates to:
  /// **'Redis & Celery'**
  String get techRedis;

  /// No description provided for @techRedisDesc.
  ///
  /// In en, this message translates to:
  /// **'Caching, queues, and real-time pub/sub'**
  String get techRedisDesc;

  /// No description provided for @techRedisDetail.
  ///
  /// In en, this message translates to:
  /// **'Redis backs Django Channels groups, optional dine-in table holds, and Celery workers for async jobs and scheduled beats.'**
  String get techRedisDetail;

  /// No description provided for @techRedisUse1.
  ///
  /// In en, this message translates to:
  /// **'WebSocket channel layer for live tracking'**
  String get techRedisUse1;

  /// No description provided for @techRedisUse2.
  ///
  /// In en, this message translates to:
  /// **'5-minute dine-in table hold TTL'**
  String get techRedisUse2;

  /// No description provided for @techRedisUse3.
  ///
  /// In en, this message translates to:
  /// **'Background tasks via Celery + django-celery-beat'**
  String get techRedisUse3;

  /// No description provided for @techLiveKit.
  ///
  /// In en, this message translates to:
  /// **'LiveKit'**
  String get techLiveKit;

  /// No description provided for @techLiveKitDesc.
  ///
  /// In en, this message translates to:
  /// **'In-app voice calls'**
  String get techLiveKitDesc;

  /// No description provided for @techLiveKitDetail.
  ///
  /// In en, this message translates to:
  /// **'LiveKit rooms connect customers and couriers during active deliveries. The backend mints tokens via livekit-api; the Flutter app uses livekit_client.'**
  String get techLiveKitDetail;

  /// No description provided for @techLiveKitUse1.
  ///
  /// In en, this message translates to:
  /// **'Voice call screen on the tracking tab'**
  String get techLiveKitUse1;

  /// No description provided for @techLiveKitUse2.
  ///
  /// In en, this message translates to:
  /// **'Token API on the communications backend'**
  String get techLiveKitUse2;

  /// No description provided for @techFirebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase FCM'**
  String get techFirebase;

  /// No description provided for @techFirebaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get techFirebaseDesc;

  /// No description provided for @techFirebaseDetail.
  ///
  /// In en, this message translates to:
  /// **'firebase-admin sends multicast FCM messages when order status changes or a courier is assigned. Device tokens are stored per user.'**
  String get techFirebaseDetail;

  /// No description provided for @techFirebaseUse1.
  ///
  /// In en, this message translates to:
  /// **'Order status and delivery alerts'**
  String get techFirebaseUse1;

  /// No description provided for @techFirebaseUse2.
  ///
  /// In en, this message translates to:
  /// **'Registered FCM tokens in communications app'**
  String get techFirebaseUse2;

  /// No description provided for @techFlutterDetail.
  ///
  /// In en, this message translates to:
  /// **'The customer app (getir_style_delivery_ui_v2) and courier app (getir_style_delivery_ui_peyk) share Flutter patterns: Provider for state, Dio for REST, and Material 3 theming with Persian/RTL support.'**
  String get techFlutterDetail;

  /// No description provided for @techFlutterUse1.
  ///
  /// In en, this message translates to:
  /// **'Home, dine-in 360°, cart, checkout, and wallet UI'**
  String get techFlutterUse1;

  /// No description provided for @techFlutterUse2.
  ///
  /// In en, this message translates to:
  /// **'Live order tracking map with flutter_map'**
  String get techFlutterUse2;

  /// No description provided for @techFlutterUse3.
  ///
  /// In en, this message translates to:
  /// **'Secure JWT storage via flutter_secure_storage'**
  String get techFlutterUse3;

  /// No description provided for @techDjangoDetail.
  ///
  /// In en, this message translates to:
  /// **'getir_style_delivery_ui_backend exposes versioned REST APIs under /api/v1/ for catalog, orders, wallet, payments, and tracking. JWT auth via simplejwt; admin via django-unfold.'**
  String get techDjangoDetail;

  /// No description provided for @techDjangoUse1.
  ///
  /// In en, this message translates to:
  /// **'Catalog, orders, dine-in, and wallet endpoints'**
  String get techDjangoUse1;

  /// No description provided for @techDjangoUse2.
  ///
  /// In en, this message translates to:
  /// **'Role-based access for customer, vendor, peyk, operator'**
  String get techDjangoUse2;

  /// No description provided for @techDjangoUse3.
  ///
  /// In en, this message translates to:
  /// **'Media uploads via django-storages (S3-compatible)'**
  String get techDjangoUse3;

  /// No description provided for @techWebSocketDetail.
  ///
  /// In en, this message translates to:
  /// **'ASGI workers run Django Channels consumers for order and courier location streams. The Flutter tracking tab subscribes via web_socket_channel.'**
  String get techWebSocketDetail;

  /// No description provided for @techWebSocketUse1.
  ///
  /// In en, this message translates to:
  /// **'Real-time courier location on the map'**
  String get techWebSocketUse1;

  /// No description provided for @techWebSocketUse2.
  ///
  /// In en, this message translates to:
  /// **'Order status updates without polling'**
  String get techWebSocketUse2;

  /// No description provided for @techNeshanDetail.
  ///
  /// In en, this message translates to:
  /// **'Neshan Static Map v5 renders tiles through a backend proxy (Api-Key header). Reverse geocoding powers address pickers; coordinates anchor dine-in venues.'**
  String get techNeshanDetail;

  /// No description provided for @techNeshanUse1.
  ///
  /// In en, this message translates to:
  /// **'Address picker and tracking map tiles'**
  String get techNeshanUse1;

  /// No description provided for @techNeshanUse2.
  ///
  /// In en, this message translates to:
  /// **'Restaurant venue preview pins'**
  String get techNeshanUse2;

  /// No description provided for @techNeshanUse3.
  ///
  /// In en, this message translates to:
  /// **'Backend /api/v1/tracking/tiles/ proxy for Android'**
  String get techNeshanUse3;

  /// No description provided for @stackPackagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Libraries & packages'**
  String get stackPackagesLabel;

  /// No description provided for @stackUsedInLabel.
  ///
  /// In en, this message translates to:
  /// **'Used in GetirStyleDeliveryUi'**
  String get stackUsedInLabel;

  /// No description provided for @stackViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get stackViewDetails;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currencyToman.
  ///
  /// In en, this message translates to:
  /// **'Toman'**
  String get currencyToman;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total ({count})'**
  String cartTotal(int count);

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @editCart.
  ///
  /// In en, this message translates to:
  /// **'Edit cart'**
  String get editCart;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @fullAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full address'**
  String get fullAddressHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @walletPay.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletPay;

  /// No description provided for @walletBalanceLoading.
  ///
  /// In en, this message translates to:
  /// **'Balance…'**
  String get walletBalanceLoading;

  /// No description provided for @walletBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String walletBalanceLabel(String amount);

  /// No description provided for @onlinePay.
  ///
  /// In en, this message translates to:
  /// **'Online payment'**
  String get onlinePay;

  /// No description provided for @zarinpalGateway.
  ///
  /// In en, this message translates to:
  /// **'Zarinpal gateway'**
  String get zarinpalGateway;

  /// No description provided for @payAtDoor.
  ///
  /// In en, this message translates to:
  /// **'Pay on delivery'**
  String get payAtDoor;

  /// No description provided for @payAtDoorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get payAtDoorSubtitle;

  /// No description provided for @payableAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount payable'**
  String get payableAmount;

  /// No description provided for @cartEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmptyError;

  /// No description provided for @enterDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a delivery address.'**
  String get enterDeliveryAddress;

  /// No description provided for @orderPlacedWallet.
  ///
  /// In en, this message translates to:
  /// **'Order placed and paid from wallet.'**
  String get orderPlacedWallet;

  /// No description provided for @orderPlacedOnline.
  ///
  /// In en, this message translates to:
  /// **'Order placed. Pay online: {url}'**
  String orderPlacedOnline(String url);

  /// No description provided for @orderPlacedCash.
  ///
  /// In en, this message translates to:
  /// **'Order placed. Pay on delivery.'**
  String get orderPlacedCash;

  /// No description provided for @orderPlaceError.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order.'**
  String get orderPlaceError;

  /// No description provided for @vendorMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Different vendor'**
  String get vendorMismatchTitle;

  /// No description provided for @vendorMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'Your cart has items from another vendor. Start a new cart?'**
  String get vendorMismatchBody;

  /// No description provided for @newCart.
  ///
  /// In en, this message translates to:
  /// **'New cart'**
  String get newCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String addedToCart(String name);

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get orderStatusPickedUp;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You have not placed any orders yet'**
  String get noOrdersYet;

  /// No description provided for @orderFallback.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderFallback;

  /// No description provided for @deliveryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery code:'**
  String get deliveryCodeLabel;

  /// No description provided for @supportHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get supportHeroTitle;

  /// No description provided for @supportHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The GetirStyleDeliveryUi support team is here for you every day.'**
  String get supportHeroSubtitle;

  /// No description provided for @contactMethods.
  ///
  /// In en, this message translates to:
  /// **'Contact methods'**
  String get contactMethods;

  /// No description provided for @phoneContact.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneContact;

  /// No description provided for @emailContact.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailContact;

  /// No description provided for @onlineChat.
  ///
  /// In en, this message translates to:
  /// **'Online chat'**
  String get onlineChat;

  /// No description provided for @onlineChatValue.
  ///
  /// In en, this message translates to:
  /// **'Instant reply in the app'**
  String get onlineChatValue;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business hours'**
  String get businessHours;

  /// No description provided for @businessHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Every day 9 AM – 11 PM'**
  String get businessHoursValue;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @faqTrackOrderQ.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get faqTrackOrderQ;

  /// No description provided for @faqTrackOrderA.
  ///
  /// In en, this message translates to:
  /// **'Use the Tracking tab to see courier location and order stages on the map.'**
  String get faqTrackOrderA;

  /// No description provided for @faqPaymentQ.
  ///
  /// In en, this message translates to:
  /// **'What payment methods are available?'**
  String get faqPaymentQ;

  /// No description provided for @faqPaymentA.
  ///
  /// In en, this message translates to:
  /// **'Wallet, online payment, and pay on delivery are supported.'**
  String get faqPaymentA;

  /// No description provided for @faqAddressQ.
  ///
  /// In en, this message translates to:
  /// **'How do I add an address?'**
  String get faqAddressQ;

  /// No description provided for @faqAddressA.
  ///
  /// In en, this message translates to:
  /// **'From the top bar on the home screen or My Addresses in profile.'**
  String get faqAddressA;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get profileUpdateFailed;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @selectAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get selectAvatar;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick location on map'**
  String get mapPickerTitle;

  /// No description provided for @pickOnMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map or tap your desired point'**
  String get pickOnMapHint;

  /// No description provided for @resolvingAddress.
  ///
  /// In en, this message translates to:
  /// **'Finding address…'**
  String get resolvingAddress;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'No address found for this point'**
  String get addressNotFound;

  /// No description provided for @continueCompleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Continue & complete address'**
  String get continueCompleteAddress;

  /// No description provided for @completeAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete address'**
  String get completeAddressTitle;

  /// No description provided for @mapLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected on the map. Edit details if needed.'**
  String get mapLocationSelected;

  /// No description provided for @addressTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (home, work)'**
  String get addressTitleLabel;

  /// No description provided for @fullAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get fullAddressLabel;

  /// No description provided for @searchOrEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Search or edit address…'**
  String get searchOrEditAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @defaultAddressSaved.
  ///
  /// In en, this message translates to:
  /// **'Default address saved'**
  String get defaultAddressSaved;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddress;

  /// No description provided for @moveMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map'**
  String get moveMapHint;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location. Check permissions and try again.'**
  String get locationUnavailable;

  /// No description provided for @addressFallback.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressFallback;

  /// No description provided for @discounted.
  ///
  /// In en, this message translates to:
  /// **'Discounted'**
  String get discounted;

  /// No description provided for @todaySpecials.
  ///
  /// In en, this message translates to:
  /// **'Today\'s specials'**
  String get todaySpecials;

  /// No description provided for @deliveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String deliveryMinutes(int minutes);

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get addMore;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @upsellTitle.
  ///
  /// In en, this message translates to:
  /// **'You might also add'**
  String get upsellTitle;

  /// No description provided for @aiBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Q&A'**
  String get aiBannerSubtitle;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @receivedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Received this month'**
  String get receivedThisMonth;

  /// No description provided for @paidThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Paid this month'**
  String get paidThisMonth;

  /// No description provided for @txnCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String txnCount(int count);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @totalTopUp.
  ///
  /// In en, this message translates to:
  /// **'Total top-up'**
  String get totalTopUp;

  /// No description provided for @lastTopUp.
  ///
  /// In en, this message translates to:
  /// **'Last top-up'**
  String get lastTopUp;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get filterCredit;

  /// No description provided for @filterDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get filterDebit;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions to show'**
  String get noTransactions;

  /// No description provided for @txnTypeTopup.
  ///
  /// In en, this message translates to:
  /// **'Wallet top-up'**
  String get txnTypeTopup;

  /// No description provided for @txnTypeOrderPayment.
  ///
  /// In en, this message translates to:
  /// **'Order payment'**
  String get txnTypeOrderPayment;

  /// No description provided for @txnTypeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get txnTypeRefund;

  /// No description provided for @txnTypeAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Balance adjustment'**
  String get txnTypeAdjustment;

  /// No description provided for @txnGeneric.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get txnGeneric;

  /// No description provided for @balanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String balanceAfter(String amount);

  /// No description provided for @topUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start wallet top-up.'**
  String get topUpFailed;

  /// No description provided for @paymentLink.
  ///
  /// In en, this message translates to:
  /// **'Payment link: {url}'**
  String paymentLink(String url);

  /// No description provided for @orderDeliveredSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your order was delivered ✅'**
  String get orderDeliveredSnackbar;

  /// No description provided for @callAfterPeykAssigned.
  ///
  /// In en, this message translates to:
  /// **'You can call once a courier is assigned.'**
  String get callAfterPeykAssigned;

  /// No description provided for @callUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the call.'**
  String get callUnavailable;

  /// No description provided for @etaTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get etaTitle;

  /// No description provided for @assignedPeykTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier assigned'**
  String get assignedPeykTitle;

  /// No description provided for @orderStatusHeader.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderStatusHeader;

  /// No description provided for @arrivingSoon.
  ///
  /// In en, this message translates to:
  /// **'Arriving soon'**
  String get arrivingSoon;

  /// No description provided for @etaMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String etaMinutes(int minutes);

  /// No description provided for @peykPickingUp.
  ///
  /// In en, this message translates to:
  /// **'Courier picking up from vendor'**
  String get peykPickingUp;

  /// No description provided for @awaitingPreparation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting preparation'**
  String get awaitingPreparation;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @peykLocationAfterPickup.
  ///
  /// In en, this message translates to:
  /// **'Courier location appears after pickup from vendor'**
  String get peykLocationAfterPickup;

  /// No description provided for @livePeykLocation.
  ///
  /// In en, this message translates to:
  /// **'Live courier location'**
  String get livePeykLocation;

  /// No description provided for @awaitingPeykLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for courier location'**
  String get awaitingPeykLocation;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance}'**
  String distanceLabel(String distance);

  /// No description provided for @orderFromVendor.
  ///
  /// In en, this message translates to:
  /// **'Order from {vendor}'**
  String orderFromVendor(String vendor);

  /// No description provided for @deliveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery code'**
  String get deliveryCodeTitle;

  /// No description provided for @tellCodeToPeyk.
  ///
  /// In en, this message translates to:
  /// **'Tell this code to the courier on delivery'**
  String get tellCodeToPeyk;

  /// No description provided for @stepPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get stepPreparing;

  /// No description provided for @stepOnWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get stepOnWay;

  /// No description provided for @stepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get stepDelivered;

  /// No description provided for @noActiveOrder.
  ///
  /// In en, this message translates to:
  /// **'No active order'**
  String get noActiveOrder;

  /// No description provided for @noActiveOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'After you place an order, the map and delivery stages appear here.'**
  String get noActiveOrderDesc;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get yourCart;

  /// No description provided for @getirStyleDeliveryUiCourier.
  ///
  /// In en, this message translates to:
  /// **'GetirStyleDeliveryUi courier'**
  String get getirStyleDeliveryUiCourier;

  /// No description provided for @deliveringYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Delivering your order'**
  String get deliveringYourOrder;

  /// No description provided for @peykReceivingFromVendor.
  ///
  /// In en, this message translates to:
  /// **'Courier picking up from vendor'**
  String get peykReceivingFromVendor;

  /// No description provided for @awaitingPeykAssignment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for courier assignment'**
  String get awaitingPeykAssignment;

  /// No description provided for @orderConfirmedPreparing.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed — preparing'**
  String get orderConfirmedPreparing;

  /// No description provided for @orderRegistered.
  ///
  /// In en, this message translates to:
  /// **'Your order was placed'**
  String get orderRegistered;

  /// No description provided for @voiceCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCallTitle;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// No description provided for @awaitingPeykConnect.
  ///
  /// In en, this message translates to:
  /// **'Waiting for courier to connect…'**
  String get awaitingPeykConnect;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Call connected'**
  String get callConnected;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Call connection failed.'**
  String get callFailed;

  /// No description provided for @micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice calls.'**
  String get micPermissionRequired;

  /// No description provided for @roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room: {name}'**
  String roomLabel(String name);

  /// No description provided for @muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get muted;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get endCall;

  /// No description provided for @exitCall.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitCall;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get genericError;

  /// No description provided for @devOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'Test code (dev mode)'**
  String get devOtpLabel;

  /// No description provided for @betaOtpHint.
  ///
  /// In en, this message translates to:
  /// **'In beta, the code is shown on this screen'**
  String get betaOtpHint;

  /// No description provided for @devOtpSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Dev OTP: {code}'**
  String devOtpSnackbar(String code);

  /// No description provided for @devDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Dev Debug'**
  String get devDebugTitle;

  /// No description provided for @devClearSession.
  ///
  /// In en, this message translates to:
  /// **'Clear session (logout)'**
  String get devClearSession;

  /// No description provided for @dineInTitle.
  ///
  /// In en, this message translates to:
  /// **'Dine-in'**
  String get dineInTitle;

  /// No description provided for @dineInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your table in 360° and order from your seat'**
  String get dineInSubtitle;

  /// No description provided for @dineInEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dine-in restaurants available yet'**
  String get dineInEmpty;

  /// No description provided for @noDineInRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No dine-in restaurants available yet'**
  String get noDineInRestaurants;

  /// No description provided for @dineInLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load restaurants. Pull to refresh.'**
  String get dineInLoadError;

  /// No description provided for @loadVenueError.
  ///
  /// In en, this message translates to:
  /// **'Could not load restaurant details. Try again.'**
  String get loadVenueError;

  /// No description provided for @enterRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Enter restaurant'**
  String get enterRestaurant;

  /// No description provided for @selectYourTable.
  ///
  /// In en, this message translates to:
  /// **'Select your table'**
  String get selectYourTable;

  /// No description provided for @selectTable.
  ///
  /// In en, this message translates to:
  /// **'Select your table'**
  String get selectTable;

  /// No description provided for @confirmTable.
  ///
  /// In en, this message translates to:
  /// **'Confirm table'**
  String get confirmTable;

  /// No description provided for @tableOccupied.
  ///
  /// In en, this message translates to:
  /// **'This table is not available'**
  String get tableOccupied;

  /// No description provided for @tableHoldFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reserve this table. Try another.'**
  String get tableHoldFailed;

  /// No description provided for @dineInFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Dine-in'**
  String get dineInFulfillment;

  /// No description provided for @dineInCheckoutSummary.
  ///
  /// In en, this message translates to:
  /// **'{table} — {restaurant}'**
  String dineInCheckoutSummary(String table, String restaurant);

  /// No description provided for @dineInTableSummary.
  ///
  /// In en, this message translates to:
  /// **'{table} — {restaurant}'**
  String dineInTableSummary(String table, String restaurant);

  /// No description provided for @dineInSeats.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String dineInSeats(int count);

  /// No description provided for @restaurantAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get restaurantAbout;

  /// No description provided for @restaurantAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get restaurantAddress;

  /// No description provided for @restaurantFeaturedMenu.
  ///
  /// In en, this message translates to:
  /// **'Popular dishes'**
  String get restaurantFeaturedMenu;

  /// No description provided for @restaurant360Booking.
  ///
  /// In en, this message translates to:
  /// **'360° table booking'**
  String get restaurant360Booking;

  /// No description provided for @restaurantTablesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} tables available'**
  String restaurantTablesAvailable(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
