import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_customer_card.dart';
import '../../../models/shop_customer.dart';
import '../../../services/customer_directory_service.dart';
import '../../../shared/controllers/shop_session_controller.dart';
import '../../controllers/admin_customer_orders_controller.dart';
import '../../controllers/admin_customers_controller.dart';
import 'admin_customer_detail_screen.dart';

class AdminCustomersScreen extends GetView<AdminCustomersController> {
  const AdminCustomersScreen({super.key});

  void _openCustomer(ShopCustomer customer) {
    Get.to<void>(
      () => AdminCustomerDetailScreen(customer: customer),
      binding: BindingsBuilder(() {
        Get.put(AdminCustomerOrdersController(
          service: Get.find<CustomerDirectoryService>(),
          session: Get.find<ShopSessionController>(),
          customerId: customer.id,
        ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE CONTROL ROOM / PEOPLE',
                  style: TextStyle(
                    color: ShopColors.dragonfruit,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text('The people behind every order.',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                const Text('Customer profiles and purchase history.',
                    style: TextStyle(color: ShopColors.muted)),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => controller.search.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Search customers',
                    hintText: 'Name or email',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Text(controller.error.value);
                  }
                  final items = controller.filteredCustomers;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No matching customers found.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final customer in items)
                        ShopCustomerCard(
                          customer: customer,
                          onTap: () => _openCustomer(customer),
                        ),
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
