import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderCubit extends Cubit<OrderState> {
  final PlaceOrderUseCase _placeOrder;
  final GetOrdersUseCase _getOrders;
  final ClearCartUseCase _clearCart;

  OrderCubit(this._placeOrder, this._getOrders, this._clearCart)
      : super(const OrderInitial());

  Future<void> loadOrders() async {
    emit(const OrderLoading());
    final result = await _getOrders();
    switch (result) {
      case Success(:final value):
        emit(OrderLoaded(orders: value));
      case Failure(:final exception):
        emit(OrderError(message: exception));
    }
  }

  Future<void> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    emit(const OrderPlacing());
    final result = await _placeOrder(items: items, totalAmount: totalAmount);
    switch (result) {
      case Success():
        await _clearCart();
        emit(const OrderSuccess());
      case Failure(:final exception):
        emit(OrderError(message: exception));
    }
  }
}
