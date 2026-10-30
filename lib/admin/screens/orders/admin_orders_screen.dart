import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../models/shop_order.dart';
import '../../controllers/admin_orders_controller.dart';

class AdminOrdersScreen extends GetView<AdminOrdersController> {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
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
                  child: Text('No customer orders yet.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Incoming orders.',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  const Text(
                      'Verify price and stock before confirming a request.',
                      style: TextStyle(color: ShopColors.muted)),
                  const SizedBox(height: 20),
                  for (final order in controller.orders)
                    _AdminOrderCard(
                      order: order,
                      busy: controller.working.value,
                      onStatus: (status) =>
                          controller.changeStatus(order, status),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.busy,
    required this.onStatus,
  });

  final ShopOrder order;
  final bool busy;
  final ValueChanged<String> onStatus;
  static const statuses = <String>[
    'pending',
    'confirmed',
    'packed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: ShopColors.paper,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.customerName} • ₹${order.total}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${order.phone} • ${order.shippingAddress}'),
            const SizedBox(height: 12),
            for (final line in order.items)
              Text('${line['name']} • ${line['quantity']} × ₹${line['price']}',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: order.status,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Order status'),
              items: [
                for (final status in statuses)
                  DropdownMenuItem(
                      value: status, child: Text(status.toUpperCase())),
              ],
              onChanged: busy
                  ? null
                  : (status) {
                      if (status != null && status != order.status) {
                        onStatus(status);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
