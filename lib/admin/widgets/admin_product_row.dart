import 'package:flutter/material.dart';

import '../../core/theme/shop_colors.dart';
import '../../models/shop_product.dart';

/// Responsive admin list row. Image stays to the left at every screen size.
class AdminProductRow extends StatelessWidget {
  const AdminProductRow({
    super.key,
    required this.product,
    required this.isBusy,
    required this.onEdit,
    required this.onVisibility,
    required this.onDelete,
  });

  final ShopProduct product;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onVisibility;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShopColors.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ShopColors.stroke),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;
        final summary = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProductThumbnail(imageUrl: product.imageUrl, size: wide ? 80 : 66),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category}  •  ₹${product.price}  •  Stock: ${product.stock}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: ShopColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.isActive ? 'VISIBLE TO CUSTOMERS' : 'HIDDEN',
                    style: const TextStyle(
                      color: ShopColors.dragonfruit,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: isBusy ? null : onEdit,
            ),
            IconButton(
              tooltip: product.isActive ? 'Hide' : 'Publish',
              icon: Icon(product.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: isBusy ? null : onVisibility,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: isBusy ? null : onDelete,
            ),
          ],
        );

        if (wide) {
          return Row(children: [
            Expanded(child: summary),
            const SizedBox(width: 12),
            actions,
          ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            summary,
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        );
      }),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl, required this.size});
  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    final validUrl = Uri.tryParse(url);
    final useImage = validUrl != null &&
        validUrl.scheme == 'https' &&
        validUrl.host.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: ShopColors.cream,
          child: useImage
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                )
              : const _ThumbnailFallback(),
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: ShopColors.muted,
        ),
      );
}
