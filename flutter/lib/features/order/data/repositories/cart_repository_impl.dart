import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/cart_local_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ICartRepository)
class CartRepositoryImpl implements ICartRepository {
  final CartLocalDatasource _local;

  const CartRepositoryImpl(this._local);

  @override
  Future<Result<void, String>> addItem(CartItemEntity item) async {
    try {
      await _local.addItem(item);
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to add item to cart');
    }
  }

  @override
  Future<Result<void, String>> removeItem(int productId) async {
    try {
      await _local.removeItem(productId);
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to remove item from cart');
    }
  }

  @override
  Future<Result<List<CartItemEntity>, String>> getItems() async {
    try {
      final items = await _local.getItems();
      return Success(items);
    } catch (e) {
      return const Failure('Failed to load cart');
    }
  }

  @override
  Future<Result<void, String>> clear() async {
    try {
      await _local.clear();
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to clear cart');
    }
  }
}
