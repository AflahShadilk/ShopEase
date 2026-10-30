import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_brand.dart';
import '../../../core/widgets/shop_product_card.dart';
import '../../../models/shop_product.dart';
import '../../../services/auth_service.dart';
import '../../controllers/customer_catalog_controller.dart';

class CustomerCatalogScreen extends GetView<CustomerCatalogController> {
  const CustomerCatalogScreen({super.key});

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
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: ShopColors.fig,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURATED FOR THE CURIOUS',
                          style: TextStyle(
                              color: ShopColors.yuzu,
                              fontSize: 11,
                              letterSpacing: 1.7,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text('Find your next favorite.',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: Colors.white, fontSize: 31)),
                      const SizedBox(height: 8),
                      const Text('Good finds. Great energy. Only on ShopEase.',
                          style: TextStyle(color: ShopColors.orchid)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('THE GOOD STUFF',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(controller.error.value),
                    );
                  }
                  final products = controller.products;
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child:
                          Text('Nothing on the shelves yet. Check back soon!'),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1020
                          ? 4
                          : width >= 700
                              ? 3
                              : width >= 440
                                  ? 2
                                  : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 335,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ShopProductCard(
                            product: product,
                            onTap: () => _showDetails(product),
                          );
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(ShopProduct product) {
    Get.bottomSheet<void>(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: ShopColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product.category.toUpperCase(),
                    style: const TextStyle(
                        color: ShopColors.dragonfruit,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 10),
                Text(product.name, style: Get.textTheme.headlineMedium),
                const SizedBox(height: 14),
                Text(product.description),
                const SizedBox(height: 18),
                Text(
                    '₹${product.price} • ${product.stock > 0 ? '${product.stock} in stock' : 'Out of stock'}',
                    style: Get.textTheme.titleLarge),
                const SizedBox(height: 10),
                const Text('Cart and checkout are coming in the next feature.',
                    style: TextStyle(color: ShopColors.muted)),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
