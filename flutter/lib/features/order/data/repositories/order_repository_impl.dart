import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IOrderRepository)
class OrderRepositoryImpl implements IOrderRepository {
  final OrderRemoteDatasource _remote;

  const OrderRepositoryImpl(this._remote);

  @override
  Future<Result<OrderEntity, String>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    try {
      final model = await _remote.placeOrder(
        items: items,
        totalAmount: totalAmount,
      );
      return Success(model.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Failure('No network connection');
      }
      return const Failure('Failed to place order');
    } catch (e) {
      return const Failure('An unexpected error occurred');
    }
  }

  @override
  Future<Result<List<OrderEntity>, String>> getOrders() async {
    try {
      final models = await _remote.getOrders();
      return Success(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Failure('No network connection');
      }
      return const Failure('Failed to load orders');
    } catch (e) {
      return const Failure('An unexpected error occurred');
    }
  }
}
