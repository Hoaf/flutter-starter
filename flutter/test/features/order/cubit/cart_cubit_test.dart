import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockGetCartUseCase extends Mock implements GetCartUseCase {}

const _mockItem = CartItemEntity(
  productId: 1,
  name: 'Test Product',
  price: 29.99,
  priceUnit: 'dollar',
  quantity: 1,
);

void main() {
  late MockAddToCartUseCase mockAdd;
  late MockRemoveFromCartUseCase mockRemove;
  late MockGetCartUseCase mockGet;
  late CartCubit cubit;

  setUp(() {
    mockAdd = MockAddToCartUseCase();
    mockRemove = MockRemoveFromCartUseCase();
    mockGet = MockGetCartUseCase();
    cubit = CartCubit(mockAdd, mockRemove, mockGet);
  });

  tearDown(() => cubit.close());

  group('CartCubit', () {
    test('initial state is CartInitial', () {
      expect(cubit.state, const CartInitial());
    });

    blocTest<CartCubit, CartState>(
      'loadCart emits CartLoaded with items from repository',
      build: () {
        when(() => mockGet())
            .thenAnswer((_) async => const Success([_mockItem]));
        return cubit;
      },
      act: (c) => c.loadCart(),
      expect: () => [
        CartLoaded(items: const [_mockItem], totalAmount: 29.99),
      ],
    );

    blocTest<CartCubit, CartState>(
      'loadCart emits CartLoaded with empty list when cart is empty',
      build: () {
        when(() => mockGet())
            .thenAnswer((_) async => const Success([]));
        return cubit;
      },
      act: (c) => c.loadCart(),
      expect: () => [
        const CartLoaded(items: [], totalAmount: 0.0),
      ],
    );

    blocTest<CartCubit, CartState>(
      'addItem calls addToCart then refreshes cart',
      build: () {
        when(() => mockAdd(_mockItem))
            .thenAnswer((_) async => const Success(null));
        when(() => mockGet())
            .thenAnswer((_) async => const Success([_mockItem]));
        return cubit;
      },
      act: (c) => c.addItem(_mockItem),
      expect: () => [
        CartLoaded(items: const [_mockItem], totalAmount: 29.99),
      ],
      verify: (_) {
        verify(() => mockAdd(_mockItem)).called(1);
        verify(() => mockGet()).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'removeItem calls removeFromCart then refreshes cart',
      build: () {
        when(() => mockRemove(1))
            .thenAnswer((_) async => const Success(null));
        when(() => mockGet())
            .thenAnswer((_) async => const Success([]));
        return cubit;
      },
      act: (c) => c.removeItem(1),
      expect: () => [
        const CartLoaded(items: [], totalAmount: 0.0),
      ],
      verify: (_) {
        verify(() => mockRemove(1)).called(1);
        verify(() => mockGet()).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'emits CartError when getCart fails',
      build: () {
        when(() => mockGet())
            .thenAnswer((_) async => const Failure('Failed to load cart'));
        return cubit;
      },
      act: (c) => c.loadCart(),
      expect: () => [
        const CartError(message: 'Failed to load cart'),
      ],
    );
  });
}
