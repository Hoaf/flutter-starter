import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';

class OrderItemModel {
  final int productId;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'] as int,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );

  OrderItemEntity toEntity() => OrderItemEntity(
        productId: productId,
        quantity: quantity,
        price: price,
      );
}

class OrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? 'pending',
        totalAmount: (json['totalAmount'] as num).toDouble(),
        shippingAddress: json['shippingAddress'] as String? ?? '',
        paymentMethod: json['paymentMethod'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as String? ?? '',
      );

  OrderEntity toEntity() => OrderEntity(
        id: id,
        status: status,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        items: items.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
      );
}
