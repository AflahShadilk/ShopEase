import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_brand.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../core/widgets/shop_header_actions.dart';
import '../../../models/shop_product.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';
import '../../widgets/admin_product_row.dart';
import '../orders/admin_orders_screen.dart';
import '../customers/admin_customers_screen.dart';
import '../../controllers/admin_products_controller.dart';
import '../../controllers/product_form_controller.dart';
import 'product_form_screen.dart';

class AdminProductsScreen extends GetView<AdminProductsController> {
  const AdminProductsScreen({super.key});

  void _openEditor(ShopProduct? product) {
    Get.to<void>(
      () => const ProductFormScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProductFormController(
          service: Get.find<ProductService>(),
          product: product,
        ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ShopBrand(markSize: 34),
        actions: [
          ShopAdminHeaderActions(
            onCustomers: () => Get.to<void>(() => const AdminCustomersScreen()),
            onOrders: () => Get.to<void>(() => const AdminOrdersScreen()),
            onLogout: () => Get.find<AuthService>().logout(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THE CONTROL ROOM / PRODUCTS',
                    style: TextStyle(
                        color: ShopColors.dragonfruit,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.7)),
                const SizedBox(height: 12),
                Text('The merch desk.',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                const Text(
                    'Create, edit and curate what customers can discover.'),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: ShopButton(
                    label: 'Add product',
                    icon: Icons.add_rounded,
                    onPressed: () => _openEditor(null),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Text(controller.error.value);
                  }
                  if (controller.products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text('No products yet. Add your first item.'),
                    );
                  }
                  return Column(
                    children: controller.products
                        .map((product) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AdminProductRow(
                                product: product,
                                isBusy: controller.isWorking.value,
                                onEdit: () => _openEditor(product),
                                onVisibility: () =>
                                    controller.changeVisibility(product),
                                onDelete: () => controller.delete(product),
                              ),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
