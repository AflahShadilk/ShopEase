import 'package:flutter/material.dart';

import '../theme/shop_colors.dart';
import 'shop_brand.dart';

class ShopEditorLayout extends StatelessWidget {
  const ShopEditorLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ShopBrand(markSize: 32)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 400;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 12 : 20,
                24,
                compact ? 12 : 20,
                48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THE CONTROL ROOM / INVENTORY',
                        style: TextStyle(
                          color: ShopColors.dragonfruit,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ShopColors.muted,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(compact ? 12 : 22),
                        decoration: BoxDecoration(
                          color: ShopColors.paper,
                          border: Border.all(color: ShopColors.stroke),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
