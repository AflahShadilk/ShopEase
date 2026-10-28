import 'package:flutter/material.dart';
import '../theme/shop_colors.dart';
import 'shop_brand.dart';


class ShopAuthLayout extends StatelessWidget {
  const ShopAuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.isAdmin = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final form = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShopBrand(),
                  const SizedBox(height: 46),
                  Text(isAdmin ? 'THE CONTROL ROOM' : 'A GOOD DAY TO SHOP',
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: ShopColors.dragonfruit, letterSpacing: 2.0,
                      )),
                  const SizedBox(height: 14),
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 9),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ShopColors.muted,
                      )),
                  const SizedBox(height: 30),
                  child,
                ],
              ),
            );

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 28 : 22,
                      vertical: wide ? 38 : 32,
                    ),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: _BrandPanel()),
                              const SizedBox(width: 70),
                              Expanded(child: form),
                            ],
                          )
                        : form,
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 630,
      padding: const EdgeInsets.all(42),
      decoration: BoxDecoration(
        color: ShopColors.fig,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SHOP / EASE     •     EDITION 01',
              style: TextStyle(color: ShopColors.yuzu, letterSpacing: 2,
                  fontSize: 11, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Align(alignment: Alignment.center,
              child: ShopMark(size: 170)),
          const Spacer(),
          Text('Every cart.\nA little spark.',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 43, color: Colors.white,
              )),
          const SizedBox(height: 15),
          const Text('An upbeat marketplace with a thoughtful touch.',
              style: TextStyle(color: ShopColors.orchid, height: 1.5)),
        ],
      ),
    );
  }
}
