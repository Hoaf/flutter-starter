import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrdersUseCase {
  final IOrderRepository _repo;
  const GetOrdersUseCase(this._repo);

  Future<Result<List<OrderEntity>, String>> call() => _repo.getOrders();
}
