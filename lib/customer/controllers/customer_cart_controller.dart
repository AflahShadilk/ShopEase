import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../models/shop_cart_line.dart';
import '../../models/shop_product.dart';
import '../../shared/controllers/shop_session_controller.dart';

/// Cart is local to this signed-in session; it is not yet persistent.
class CustomerCartController extends GetxController {
  CustomerCartController({this.session});

  final ShopSessionController? session;
  final items = <String, ShopCartLine>{}.obs;
  Worker? _sessionWorker;
  String? _currentUserId;

  List<ShopCartLine> get lines => items.values.toList(growable: false);
  int get count => items.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => items.values.fold(0, (sum, line) => sum + line.total);

  @override
  void onInit() {
    super.onInit();
    if (session != null) {
      _currentUserId = session!.user.value?.uid;
      _sessionWorker = ever<User?>(session!.user, (user) {
        if (user?.uid != _currentUserId) {
          clear();
          _currentUserId = user?.uid;
        }
      });
    }
  }

  /// Returns a user-facing reason when the product cannot be added.
  String? addProduct(ShopProduct product) {
    if (!product.isActive) return 'This item is no longer available.';
    if (product.stock <= 0) return 'This item is out of stock.';
    final next = (items[product.id]?.quantity ?? 0) + 1;
    if (next > product.stock) return 'Only ${product.stock} in stock.';
    items[product.id] = ShopCartLine(product: product, quantity: next);
    return null;
  }

  void increase(String id) {
    final line = items[id];
    if (line == null || line.quantity >= line.product.stock) return;
    items[id] = line.copyWith(quantity: line.quantity + 1);
  }

  void decrease(String id) {
    final line = items[id];
    if (line == null) return;
    if (line.quantity <= 1) {
      items.remove(id);
    } else {
      items[id] = line.copyWith(quantity: line.quantity - 1);
    }
  }

  void remove(String id) => items.remove(id);
  void clear() => items.clear();

  /// Refresh prices, availability and stock from the live catalog stream.
  void syncProducts(List<ShopProduct> available) {
    final byId = {for (final product in available) product.id: product};
    final updated = <String, ShopCartLine>{};
    for (final line in items.values) {
      final product = byId[line.product.id];
      if (product == null || !product.isActive || product.stock <= 0) continue;
      updated[product.id] = ShopCartLine(
        product: product,
        quantity: line.quantity > product.stock ? product.stock : line.quantity,
      );
    }
    items.assignAll(updated);
  }

  @override
  void onClose() {
    _sessionWorker?.dispose();
    super.onClose();
  }
}
