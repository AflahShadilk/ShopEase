import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/product_image_service.dart';
import '../theme/shop_colors.dart';

class ShopImagePickerField extends StatelessWidget {
  const ShopImagePickerField({
    super.key,
    required this.onPick,
    required this.onClear,
    this.selection,
    this.existingImageUrl = '',
    this.busy = false,
  });

  final VoidCallback onPick;
  final VoidCallback onClear;
  final ProductImageSelection? selection;
  final String existingImageUrl;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final previewBytes = selection?.bytes;
    final showExisting = existingImageUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShopColors.cream,
        border: Border.all(color: ShopColors.stroke),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRODUCT PHOTO',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ShopColors.dragonfruit,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: ColoredBox(
                color: ShopColors.orchid,
                child: previewBytes != null
                    ? _memoryPreview(previewBytes)
                    : showExisting
                        ? Image.network(
                            existingImageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const _EmptyPreview(),
                          )
                        : const _EmptyPreview(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onPick,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: const Text('Choose image'),
              ),
              if (selection != null)
                TextButton.icon(
                  onPressed: busy ? null : onClear,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Remove selection'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'JPG, PNG or WebP under 5 MB. A selected file takes priority over the URL below.',
            style: TextStyle(color: ShopColors.muted, fontSize: 12),
          ),
          if (selection != null) ...[
            const SizedBox(height: 6),
            Text(
              selection!.filename,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ShopColors.fig),
            ),
          ],
        ],
      ),
    );
  }

  Widget _memoryPreview(Uint8List bytes) => Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _EmptyPreview(),
      );
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(Icons.add_photo_alternate_outlined,
            size: 48, color: ShopColors.dragonfruit),
      );
}
