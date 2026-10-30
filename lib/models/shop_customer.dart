import 'package:cloud_firestore/cloud_firestore.dart';

class ShopCustomer {
  const ShopCustomer({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory ShopCustomer.fromMap(String id, Map<String, dynamic> data) {
    return ShopCustomer(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  factory ShopCustomer.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return ShopCustomer.fromMap(document.id, document.data() ?? {});
  }
}
