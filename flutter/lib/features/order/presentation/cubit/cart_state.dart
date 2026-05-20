import 'package:equatable/equatable.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double totalAmount;

  const CartLoaded({required this.items, required this.totalAmount});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items, totalAmount];
}

class CartError extends CartState {
  final String message;
  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
