import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddToCartUseCase {
  final ICartRepository _repo;
  const AddToCartUseCase(this._repo);

  Future<Result<void, String>> call(CartItemEntity item) => _repo.addItem(item);
}
