# Order & Cart Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Cart (bottom sheet) and Orders tab to the Flutter app — users add products to a local SQLite cart, place an order via POST /order/, then view history via GET /order/ in a new Orders tab.

**Architecture:** Feature-first Clean Architecture under `lib/features/order/`. CartCubit manages local SQLite cart, OrderCubit manages API orders. BlocListener in HomePage switches to Orders tab on OrderSuccess.

**Tech Stack:** Flutter, flutter_bloc (Cubit), sqflite (cart), Dio (orders), get_it, mocktail

**Rules:**
- Do NOT run git commit at any step — leave committing to the user
- Working directory for all commands: `C:/project/nt-flutter-starter/flutter`
- Run `flutter analyze` after each task to catch errors early

---

## File Map

### New files
```
lib/features/order/
├── domain/
│   ├── entities/
│   │   ├── cart_item_entity.dart
│   │   └── order_entity.dart          # includes OrderItemEntity
│   ├── repositories/
│   │   ├── i_cart_repository.dart
│   │   └── i_order_repository.dart
│   └── usecases/
│       ├── add_to_cart_usecase.dart
│       ├── remove_from_cart_usecase.dart
│       ├── get_cart_usecase.dart
│       ├── clear_cart_usecase.dart
│       ├── place_order_usecase.dart
│       └── get_orders_usecase.dart
├── data/
│   ├── models/
│   │   └── order_model.dart           # OrderModel + OrderItemModel
│   ├── datasources/
│   │   ├── cart_local_datasource.dart
│   │   └── order_remote_datasource.dart
│   └── repositories/
│       ├── cart_repository_impl.dart
│       └── order_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── cart_cubit.dart
    │   ├── cart_state.dart
    │   ├── order_cubit.dart
    │   └── order_state.dart
    ├── widgets/
    │   └── cart_bottom_sheet.dart
    └── pages/
        └── orders_tab.dart

test/features/order/
├── cubit/
│   ├── cart_cubit_test.dart
│   └── order_cubit_test.dart
└── usecases/
    ├── add_to_cart_usecase_test.dart
    └── place_order_usecase_test.dart
```

### Modified files
| File | Change |
|------|--------|
| `lib/di/service_locator.dart` | Register 6 new datasources/repos/usecases/cubits |
| `lib/features/product/presentation/pages/discover_tab.dart` | Wire [+] button → CartCubit.addItem(), cart icon badge |
| `lib/presentation/screens/home/home_page.dart` | Add Orders tab (index 1), CartCubit + OrderCubit providers, BlocListener |

---

## Task 1: Domain Entities

**Files:**
- Create: `lib/features/order/domain/entities/cart_item_entity.dart`
- Create: `lib/features/order/domain/entities/order_entity.dart`

- [ ] **Step 1: Create `cart_item_entity.dart`**

```dart
// lib/features/order/domain/entities/cart_item_entity.dart
import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String name;
  final double price;
  final String priceUnit;
  final String? image;
  final int quantity;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.priceUnit,
    this.image,
    required this.quantity,
  });

  String get formattedPrice {
    final symbol = switch (priceUnit) {
      'euro' => '€',
      'inr' => '₹',
      _ => '\$',
    };
    return '$symbol${price.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'price_unit': priceUnit,
        'image': image,
        'quantity': quantity,
      };

  factory CartItemEntity.fromMap(Map<String, dynamic> map) => CartItemEntity(
        productId: map['product_id'] as int,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        priceUnit: map['price_unit'] as String,
        image: map['image'] as String?,
        quantity: map['quantity'] as int,
      );

  @override
  List<Object?> get props =>
      [productId, name, price, priceUnit, image, quantity];
}
```

- [ ] **Step 2: Create `order_entity.dart`**

```dart
// lib/features/order/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int productId;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, quantity, price];
}

class OrderEntity extends Equatable {
  final int id;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItemEntity> items;
  final String createdAt;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, status, totalAmount, shippingAddress, paymentMethod, items, createdAt];
}
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/
```

Expected: No issues.

---

