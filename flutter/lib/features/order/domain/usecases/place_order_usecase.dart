import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PlaceOrderUseCase {
  final IOrderRepository _repo;
  const PlaceOrderUseCase(this._repo);

  Future<Result<OrderEntity, String>> call({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) =>
      _repo.placeOrder(items: items, totalAmount: totalAmount);
}
