import 'package:equatable/equatable.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrderLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// POST /order/ in progress — disables Place Order button.
class OrderPlacing extends OrderState {
  const OrderPlacing();
}

/// POST succeeded — triggers: close sheet, show snackbar, switch to Orders tab.
class OrderSuccess extends OrderState {
  const OrderSuccess();
}
