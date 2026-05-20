import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';

abstract class ICartRepository {
  /// Adds item to cart. If the product already exists, increments quantity by 1.
  Future<Result<void, String>> addItem(CartItemEntity item);

  /// Decrements item quantity by 1. Removes item entirely when quantity reaches 0.
  Future<Result<void, String>> removeItem(int productId);

  Future<Result<List<CartItemEntity>, String>> getItems();

  Future<Result<void, String>> clear();
}
