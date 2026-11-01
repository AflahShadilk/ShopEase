import 'package:flutter/material.dart';

import '../../models/shop_product.dart';
import '../../core/theme/shop_colors.dart';

/// Customer-only product presentation, keeping the original shared card intact.
class CustomerProductTile extends StatelessWidget {
  const CustomerProductTile({
    super.key,
    required this.product,
    required this.onTap,
    this.isGrid = true,
  });

  final ShopProduct product;
  final VoidCallback onTap;
  final bool isGrid;

  @override
  Widget build(BuildContext context) =>
      isGrid ? _grid(context) : _list(context);

  Widget _image() => ColoredBox(
        color: ShopColors.orchid,
        child: product.imageUrl.isEmpty
            ? const Center(
                child: Icon(Icons.auto_awesome_rounded,
                    size: 32, color: ShopColors.dragonfruit),
              )
            : Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 32, color: ShopColors.dragonfruit),
                ),
              ),
      );

  Widget _grid(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        color: ShopColors.paper,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: ShopColors.stroke),
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 5,
                  child: SizedBox(width: double.infinity, child: _image())),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .6,
                          color: ShopColors.dragonfruit,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Flexible(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 14),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${product.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 17),
                      ),
                      Text(
                        product.stock > 0
                            ? '${product.stock} available'
                            : 'Out of stock',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: ShopColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _list(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        color: ShopColors.paper,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: ShopColors.stroke),
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 90, height: 90, child: _image()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ShopColors.dragonfruit,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 3),
                      Text(product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 15)),
                      const SizedBox(height: 5),
                      Text('₹${product.price}',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 17,
                            color: ShopColors.fig,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          product.stock > 0
                              ? '${product.stock} available'
                              : 'Out of stock',
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 11, color: ShopColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: ShopColors.dragonfruit),
              ],
            ),
          ),
        ),
      );
}
