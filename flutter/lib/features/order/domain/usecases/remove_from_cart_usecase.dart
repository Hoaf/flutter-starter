import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoveFromCartUseCase {
  final ICartRepository _repo;
  const RemoveFromCartUseCase(this._repo);

  Future<Result<void, String>> call(int productId) => _repo.removeItem(productId);
}
