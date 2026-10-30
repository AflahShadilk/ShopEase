import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/shop_colors.dart';

/// Designed from Flutter shapes; no image asset or copied logo required.
class ShopMark extends StatelessWidget {
  const ShopMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: -math.pi / 15,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ShopColors.yuzu,
                  borderRadius: BorderRadius.circular(size * .25),
                ),
              ),
            ),
          ),
          Positioned(
            left: size * .13,
            top: size * .13,
            right: size * .08,
            bottom: size * .08,
            child: Transform.rotate(
              angle: math.pi / 19,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ShopColors.dragonfruit,
                  borderRadius: BorderRadius.circular(size * .22),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              's',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * .66,
                height: 1.0,
                letterSpacing: -3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopBrand extends StatelessWidget {
  const ShopBrand({
    super.key,
    this.markSize = 42,
    this.wordmarkColor = ShopColors.fig,
  });
  final double markSize;
  final Color wordmarkColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShopMark(size: markSize),
        const SizedBox(width: 12),
        Text(
          'shop',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: wordmarkColor,
                letterSpacing: -1.3,
              ),
        ),
        Text(
          'ease',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ShopColors.dragonfruit,
                letterSpacing: -1.3,
              ),
        ),
      ],
    );
  }
}
