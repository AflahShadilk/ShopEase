import 'package:cloud_firestore/cloud_firestore.dart';

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final int stock;
  final String imageUrl;
  final bool isActive;

  factory ShopProduct.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return ShopProduct(
      id: document.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}
