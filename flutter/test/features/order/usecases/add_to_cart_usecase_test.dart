import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockICartRepository extends Mock implements ICartRepository {}

void main() {
  late MockICartRepository mockRepo;
  late AddToCartUseCase useCase;

  const mockItem = CartItemEntity(
    productId: 1,
    name: 'Test Product',
    price: 29.99,
    priceUnit: 'dollar',
    quantity: 1,
  );

  setUp(() {
    mockRepo = MockICartRepository();
    useCase = AddToCartUseCase(mockRepo);
  });

  group('AddToCartUseCase', () {
    test('delegates to repository addItem and returns Success', () async {
      when(() => mockRepo.addItem(mockItem))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(mockItem);

      expect(result, isA<Success<void, String>>());
      verify(() => mockRepo.addItem(mockItem)).called(1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepo.addItem(mockItem)).thenAnswer(
          (_) async => const Failure('Failed to add item to cart'));

      final result = await useCase(mockItem);

      expect(result, isA<Failure<void, String>>());
      final failure = result as Failure<void, String>;
      expect(failure.exception, 'Failed to add item to cart');
    });
  });
}
