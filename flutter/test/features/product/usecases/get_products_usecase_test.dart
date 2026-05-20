import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIProductRepository extends Mock implements IProductRepository {}

void main() {
  late MockIProductRepository mockRepo;
  late GetProductsUseCase useCase;

  const mockProducts = [
    ProductEntity(
      id: 1,
      name: 'Test Product',
      description: 'A test product',
      price: 29.99,
      priceUnit: 'dollar',
    ),
  ];

  setUp(() {
    mockRepo = MockIProductRepository();
    useCase = GetProductsUseCase(mockRepo);
  });

  group('GetProductsUseCase', () {
    test('returns Success with products when repository succeeds', () async {
      when(() => mockRepo.getProducts())
          .thenAnswer((_) async => const Success(mockProducts));

      final result = await useCase();

      expect(result, isA<Success<List<ProductEntity>, String>>());
      final success = result as Success<List<ProductEntity>, String>;
      expect(success.value.length, 1);
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepo.getProducts())
          .thenAnswer((_) async => const Failure('Failed to load products'));

      final result = await useCase();

      expect(result, isA<Failure<List<ProductEntity>, String>>());
      final failure = result as Failure<List<ProductEntity>, String>;
      expect(failure.exception, 'Failed to load products');
    });

    test('delegates to repository getProducts()', () async {
      when(() => mockRepo.getProducts())
          .thenAnswer((_) async => const Success(mockProducts));

      await useCase();

      verify(() => mockRepo.getProducts()).called(1);
    });
  });
}
