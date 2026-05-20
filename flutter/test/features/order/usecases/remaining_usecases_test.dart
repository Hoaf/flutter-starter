import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockICartRepository extends Mock implements ICartRepository {}
class MockIOrderRepository extends Mock implements IOrderRepository {}

const _mockItem = CartItemEntity(
  productId: 1,
  name: 'Test Product',
  price: 29.99,
  priceUnit: 'dollar',
  quantity: 1,
);

const _mockOrder = OrderEntity(
  id: 1,
  status: 'pending',
  totalAmount: 29.99,
  shippingAddress: 'Default Address',
  paymentMethod: 'cash_on_delivery',
  items: [],
  createdAt: '2026-05-18T10:00:00Z',
);

void main() {
  late MockICartRepository mockCartRepo;
  late MockIOrderRepository mockOrderRepo;

  setUp(() {
    mockCartRepo = MockICartRepository();
    mockOrderRepo = MockIOrderRepository();
  });

  group('GetCartUseCase', () {
    test('delegates to repository getItems and returns Success', () async {
      when(() => mockCartRepo.getItems())
          .thenAnswer((_) async => const Success([_mockItem]));

      final result = await GetCartUseCase(mockCartRepo)();

      expect(result, isA<Success<List<CartItemEntity>, String>>());
      verify(() => mockCartRepo.getItems()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockCartRepo.getItems())
          .thenAnswer((_) async => const Failure('Failed to load cart'));

      final result = await GetCartUseCase(mockCartRepo)();

      expect(result, isA<Failure<List<CartItemEntity>, String>>());
    });
  });

  group('RemoveFromCartUseCase', () {
    test('delegates to repository removeItem and returns Success', () async {
      when(() => mockCartRepo.removeItem(1))
          .thenAnswer((_) async => const Success(null));

      final result = await RemoveFromCartUseCase(mockCartRepo)(1);

      expect(result, isA<Success<void, String>>());
      verify(() => mockCartRepo.removeItem(1)).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockCartRepo.removeItem(1)).thenAnswer(
          (_) async => const Failure('Failed to remove item from cart'));

      final result = await RemoveFromCartUseCase(mockCartRepo)(1);

      expect(result, isA<Failure<void, String>>());
    });
  });

  group('ClearCartUseCase', () {
    test('delegates to repository clear and returns Success', () async {
      when(() => mockCartRepo.clear())
          .thenAnswer((_) async => const Success(null));

      final result = await ClearCartUseCase(mockCartRepo)();

      expect(result, isA<Success<void, String>>());
      verify(() => mockCartRepo.clear()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockCartRepo.clear())
          .thenAnswer((_) async => const Failure('Failed to clear cart'));

      final result = await ClearCartUseCase(mockCartRepo)();

      expect(result, isA<Failure<void, String>>());
    });
  });

  group('GetOrdersUseCase', () {
    test('delegates to repository getOrders and returns Success', () async {
      when(() => mockOrderRepo.getOrders())
          .thenAnswer((_) async => const Success([_mockOrder]));

      final result = await GetOrdersUseCase(mockOrderRepo)();

      expect(result, isA<Success<List<OrderEntity>, String>>());
      verify(() => mockOrderRepo.getOrders()).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockOrderRepo.getOrders())
          .thenAnswer((_) async => const Failure('Failed to load orders'));

      final result = await GetOrdersUseCase(mockOrderRepo)();

      expect(result, isA<Failure<List<OrderEntity>, String>>());
    });
  });
}