## Task 2: Domain Repository Interfaces + Use Cases

**Files:**
- Create: `lib/features/order/domain/repositories/i_cart_repository.dart`
- Create: `lib/features/order/domain/repositories/i_order_repository.dart`
- Create: `lib/features/order/domain/usecases/add_to_cart_usecase.dart`
- Create: `lib/features/order/domain/usecases/remove_from_cart_usecase.dart`
- Create: `lib/features/order/domain/usecases/get_cart_usecase.dart`
- Create: `lib/features/order/domain/usecases/clear_cart_usecase.dart`
- Create: `lib/features/order/domain/usecases/place_order_usecase.dart`
- Create: `lib/features/order/domain/usecases/get_orders_usecase.dart`

- [ ] **Step 1: Create `i_cart_repository.dart`**

```dart
// lib/features/order/domain/repositories/i_cart_repository.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';

abstract class ICartRepository {
  /// Adds item to cart. If the product already exists, increments quantity by 1.
  Future<Result<void, String>> addItem(CartItemEntity item);

  /// Decrements item quantity by 1. Removes item entirely when quantity reaches 0.
  Future<Result<void, String>> removeItem(int productId);

  Future<Result<List<CartItemEntity>, String>> getItems();

  Future<Result<void, String>> clear();
}
```

- [ ] **Step 2: Create `i_order_repository.dart`**

```dart
// lib/features/order/domain/repositories/i_order_repository.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';

abstract class IOrderRepository {
  Future<Result<OrderEntity, String>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  });

  Future<Result<List<OrderEntity>, String>> getOrders();
}
```

- [ ] **Step 3: Create use cases**

```dart
// lib/features/order/domain/usecases/add_to_cart_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';

class AddToCartUseCase {
  final ICartRepository _repo;
  const AddToCartUseCase(this._repo);

  Future<Result<void, String>> call(CartItemEntity item) => _repo.addItem(item);
}
```

```dart
// lib/features/order/domain/usecases/remove_from_cart_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';

class RemoveFromCartUseCase {
  final ICartRepository _repo;
  const RemoveFromCartUseCase(this._repo);

  Future<Result<void, String>> call(int productId) => _repo.removeItem(productId);
}
```

```dart
// lib/features/order/domain/usecases/get_cart_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';

class GetCartUseCase {
  final ICartRepository _repo;
  const GetCartUseCase(this._repo);

  Future<Result<List<CartItemEntity>, String>> call() => _repo.getItems();
}
```

```dart
// lib/features/order/domain/usecases/clear_cart_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';

class ClearCartUseCase {
  final ICartRepository _repo;
  const ClearCartUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.clear();
}
```

```dart
// lib/features/order/domain/usecases/place_order_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';

class PlaceOrderUseCase {
  final IOrderRepository _repo;
  const PlaceOrderUseCase(this._repo);

  Future<Result<OrderEntity, String>> call({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) =>
      _repo.placeOrder(items: items, totalAmount: totalAmount);
}
```

```dart
// lib/features/order/domain/usecases/get_orders_usecase.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';

class GetOrdersUseCase {
  final IOrderRepository _repo;
  const GetOrdersUseCase(this._repo);

  Future<Result<List<OrderEntity>, String>> call() => _repo.getOrders();
}
```

- [ ] **Step 4: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/
```

Expected: No issues.

---

## Task 3: Data Models

**Files:**
- Create: `lib/features/order/data/models/order_model.dart`

- [ ] **Step 1: Create `order_model.dart`**

```dart
// lib/features/order/data/models/order_model.dart
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';

class OrderItemModel {
  final int productId;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'] as int,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );

  OrderItemEntity toEntity() => OrderItemEntity(
        productId: productId,
        quantity: quantity,
        price: price,
      );
}

class OrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? 'pending',
        totalAmount: (json['totalAmount'] as num).toDouble(),
        shippingAddress: json['shippingAddress'] as String? ?? '',
        paymentMethod: json['paymentMethod'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as String? ?? '',
      );

  OrderEntity toEntity() => OrderEntity(
        id: id,
        status: status,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        items: items.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
      );
}
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/data/models/
```

Expected: No issues.

---

## Task 4: CartLocalDatasource (SQLite)

**Files:**
- Create: `lib/features/order/data/datasources/cart_local_datasource.dart`

- [ ] **Step 1: Create `cart_local_datasource.dart`**

```dart
// lib/features/order/data/datasources/cart_local_datasource.dart
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartLocalDatasource {
  static const _dbName = 'cart.db';
  static const _tableName = 'cart_items';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _dbName),
      onCreate: (db, version) => db.execute('''
        CREATE TABLE $_tableName (
          product_id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          price_unit TEXT NOT NULL,
          image TEXT,
          quantity INTEGER NOT NULL DEFAULT 1
        )
      '''),
      version: 1,
    );
  }

  /// Increments quantity if item exists, otherwise inserts with quantity 1.
  Future<void> addItem(CartItemEntity item) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [item.productId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(_tableName, item.toMap());
    } else {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        _tableName,
        {'quantity': currentQty + 1},
        where: 'product_id = ?',
        whereArgs: [item.productId],
      );
    }
  }

  /// Decrements quantity. Deletes the row when quantity reaches 0.
  Future<void> removeItem(int productId) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (existing.isEmpty) return;
    final currentQty = existing.first['quantity'] as int;
    if (currentQty <= 1) {
      await db.delete(
        _tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      await db.update(
        _tableName,
        {'quantity': currentQty - 1},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<List<CartItemEntity>> getItems() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return maps.map(CartItemEntity.fromMap).toList();
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/data/datasources/cart_local_datasource.dart
```

Expected: No issues.

---

## Task 5: OrderRemoteDatasource

**Files:**
- Create: `lib/features/order/data/datasources/order_remote_datasource.dart`

- [ ] **Step 1: Create `order_remote_datasource.dart`**

```dart
// lib/features/order/data/datasources/order_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/order/data/models/order_model.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';

class OrderRemoteDatasource {
  final Dio _dio;

  OrderRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<OrderModel> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    final response = await _dio.post('/order/', data: {
      'items': items
          .map((e) => {
                'productId': e.productId,
                'quantity': e.quantity,
                'price': e.price,
              })
          .toList(),
      'totalAmount': totalAmount,
      'shippingAddress': 'Default Address',
      'paymentMethod': 'cash_on_delivery',
    });
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get('/order/');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/data/datasources/order_remote_datasource.dart
```

Expected: No issues.

---

## Task 6: Repository Implementations

**Files:**
- Create: `lib/features/order/data/repositories/cart_repository_impl.dart`
- Create: `lib/features/order/data/repositories/order_repository_impl.dart`

- [ ] **Step 1: Create `cart_repository_impl.dart`**

```dart
// lib/features/order/data/repositories/cart_repository_impl.dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/cart_local_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  final CartLocalDatasource _local;

  const CartRepositoryImpl(this._local);

  @override
  Future<Result<void, String>> addItem(CartItemEntity item) async {
    try {
      await _local.addItem(item);
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to add item to cart');
    }
  }

  @override
  Future<Result<void, String>> removeItem(int productId) async {
    try {
      await _local.removeItem(productId);
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to remove item from cart');
    }
  }

  @override
  Future<Result<List<CartItemEntity>, String>> getItems() async {
    try {
      final items = await _local.getItems();
      return Success(items);
    } catch (e) {
      return const Failure('Failed to load cart');
    }
  }

  @override
  Future<Result<void, String>> clear() async {
    try {
      await _local.clear();
      return const Success(null);
    } catch (e) {
      return const Failure('Failed to clear cart');
    }
  }
}
```

- [ ] **Step 2: Create `order_repository_impl.dart`**

```dart
// lib/features/order/data/repositories/order_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final OrderRemoteDatasource _remote;

  const OrderRepositoryImpl(this._remote);

  @override
  Future<Result<OrderEntity, String>> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    try {
      final model = await _remote.placeOrder(
        items: items,
        totalAmount: totalAmount,
      );
      return Success(model.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Failure('No network connection');
      }
      return const Failure('Failed to place order');
    } catch (e) {
      return const Failure('An unexpected error occurred');
    }
  }

  @override
  Future<Result<List<OrderEntity>, String>> getOrders() async {
    try {
      final models = await _remote.getOrders();
      return Success(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Failure('No network connection');
      }
      return const Failure('Failed to load orders');
    } catch (e) {
      return const Failure('An unexpected error occurred');
    }
  }
}
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/data/
```

Expected: No issues.

---

## Task 7: CartCubit + CartState

**Files:**
- Create: `lib/features/order/presentation/cubit/cart_state.dart`
- Create: `lib/features/order/presentation/cubit/cart_cubit.dart`

- [ ] **Step 1: Create `cart_state.dart`**

```dart
// lib/features/order/presentation/cubit/cart_state.dart
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
```

- [ ] **Step 2: Create `cart_cubit.dart`**

```dart
// lib/features/order/presentation/cubit/cart_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';

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
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/presentation/cubit/
```

Expected: No issues.

---

## Task 8: OrderCubit + OrderState

**Files:**
- Create: `lib/features/order/presentation/cubit/order_state.dart`
- Create: `lib/features/order/presentation/cubit/order_cubit.dart`

- [ ] **Step 1: Create `order_state.dart`**

```dart
// lib/features/order/presentation/cubit/order_state.dart
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
```

- [ ] **Step 2: Create `order_cubit.dart`**

```dart
// lib/features/order/presentation/cubit/order_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final PlaceOrderUseCase _placeOrder;
  final GetOrdersUseCase _getOrders;
  final ClearCartUseCase _clearCart;

  OrderCubit(this._placeOrder, this._getOrders, this._clearCart)
      : super(const OrderInitial());

  Future<void> loadOrders() async {
    emit(const OrderLoading());
    final result = await _getOrders();
    switch (result) {
      case Success(:final value):
        emit(OrderLoaded(orders: value));
      case Failure(:final exception):
        emit(OrderError(message: exception));
    }
  }

  Future<void> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    emit(const OrderPlacing());
    final result = await _placeOrder(items: items, totalAmount: totalAmount);
    switch (result) {
      case Success():
        await _clearCart();
        emit(const OrderSuccess());
      case Failure(:final exception):
        emit(OrderError(message: exception));
    }
  }
}
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/presentation/cubit/
```

Expected: No issues.

---

## Task 9: CartBottomSheet Widget

**Files:**
- Create: `lib/features/order/presentation/widgets/cart_bottom_sheet.dart`

- [ ] **Step 1: Create `cart_bottom_sheet.dart`**

```dart
// lib/features/order/presentation/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: BlocProvider.value(
          value: context.read<OrderCubit>(),
          child: const CartBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<CartState, CartState>(
                    builder: (context, state) => _buildBody(
                        context, state, scrollController),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(
        children: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count =
                  state is CartLoaded ? state.totalItemCount : 0;
              return Text(
                'Cart ($count ${count == 1 ? 'item' : 'items'})',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.paleSky),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CartState state, ScrollController scrollController) {
    if (state is CartLoaded && state.items.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Row(
                  children: [
                    // Placeholder image box
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.cyanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.cyan, size: 28),
                    ),
                    const SizedBox(width: 12),
                    // Name + price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.shark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.formattedPrice,
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_12,
                              color: AppColors.paleSky,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity controls
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () => context
                              .read<CartCubit>()
                              .removeItem(item.productId),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.shark,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () => context
                              .read<CartCubit>()
                              .addItem(item.copyWith(quantity: 1)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          _buildFooter(context, state),
        ],
      );
    }

    // Empty cart
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.gray),
          const SizedBox(height: 12),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: AppFontSizes.fs_14,
              color: AppColors.paleSky,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: AppFontSizes.fs_15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shark,
                ),
              ),
              Text(
                '\$${state.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyan,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              final isPlacing = orderState is OrderPlacing;
              return ElevatedButton(
                onPressed: isPlacing
                    ? null
                    : () => context.read<OrderCubit>().placeOrder(
                          items: state.items,
                          totalAmount: state.totalAmount,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isPlacing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: AppFontSizes.fs_15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.cyanLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.cyan),
      ),
    );
  }
}
```

> **Note:** The `_buildBody` method uses `BlocBuilder<CartState, CartState>` — that should be `BlocBuilder<CartCubit, CartState>`. Also `item.copyWith` needs to be added to `CartItemEntity`. See fixups below.

- [ ] **Step 2: Fix `CartItemEntity` — add `copyWith`**

Add to `lib/features/order/domain/entities/cart_item_entity.dart` after the `fromMap` factory:

```dart
  CartItemEntity copyWith({
    int? productId,
    String? name,
    double? price,
    String? priceUnit,
    String? image,
    int? quantity,
  }) =>
      CartItemEntity(
        productId: productId ?? this.productId,
        name: name ?? this.name,
        price: price ?? this.price,
        priceUnit: priceUnit ?? this.priceUnit,
        image: image ?? this.image,
        quantity: quantity ?? this.quantity,
      );
