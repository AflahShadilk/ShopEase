import 'shop_product.dart';

class ShopCartLine {
  const ShopCartLine({required this.product, required this.quantity});

  final ShopProduct product;
  final int quantity;

  int get total => product.price * quantity;

  ShopCartLine copyWith({ShopProduct? product, int? quantity}) {
    return ShopCartLine(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
