import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late MockIOrderRepository mockRepo;
  late PlaceOrderUseCase useCase;

  const mockOrder = OrderEntity(
    id: 1,
    status: 'pending',
    totalAmount: 59.98,
    shippingAddress: 'Default Address',
    paymentMethod: 'cash_on_delivery',
    items: [],
    createdAt: '2026-05-18T10:00:00Z',
  );

  const mockItems = [
    CartItemEntity(
      productId: 1,
      name: 'Test Product',
      price: 29.99,
      priceUnit: 'dollar',
      quantity: 2,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const <CartItemEntity>[]);
  });

  setUp(() {
    mockRepo = MockIOrderRepository();
    useCase = PlaceOrderUseCase(mockRepo);
  });

  group('PlaceOrderUseCase', () {
    test('delegates to repository placeOrder and returns Success', () async {
      when(() => mockRepo.placeOrder(
            items: mockItems,
            totalAmount: 59.98,
          )).thenAnswer((_) async => const Success(mockOrder));

      final result = await useCase(items: mockItems, totalAmount: 59.98);

      expect(result, isA<Success<OrderEntity, String>>());
      final success = result as Success<OrderEntity, String>;
      expect(success.value.id, 1);
      verify(() => mockRepo.placeOrder(
            items: mockItems,
            totalAmount: 59.98,
          )).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepo.placeOrder(
            items: any(named: 'items'),
            totalAmount: any(named: 'totalAmount'),
          )).thenAnswer((_) async => const Failure('Failed to place order'));

      final result = await useCase(items: mockItems, totalAmount: 59.98);

      expect(result, isA<Failure<OrderEntity, String>>());
      final failure = result as Failure<OrderEntity, String>;
      expect(failure.exception, 'Failed to place order');
    });
  });
}