```

- [ ] **Step 3: Fix `BlocBuilder` type in `cart_bottom_sheet.dart`**

In `_buildBody`, change:
```dart
// WRONG:
BlocBuilder<CartState, CartState>(
// CORRECT:
BlocBuilder<CartCubit, CartState>(
```

- [ ] **Step 4: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/
```

Expected: No issues.

---

## Task 10: OrdersTab Page

**Files:**
- Create: `lib/features/order/presentation/pages/orders_tab.dart`

- [ ] **Step 1: Create `orders_tab.dart`**

```dart
// lib/features/order/presentation/pages/orders_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'My Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.shark,
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan),
                  );
                }

                if (state is OrderError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_outlined,
                            size: 48, color: AppColors.paleSky),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: AppFontSizes.fs_14,
                            color: AppColors.paleSky,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<OrderCubit>().loadOrders(),
                          icon: const Icon(Icons.refresh,
                              color: AppColors.cyan),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.cyan),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrderLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppColors.gray),
                          const SizedBox(height: 12),
                          const Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              color: AppColors.paleSky,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _OrderCard(order: state.orders[index]),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) => switch (status) {
        'shipped' => AppColors.blue,
        'delivered' => AppColors.green,
        'cancelled' => AppColors.red,
        _ => AppColors.paleSky,
      };

  String _formattedDate(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: order ID + status badge
          Row(
            children: [
              Text(
                'ORDER #ORD-${order.id}',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppFontSizes.fs_11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Amount
          Text(
            '\$${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: AppFontSizes.fs_16,
              fontWeight: FontWeight.bold,
              color: AppColors.cyan,
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 4),
          // Date
          Text(
            'Placed on ${_formattedDate(order.createdAt)}',
            style: const TextStyle(
              fontSize: AppFontSizes.fs_12,
              color: AppColors.paleSky,
            ),
          ),
          // Action buttons for delivered/shipped statuses
          if (order.status == 'delivered') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(label: 'Reorder', onTap: () {}),
                const SizedBox(width: 8),
                _ActionButton(label: 'View Details', onTap: () {}),
              ],
            ),
          ] else if (order.status == 'shipped') ...[
            const SizedBox(height: 12),
            _ActionButton(label: 'Track Order', onTap: () {}),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppFontSizes.fs_12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/features/order/presentation/pages/
```

Expected: No issues.

---

## Task 11: Wire Up (ServiceLocator + DiscoverTab + HomePage)

**Files:**
- Modify: `lib/di/service_locator.dart`
- Modify: `lib/features/product/presentation/pages/discover_tab.dart`
- Modify: `lib/presentation/screens/home/home_page.dart`

- [ ] **Step 1: Update `service_locator.dart`**

Replace the entire file content:

```dart
// lib/di/service_locator.dart
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';
import 'package:flutter_demo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_demo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_demo/features/order/data/datasources/cart_local_datasource.dart';
import 'package:flutter_demo/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_demo/features/order/data/repositories/cart_repository_impl.dart';
import 'package:flutter_demo/features/order/data/repositories/order_repository_impl.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_demo/features/product/data/repositories/product_repository_impl.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_local_datasource.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_remote_datasource.dart';
import 'package:flutter_demo/features/profile/data/repositories/user_repository_impl.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // ── Storage ──────────────────────────────────────────────
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<TokenLocalDatasource>(
    () => TokenLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<UserLocalDatasource>(
    () => UserLocalDatasource(),
  );
  getIt.registerLazySingleton<CartLocalDatasource>(
    () => CartLocalDatasource(),
  );

  // ── Network ───────────────────────────────────────────────
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt()),
  );

  // ── Datasources ───────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<OrderRemoteDatasource>(
    () => OrderRemoteDatasource(getIt()),
  );

  // ── Repositories ──────────────────────────────────────────
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ICartRepository>(
    () => CartRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(getIt()),
  );

  // ── Use cases ─────────────────────────────────────────────
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase(getIt()));
  getIt.registerFactory<GetProductsUseCase>(
      () => GetProductsUseCase(getIt()));
  getIt.registerFactory<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt()));
  getIt.registerFactory<AddToCartUseCase>(() => AddToCartUseCase(getIt()));
  getIt.registerFactory<RemoveFromCartUseCase>(
      () => RemoveFromCartUseCase(getIt()));
  getIt.registerFactory<GetCartUseCase>(() => GetCartUseCase(getIt()));
  getIt.registerFactory<ClearCartUseCase>(() => ClearCartUseCase(getIt()));
  getIt.registerFactory<PlaceOrderUseCase>(() => PlaceOrderUseCase(getIt()));
  getIt.registerFactory<GetOrdersUseCase>(() => GetOrdersUseCase(getIt()));

  // ── BLoC / Cubit ──────────────────────────────────────────
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt()));
  getIt.registerFactory<ProductCubit>(() => ProductCubit(getIt()));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt(), getIt()));
  getIt.registerFactory<CartCubit>(
      () => CartCubit(getIt(), getIt(), getIt()));
  getIt.registerFactory<OrderCubit>(
      () => OrderCubit(getIt(), getIt(), getIt()));
}
```

- [ ] **Step 2: Update `discover_tab.dart`**

Replace the entire file:

```dart
// lib/features/product/presentation/pages/discover_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:flutter_demo/features/order/presentation/widgets/cart_bottom_sheet.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';

const List<String> _categories = ['All Items', 'Electronics', 'Fashion'];

const List<String> _localImages = [
  'assets/images/sample1.png',
  'assets/images/sample2.png',
  'assets/images/sample3.png',
  'assets/images/sample4.png',
  'assets/images/sample5.png',
];

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String _searchQuery = '';
  String _activeCategory = 'All Items';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
    context.read<CartCubit>().loadCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.shark,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.paleSky),
                      onPressed: () {},
                    ),
                    // Cart icon with badge
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final count = cartState is CartLoaded
                            ? cartState.totalItemCount
                            : 0;
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.paleSky),
                              onPressed: () =>
                                  CartBottomSheet.show(context),
                            ),
                            if (count > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.cyan,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search products, brands...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: AppFontSizes.fs_14,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.paleSky),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isActive = cat == _activeCategory;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.cyan : AppColors.white,
                      border: Border.all(
                        color:
                            isActive ? AppColors.cyan : AppColors.gray,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: AppFontSizes.fs_12,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? AppColors.white
                            : const Color(0xFF616161),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // Product grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyan,
                      ),
                    );
                  }

                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_outlined,
                              size: 48, color: AppColors.paleSky),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              color: AppColors.paleSky,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () =>
                                context.read<ProductCubit>().loadProducts(),
                            icon: const Icon(Icons.refresh,
                                color: AppColors.cyan),
                            label: const Text(
                              'Retry',
                              style: TextStyle(color: AppColors.cyan),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductLoaded) {
                    final filtered = _filterProducts(state.products);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: AppFontSizes.fs_14,
                            color: AppColors.paleSky,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _ProductCard(product: filtered[index]),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final localImage = _localImages[product.id % _localImages.length];
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  localImage,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: AppColors.paleSky,
                  ),
                ),
              ),
            ],
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.fs_12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: AppFontSizes.fs_14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.shark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<CartCubit>().addItem(
                              CartItemEntity(
                                productId: product.id,
                                name: product.name,
                                price: product.price,
                                priceUnit: product.priceUnit,
                                image: product.image,
                                quantity: 1,
                              ),
                            ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Update `home_page.dart`**

Replace the entire file:

```dart
// lib/presentation/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/di/service_locator.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/features/order/presentation/pages/orders_tab.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/pages/discover_tab.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/pages/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DiscoverTab(),
    OrdersTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>(create: (_) => getIt<ProductCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
        BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>()),
        BlocProvider<OrderCubit>(create: (_) => getIt<OrderCubit>()),
      ],
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            setState(() => _currentIndex = 1);
            context.read<OrderCubit>().loadOrders();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightGrey,
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.cyan,
            unselectedItemColor: AppColors.paleSky,
            selectedLabelStyle: const TextStyle(
              fontSize: AppFontSizes.fs_10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Ubuntu',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: AppFontSizes.fs_10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu',
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run flutter analyze on all modified files**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/
```

Expected: No issues found.

---

## Task 12: Unit Tests

**Files:**
- Create: `test/features/order/cubit/cart_cubit_test.dart`
- Create: `test/features/order/cubit/order_cubit_test.dart`
- Create: `test/features/order/usecases/add_to_cart_usecase_test.dart`
- Create: `test/features/order/usecases/place_order_usecase_test.dart`

- [ ] **Step 1: Create `cart_cubit_test.dart`**

```dart
// test/features/order/cubit/cart_cubit_test.dart
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
        CartLoaded(
          items: const [_mockItem],
          totalAmount: 29.99,
        ),
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
        when(() => mockGet()).thenAnswer(
            (_) async => const Success([_mockItem]));
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
```

- [ ] **Step 2: Create `order_cubit_test.dart`**

```dart
// test/features/order/cubit/order_cubit_test.dart
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
        when(() => mockGetOrders())
            .thenAnswer((_) async => const Failure('Failed to load orders'));
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
```

- [ ] **Step 3: Create `add_to_cart_usecase_test.dart`**

```dart
// test/features/order/usecases/add_to_cart_usecase_test.dart
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
    test('delegates to repository addItem', () async {
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
```

- [ ] **Step 4: Create `place_order_usecase_test.dart`**

```dart
// test/features/order/usecases/place_order_usecase_test.dart
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
```

- [ ] **Step 5: Run all tests**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter test test/features/order/
```

Expected: All tests pass.

---

## Task 13: Update docs/architecture.html

**Files:**
- Modify: `docs/architecture.html`

- [ ] **Step 1: Open `docs/architecture.html` and add the `features/order/` section**

In the **Features** section of the architecture diagram, add `features/order/` with its domain/data/presentation sub-layers.

In the **State Machines** section, add:

```
CartCubit states:
  CartInitial → CartLoaded(items, totalAmount) | CartError(message)

OrderCubit states:
  OrderInitial
  OrderLoading   (GET /order/ in progress)
  OrderLoaded(orders)
  OrderError(message)
  OrderPlacing   (POST /order/ in progress)
  OrderSuccess   (triggers: clear cart, close sheet, snackbar, switch to Orders tab)
```

In the **Tab Navigation** section, update to show 3 tabs:
```
index 0: Home (DiscoverTab)
index 1: Orders (OrdersTab) ← NEW
index 2: Profile (ProfileTab)
```

Add a note: `shippingAddress` and `paymentMethod` are hardcoded (`"Default Address"`, `"cash_on_delivery"`) — no UI for these fields.

- [ ] **Step 2: Run flutter analyze one final time**

```bash
cd C:/project/nt-flutter-starter/flutter && flutter analyze lib/ && flutter test test/features/
```

Expected: No analysis issues, all tests pass.
