import 'package:flutter/material.dart';

import '../../models/shop_customer.dart';
import '../theme/shop_colors.dart';

class ShopCustomerCard extends StatelessWidget {
  const ShopCustomerCard({super.key, required this.customer, this.onTap});

  final ShopCustomer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ShopColors.paper,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: ShopColors.stroke),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: ShopColors.orchid,
                child: Text(
                  customer.name.isEmpty
                      ? '?'
                      : customer.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: ShopColors.dragonfruit,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name.isEmpty
                          ? 'Unnamed customer'
                          : customer.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: ShopColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: ShopColors.dragonfruit),
            ],
          ),
        ),
      ),
    );
  }
}
