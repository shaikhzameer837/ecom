import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// Bottom-navigation shell. Tabs keep their state via IndexedStack.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final nav = Get.find<NavController>();
  final cart = Get.find<CartController>();
  final wishlist = Get.find<WishlistController>();

  @override
  void initState() {
    super.initState();
    // Guests browse without a cart/wishlist; realtime sync starts only once a
    // user is signed in (a fresh MainScreen is built after login). Binding
    // touches observables, so it must run after the first frame — doing it in
    // initState would mutate Rx values while the tabs are still building.
    if (Get.find<AuthController>().isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        cart.bind();
        wishlist.bind();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: nav.index.value,
          children: const [
            HomeScreen(),
            CategoriesScreen(),
            CartScreen(),
            WishlistScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav.index.value,
          onDestinationSelected: nav.changeTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: 'nav_categories'.tr,
            ),
            NavigationDestination(
              icon: _badged(const Icon(Icons.shopping_cart_outlined),
                  cart.itemCount),
              selectedIcon: _badged(
                  const Icon(Icons.shopping_cart_rounded), cart.itemCount),
              label: 'nav_cart'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: 'nav_wishlist'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: 'nav_profile'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badged(Widget icon, int count) => count == 0
      ? icon
      : Badge(label: Text('$count'), child: icon);
}
