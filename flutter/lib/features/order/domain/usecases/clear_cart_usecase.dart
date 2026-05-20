import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClearCartUseCase {
  final ICartRepository _repo;
  const ClearCartUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.clear();
}
