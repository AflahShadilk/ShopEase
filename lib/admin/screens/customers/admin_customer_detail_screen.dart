import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_order_timeline.dart';
import '../../../models/shop_customer.dart';
import '../../../models/shop_order.dart';
import '../../controllers/admin_customer_orders_controller.dart';

class AdminCustomerDetailScreen extends GetView<AdminCustomerOrdersController> {
  const AdminCustomerDetailScreen({super.key, required this.customer});

  final ShopCustomer customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE CONTROL ROOM / CUSTOMER',
                  style: TextStyle(
                    color: ShopColors.dragonfruit,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(customer.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                SelectableText(customer.email,
                    style: const TextStyle(color: ShopColors.muted)),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Text(controller.error.value);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _Metric(
                              label: 'Orders',
                              value: '${controller.totalOrders}'),
                          _Metric(
                              label: 'Delivered',
                              value: '${controller.completedOrders}'),
                          _Metric(
                              label: 'Non-cancelled order value',
                              value: '₹${controller.lifetimeTotal}'),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text('ORDER HISTORY',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      if (controller.orders.isEmpty)
                        const Text(
                            'This customer has not placed an order yet.'),
                      for (final order in controller.orders)
                        _HistoryCard(order: order),
                    ],
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 135, maxWidth: 275),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopColors.paper,
        border: Border.all(color: ShopColors.stroke),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: ShopColors.muted)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});
  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length > 6 ? order.id.substring(0, 6) : order.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: ShopColors.paper,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                Text('Order #${shortId.toUpperCase()}',
                    style: Theme.of(context).textTheme.titleLarge),
                Chip(label: Text(order.status.toUpperCase())),
              ],
            ),
            const SizedBox(height: 8),
            Text('₹${order.total} • ${order.items.length} product types'),
            const SizedBox(height: 6),
            for (final item in order.items)
              Text('${item['name']} × ${item['quantity']}',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(order.shippingAddress,
                style: const TextStyle(color: ShopColors.muted)),
            const Divider(height: 28),
            ShopOrderTimeline(status: order.status),
          ],
        ),
      ),
    );
  }
}
