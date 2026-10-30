import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../models/shop_order.dart';
import '../../controllers/customer_orders_controller.dart';

class ShopOrdersScreen extends GetView<CustomerOrdersController> {
  const ShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty) {
                return Text(controller.error.value);
              }
              if (controller.orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'No orders yet. Your order history will appear here.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A little joy, on its way.',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  for (final order in controller.orders)
                    _OrderCard(order: order),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ShopColors.paper,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleLarge),
                Chip(label: Text(order.status.toUpperCase())),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.items.length} product types • ₹${order.total}'),
            const SizedBox(height: 6),
            for (final item in order.items)
              Text('${item['name']} × ${item['quantity']}',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(order.shippingAddress,
                style: const TextStyle(color: ShopColors.muted)),
          ],
        ),
      ),
    );
  }
}
