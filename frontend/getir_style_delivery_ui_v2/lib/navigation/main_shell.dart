import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../core/providers/service_provider.dart';

import '../features/dine_in/dine_in_screen.dart';

import '../features/home/home_screen.dart';

import '../features/home/service_home_screen.dart';

import '../features/search/search_screen.dart';

import '../features/tracking/tracking_screen.dart';

import '../features/wallet/wallet_screen.dart';

import '../l10n/app_localizations.dart';

import '../widgets/floating_home_actions.dart';

import '../widgets/profile_drawer.dart';

import '../widgets/getir_style_delivery_ui_bottom_nav.dart';

import 'main_shell_scope.dart';



class MainShell extends StatefulWidget {

  const MainShell({super.key});



  @override

  State<MainShell> createState() => _MainShellState();

}



class _MainShellState extends State<MainShell> with TickerProviderStateMixin {

  static const _trackingTabIndex = 3;



  final _shellKey = GlobalKey<ScaffoldState>();



  int _index = 0;

  final Set<int> _visited = {0};



  late final AnimationController _tabFade;



  @override

  void initState() {

    super.initState();

    _tabFade = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 260),

      value: 1,

    );

  }



  @override

  void dispose() {

    _tabFade.dispose();

    super.dispose();

  }



  void _openProfileDrawer() {

    _shellKey.currentState?.openDrawer();

  }



  void _onTabSelected(int index) {

    _animateToTab(index);

  }



  Future<void> _animateToTab(int index) async {

    if (index == _index) return;



    await _tabFade.reverse();

    if (!mounted) return;



    setState(() {

      _index = index;

      _visited.add(index);

    });



    _tabFade.forward(from: 0);

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    final serviceProvider = context.watch<ServiceProvider>();



    final homeScreen = serviceProvider.hasService

        ? ServiceHomeScreen(service: serviceProvider.selected!)

        : const HomeScreen();



    final screens = [

      homeScreen,

      const DineInScreen(),

      const SearchScreen(),

      const TrackingScreen(),

      const WalletScreen(),

    ];



    return MainShellScope(

      openProfileDrawer: _openProfileDrawer,

      child: Scaffold(

        key: _shellKey,

        extendBody: true,

        drawer: const ProfileDrawer(),

        body: Stack(

          children: [

            FadeTransition(

              opacity: CurvedAnimation(

                parent: _tabFade,

                curve: Curves.easeOutCubic,

              ),

              child: IndexedStack(

                index: _index,

                sizing: StackFit.expand,

                children: [

                  for (var i = 0; i < screens.length; i++)

                    RepaintBoundary(

                      child: _visited.contains(i)

                          ? screens[i]

                          : const SizedBox.shrink(),

                    ),

                ],

              ),

            ),

            FloatingHomeActions(

              showAi: _index != _trackingTabIndex,

              showCart: _index != _trackingTabIndex,

            ),

          ],

        ),

        bottomNavigationBar: GetirStyleDeliveryUiBottomNav(

          currentIndex: _index,

          onTap: _onTabSelected,

          items: [

            GetirStyleDeliveryUiNavItem(icon: Icons.home, label: l10n.navHome),

            GetirStyleDeliveryUiNavItem(icon: Icons.restaurant, label: l10n.navDineIn),

            GetirStyleDeliveryUiNavItem(icon: Icons.search, label: l10n.navSearch),

            GetirStyleDeliveryUiNavItem(icon: Icons.delivery_dining, label: l10n.navTracking),

            GetirStyleDeliveryUiNavItem(icon: Icons.account_balance_wallet, label: l10n.navWallet),

          ],

        ),

      ),

    );

  }

}


