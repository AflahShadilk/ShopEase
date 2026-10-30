import 'package:flutter/material.dart';

import '../../models/shop_product.dart';
import '../theme/shop_colors.dart';

class ShopProductCard extends StatelessWidget {
  const ShopProductCard({super.key, required this.product, this.onTap});

  final ShopProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ShopColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: ShopColors.stroke),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 158,
              width: double.infinity,
              child: ColoredBox(
                color: ShopColors.orchid,
                child: product.imageUrl.isEmpty
                    ? const Icon(Icons.auto_awesome_rounded,
                        size: 54, color: ShopColors.dragonfruit)
                    : Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: ShopColors.dragonfruit,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: ShopColors.dragonfruit,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 17),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text('₹${product.price}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: ShopColors.fig,
                                  )),
                        ),
                        Icon(
                          product.stock > 0
                              ? Icons.arrow_outward_rounded
                              : Icons.remove_shopping_cart_outlined,
                          color: ShopColors.dragonfruit,
                        ),
                      ],
                    ),
                    Text(
                      product.stock > 0
                          ? '${product.stock} available'
                          : 'Out of stock',
                      style: const TextStyle(
                          fontSize: 12, color: ShopColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
