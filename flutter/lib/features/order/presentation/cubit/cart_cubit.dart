import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartCubit extends Cubit<CartState> {
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final GetCartUseCase _getCart;

  CartCubit(this._addToCart, this._removeFromCart, this._getCart)
      : super(const CartInitial());

  Future<void> loadCart() async {
    final result = await _getCart();
    _emitFromItems(result);
  }

  Future<void> addItem(CartItemEntity item) async {
    await _addToCart(item);
    final result = await _getCart();
    _emitFromItems(result);
  }

  Future<void> removeItem(int productId) async {
    await _removeFromCart(productId);
    final result = await _getCart();
    _emitFromItems(result);
  }

  void _emitFromItems(Result<List<CartItemEntity>, String> result) {
    switch (result) {
      case Success(:final value):
        final total = value.fold(
          0.0,
          (sum, item) => sum + item.price * item.quantity,
        );
        emit(CartLoaded(items: value, totalAmount: total));
      case Failure(:final exception):
        emit(CartError(message: exception));
    }
  }
}
