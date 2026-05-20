import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';

abstract class IOrderRepository {
  Future<Result<OrderEntity, String>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  });

  Future<Result<List<OrderEntity>, String>> getOrders();
}
