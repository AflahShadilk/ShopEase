import 'package:cloud_firestore/cloud_firestore.dart';

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.shippingAddress,
    required this.phone,
    required this.status,
    required this.total,
    required this.items,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String shippingAddress;
  final String phone;
  final String status;
  final int total;
  final List<Map<String, dynamic>> items;
  final DateTime? createdAt;

  factory ShopOrder.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return ShopOrder(
      id: document.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      shippingAddress: data['shippingAddress'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      total: (data['total'] as num?)?.toInt() ?? 0,
      items: (data['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
