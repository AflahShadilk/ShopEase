import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../controllers/customer_cart_controller.dart';
import '../cart/shop_cart_screen.dart';
import '../catalog/customer_catalog_screen.dart';
import '../orders/shop_orders_screen.dart';
import '../profile/customer_profile_screen.dart';

/// Customer-only navigation shell. No admin route or dependency is changed.
class CustomerHomeShell extends StatefulWidget {
  const CustomerHomeShell({super.key});

  @override
  State<CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<CustomerHomeShell> {
  int _selectedTab = 0;

  void _selectTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const CustomerCatalogScreen(),
          const ShopOrdersScreen(),
          ShopCartScreen(onExploreProducts: () => _selectTab(0)),
          const CustomerProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          height: 74,
          backgroundColor: ShopColors.paper,
          indicatorColor: ShopColors.orchid,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _selectedTab,
          onDestinationSelected: _selectTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Obx(() {
                final quantity = Get.find<CustomerCartController>().count;
                return Badge(
                  isLabelVisible: quantity > 0,
                  label: Text('$quantity'),
                  child: const Icon(Icons.shopping_bag_outlined),
                );
              }),
              selectedIcon: const Icon(Icons.shopping_bag_rounded),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
