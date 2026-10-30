import 'package:flutter/material.dart';

import '../theme/shop_colors.dart';

/// Presentational widget. Status changes are handled by the admin controller.
class ShopOrderTimeline extends StatelessWidget {
  const ShopOrderTimeline({super.key, required this.status});

  final String status;

  static const steps = <String>[
    'pending',
    'confirmed',
    'packed',
    'shipped',
    'delivered',
  ];

  static int progressFor(String status) => steps.indexOf(status);

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return const Row(
        children: [
          Icon(Icons.cancel_outlined, color: ShopColors.danger),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Order cancelled',
              style: TextStyle(
                color: ShopColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    final current = progressFor(status);
    if (current < 0) {
      return Text('Status: $status');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORDER JOURNEY',
          style: TextStyle(
            color: ShopColors.dragonfruit,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  i <= current
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 21,
                  color:
                      i <= current ? ShopColors.dragonfruit : ShopColors.stroke,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _label(steps[i]),
                    style: TextStyle(
                      color: i <= current ? ShopColors.fig : ShopColors.muted,
                      fontWeight:
                          i == current ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
                if (i == current)
                  const Text(
                    'CURRENT',
                    style: TextStyle(
                      color: ShopColors.dragonfruit,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _label(String status) {
    switch (status) {
      case 'pending':
        return 'Order placed';
      case 'confirmed':
        return 'Order confirmed';
      case 'packed':
        return 'Packed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }
}
