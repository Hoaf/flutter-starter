import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockUseCase;
  late ProductCubit cubit;

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
    mockUseCase = MockGetProductsUseCase();
    cubit = ProductCubit(mockUseCase);
  });

  tearDown(() => cubit.close());

  group('ProductCubit', () {
    test('initial state is ProductInitial', () {
      expect(cubit.state, const ProductInitial());
    });

    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductLoaded] on successful load',
      build: () {
        when(() => mockUseCase())
            .thenAnswer((_) async => const Success(mockProducts));
        return cubit;
      },
      act: (c) => c.loadProducts(),
      expect: () => [
        const ProductLoading(),
        const ProductLoaded(products: mockProducts),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductError] on API error',
      build: () {
        when(() => mockUseCase()).thenAnswer(
            (_) async => const Failure('Failed to load products'));
        return cubit;
      },
      act: (c) => c.loadProducts(),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Failed to load products'),
      ],
    );
  });
}
