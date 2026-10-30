import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_brand.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../models/shop_product.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';
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
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Get.find<AuthService>().logout(),
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
                              child: _ProductRow(
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

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.isBusy,
    required this.onEdit,
    required this.onVisibility,
    required this.onDelete,
  });

  final ShopProduct product;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onVisibility;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopColors.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ShopColors.stroke),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
                '${product.category}  •  ₹${product.price}  •  Stock: ${product.stock}',
                style: const TextStyle(color: ShopColors.muted)),
            const SizedBox(height: 4),
            Text(product.isActive ? 'VISIBLE TO CUSTOMERS' : 'HIDDEN',
                style: const TextStyle(
                    color: ShopColors.dragonfruit,
                    fontWeight: FontWeight.w800,
                    fontSize: 11)),
          ],
        );
        final actions = Wrap(spacing: 4, children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isBusy ? null : onEdit,
          ),
          IconButton(
            tooltip: product.isActive ? 'Hide' : 'Publish',
            icon: Icon(product.isActive
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: isBusy ? null : onVisibility,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: isBusy ? null : onDelete,
          ),
        ]);
        return constraints.maxWidth >= 600
            ? Row(children: [Expanded(child: details), actions])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [details, const SizedBox(height: 10), actions]);
      }),
    );
  }
}
