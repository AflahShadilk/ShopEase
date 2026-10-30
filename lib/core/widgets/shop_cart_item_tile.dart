import 'package:flutter/material.dart';

import '../../models/shop_cart_line.dart';
import '../theme/shop_colors.dart';

class ShopCartItemTile extends StatelessWidget {
  const ShopCartItemTile({
    super.key,
    required this.line,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final ShopCartLine line;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShopColors.paper,
        border: Border.all(color: ShopColors.stroke),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 68,
              height: 84,
              child: ColoredBox(
                color: ShopColors.orchid,
                child: line.product.imageUrl.isEmpty
                    ? const Icon(Icons.shopping_bag_outlined,
                        color: ShopColors.dragonfruit)
                    : Image.network(
                        line.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: ShopColors.dragonfruit,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text('₹${line.product.price} each',
                    style: const TextStyle(color: ShopColors.muted)),
                const SizedBox(height: 9),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    IconButton.outlined(
                      tooltip: 'Decrease quantity',
                      icon: const Icon(Icons.remove, size: 17),
                      onPressed: onDecrease,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('${line.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    IconButton.outlined(
                      tooltip: 'Increase quantity',
                      icon: const Icon(Icons.add, size: 17),
                      onPressed: line.quantity < line.product.stock
                          ? onIncrease
                          : null,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: ShopColors.danger,
                      onPressed: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text('₹${line.total}',
                    style: const TextStyle(
                      color: ShopColors.fig,
                      fontWeight: FontWeight.w800,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
