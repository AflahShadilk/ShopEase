import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_brand.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../core/widgets/shop_cart_item_tile.dart';
import '../../../services/order_service.dart';
import '../../controllers/customer_cart_controller.dart';
import '../../controllers/shop_checkout_controller.dart';
import '../orders/shop_orders_screen.dart';
import 'shop_checkout_screen.dart';

class ShopCartScreen extends GetView<CustomerCartController> {
  const ShopCartScreen({super.key});

  void _checkout() {
    Get.to<void>(
      () => const ShopCheckoutScreen(),
      binding: BindingsBuilder(() {
        Get.put(ShopCheckoutController(
          cart: Get.find<CustomerCartController>(),
          orders: Get.find<OrderService>(),
        ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ShopBrand(markSize: 32),
        actions: [
          IconButton(
            tooltip: 'My orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Get.to<void>(() => const ShopOrdersScreen()),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 400;
        return SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(compact ? 12 : 20, 20, compact ? 12 : 20, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Obx(() {
                final lines = controller.lines;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOUR FINDS / THE BAG',
                        style: TextStyle(
                          color: ShopColors.dragonfruit,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.7,
                        )),
                    const SizedBox(height: 12),
                    Text('Your bag, your way.',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    if (lines.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child:
                            Text('Your bag is empty. Find something you love!'),
                      ),
                      ShopButton(
                          label: 'Explore products',
                          onPressed: () => Get.back<void>()),
                    ] else ...[
                      for (final line in lines)
                        ShopCartItemTile(
                          key: ValueKey(line.product.id),
                          line: line,
                          onIncrease: () =>
                              controller.increase(line.product.id),
                          onDecrease: () =>
                              controller.decrease(line.product.id),
                          onRemove: () => controller.remove(line.product.id),
                        ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ShopColors.orchid,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        '${controller.count} items • Subtotal')),
                                Text('₹${controller.subtotal}',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  'Demo checkout • Cash on delivery only',
                                  style: TextStyle(color: ShopColors.muted)),
                            ),
                            const SizedBox(height: 18),
                            ShopButton(
                              label: 'Continue to checkout',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: _checkout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}
