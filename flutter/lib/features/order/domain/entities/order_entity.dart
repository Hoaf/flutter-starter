import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int productId;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, quantity, price];
}

class OrderEntity extends Equatable {
  final int id;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItemEntity> items;
  final String createdAt;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, status, totalAmount, shippingAddress, paymentMethod, items, createdAt];
}
