import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/shop_colors.dart';
import '../customer/screens/catalog/customer_catalog_screen.dart';
import '../admin/screens/products/admin_products_screen.dart';
import '../core/widgets/shop_brand.dart';
import '../core/widgets/shop_button.dart';
import '../services/auth_service.dart';
import 'controllers/shop_session_controller.dart';
import 'screens/shop_login_screen.dart';

/// Both entry points use this reactive gate with different required roles.
class ShopAuthGate extends StatelessWidget {
  const ShopAuthGate({super.key, this.isAdmin = false});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final session = Get.find<ShopSessionController>();
    return Obx(() {
      if (session.isChecking.value) {
        return const _GateMessage(message: 'Checking your session...');
      }
      if (session.error.value.isNotEmpty) {
        return _GateMessage(
          message: session.error.value,
          allowSignOut: session.user.value != null,
        );
      }
      final user = session.user.value;
      if (user == null) return ShopLoginScreen(isAdmin: isAdmin);

      final data = session.profile.value;
      if (data == null) {
        return const _GateMessage(
          message: 'Profile not found. Check your Firestore profile or rules.',
          allowSignOut: true,
        );
      }
      final role = isAdmin ? 'admin' : 'customer';
      if (data['role'] != role) {
        return const _GateMessage(
          message: 'This account is not authorized for this application.',
          allowSignOut: true,
        );
      }
      return isAdmin
          ? const AdminProductsScreen()
          : const CustomerCatalogScreen();
    });
  }
}

class _GateMessage extends StatelessWidget {
  const _GateMessage({required this.message, this.allowSignOut = false});
  final String message;
  final bool allowSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShopBrand(),
                const SizedBox(height: 26),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 22),
                if (allowSignOut)
                  ShopButton(
                    label: 'Sign out',
                    onPressed: () => Get.find<AuthService>().logout(),
                  )
                else
                  const CircularProgressIndicator(
                    color: ShopColors.dragonfruit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
