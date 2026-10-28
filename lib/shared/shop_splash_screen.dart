import 'package:flutter/material.dart';
import '../../core/theme/shop_colors.dart';
import '../../core/widgets/shop_brand.dart';


/// Later, pass an auth-gate widget as [nextPage], not an unprotected admin screen.
class ShopSplashScreen extends StatefulWidget {
  const ShopSplashScreen({
    super.key,
    required this.nextPage,
    this.isAdmin = false,
  });

  final Widget nextPage;
  final bool isAdmin;

  @override
  State<ShopSplashScreen> createState() => _ShopSplashScreenState();
}

class _ShopSplashScreenState extends State<ShopSplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) => widget.nextPage,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopColors.fig,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 28, left: 26,
              child: Text('S / E    •    01',
                  style: TextStyle(color: ShopColors.yuzu,
                      fontSize: 12, fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
            ),
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 650),
                opacity: _visible ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  scale: _visible ? 1 : .88,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ShopMark(size: 94),
                      const SizedBox(height: 25),
                      Text('shop ease',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white, fontSize: 42,
                            letterSpacing: -2.2,
                          )),
                      const SizedBox(height: 11),
                      Text(widget.isAdmin ? 'THE CONTROL ROOM' : 'EVERY CART. A LITTLE SPARK.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ShopColors.yuzu, fontSize: 11,
                            letterSpacing: 2.0, fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: 30,
              child: Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(
                    color: ShopColors.dragonfruit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
