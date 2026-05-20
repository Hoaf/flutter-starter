import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPlaceOrderUseCase extends Mock implements PlaceOrderUseCase {}
class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

const _mockOrder = OrderEntity(
  id: 1,
  status: 'pending',
  totalAmount: 59.98,
  shippingAddress: 'Default Address',
  paymentMethod: 'cash_on_delivery',
  items: [],
  createdAt: '2026-05-18T10:00:00Z',
);

const _mockItem = CartItemEntity(
  productId: 1,
  name: 'Test Product',
  price: 29.99,
  priceUnit: 'dollar',
  quantity: 2,
);

void main() {
  late MockPlaceOrderUseCase mockPlace;
  late MockGetOrdersUseCase mockGetOrders;
  late MockClearCartUseCase mockClear;
  late OrderCubit cubit;

  setUpAll(() {
    registerFallbackValue(const <CartItemEntity>[]);
  });

  setUp(() {
    mockPlace = MockPlaceOrderUseCase();
    mockGetOrders = MockGetOrdersUseCase();
    mockClear = MockClearCartUseCase();
    cubit = OrderCubit(mockPlace, mockGetOrders, mockClear);
  });

  tearDown(() => cubit.close());

  group('OrderCubit', () {
    test('initial state is OrderInitial', () {
      expect(cubit.state, const OrderInitial());
    });

    blocTest<OrderCubit, OrderState>(
      'loadOrders emits [OrderLoading, OrderLoaded] on success',
      build: () {
        when(() => mockGetOrders())
            .thenAnswer((_) async => const Success([_mockOrder]));
        return cubit;
      },
      act: (c) => c.loadOrders(),
      expect: () => [
        const OrderLoading(),
        const OrderLoaded(orders: [_mockOrder]),
      ],
    );

    blocTest<OrderCubit, OrderState>(
      'loadOrders emits [OrderLoading, OrderError] on failure',
      build: () {
        when(() => mockGetOrders()).thenAnswer(
            (_) async => const Failure('Failed to load orders'));
        return cubit;
      },
      act: (c) => c.loadOrders(),
      expect: () => [
        const OrderLoading(),
        const OrderError(message: 'Failed to load orders'),
      ],
    );

    blocTest<OrderCubit, OrderState>(
      'placeOrder emits [OrderPlacing, OrderSuccess] and clears cart on success',
      build: () {
        when(() => mockPlace(
              items: any(named: 'items'),
              totalAmount: any(named: 'totalAmount'),
            )).thenAnswer((_) async => const Success(_mockOrder));
        when(() => mockClear())
            .thenAnswer((_) async => const Success(null));
        return cubit;
      },
      act: (c) => c.placeOrder(
        items: const [_mockItem],
        totalAmount: 59.98,
      ),
      expect: () => [
        const OrderPlacing(),
        const OrderSuccess(),
      ],
      verify: (_) {
        verify(() => mockClear()).called(1);
      },
    );

    blocTest<OrderCubit, OrderState>(
      'placeOrder emits [OrderPlacing, OrderError] on failure',
      build: () {
        when(() => mockPlace(
              items: any(named: 'items'),
              totalAmount: any(named: 'totalAmount'),
            )).thenAnswer((_) async => const Failure('Failed to place order'));
        return cubit;
      },
      act: (c) => c.placeOrder(
        items: const [_mockItem],
        totalAmount: 59.98,
      ),
      expect: () => [
        const OrderPlacing(),
        const OrderError(message: 'Failed to place order'),
      ],
    );
  });
}
