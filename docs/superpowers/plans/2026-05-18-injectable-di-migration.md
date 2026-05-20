# Injectable DI Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace manual DI registration in `service_locator.dart` with `@injectable` code generation, so adding new classes only requires an annotation.

**Architecture:** Annotate each class with `@lazySingleton`, `@LazySingleton(as: IFoo)`, or `@injectable`. A separate `injection_module.dart` registers `FlutterSecureStorage` (third-party, cannot be annotated). `build_runner` generates `service_locator.config.dart`. The entry point `service_locator.dart` shrinks to 3 lines.

**Tech Stack:** `injectable: ^2.5.0`, `injectable_generator` (already in pubspec), `build_runner: ^2.4.15`, `get_it: ^8.0.3`

---

## File Map

| Action | File |
|---|---|
| Create | `lib/di/injection_module.dart` |
| Rewrite | `lib/di/service_locator.dart` |
| Generated (do not edit) | `lib/di/service_locator.config.dart` |
| Delete | `lib/di/injector.dart` |
| Annotate | 23 files listed in Tasks 2–6 |

---

## Task 1: Create injection_module.dart

**Files:**
- Create: `lib/di/injection_module.dart`

- [ ] **Step 1: Create the module file**

`lib/di/injection_module.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@module
abstract class InjectionModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
```

- [ ] **Step 2: Verify no analyze errors**

Run from `C:/project/nt-flutter-starter/flutter`:
```bash
flutter analyze lib/di/injection_module.dart
```
Expected: No issues found.

---

## Task 2: Annotate core layer (storage + network)

**Files:**
- Modify: `lib/core/storage/token_local_datasource.dart`
- Modify: `lib/core/network/api_client.dart`

- [ ] **Step 1: Annotate TokenLocalDatasource**

`lib/core/storage/token_local_datasource.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenLocalDatasource {
  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  const TokenLocalDatasource(this._storage);

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> getToken() => _storage.read(key: _key);

  Future<void> deleteToken() => _storage.delete(key: _key);
}
```

- [ ] **Step 2: Annotate ApiClient**

`lib/core/network/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:3000';

  late final Dio dio;

  ApiClient(TokenLocalDatasource tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor(tokenStorage));
  }
}

class AuthInterceptor extends Interceptor {
  final TokenLocalDatasource _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/core/
```
Expected: No issues found.

---

## Task 3: Annotate datasources

**Files:**
- Modify: `lib/features/profile/data/datasources/user_local_datasource.dart`
- Modify: `lib/features/order/data/datasources/cart_local_datasource.dart`
- Modify: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Modify: `lib/features/product/data/datasources/product_remote_datasource.dart`
- Modify: `lib/features/profile/data/datasources/user_remote_datasource.dart`
- Modify: `lib/features/order/data/datasources/order_remote_datasource.dart`

- [ ] **Step 1: Annotate UserLocalDatasource**

`lib/features/profile/data/datasources/user_local_datasource.dart`:
```dart
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class UserLocalDatasource {
  static const _dbName = 'app.db';
  static const _tableName = 'user_profile';

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
          id INTEGER PRIMARY KEY,
          username TEXT NOT NULL,
          email TEXT,
          first_name TEXT,
          last_name TEXT,
          age INTEGER,
          role TEXT
        )
      '''),
      version: 1,
    );
  }

  Future<void> saveUser(UserEntity user) async {
    final db = await database;
    await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserEntity?> getUser() async {
    final db = await database;
    final maps = await db.query(_tableName, limit: 1);
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
```

- [ ] **Step 2: Annotate CartLocalDatasource**

`lib/features/order/data/datasources/cart_local_datasource.dart`:
```dart
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
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

- [ ] **Step 3: Annotate AuthRemoteDatasource**

`lib/features/auth/data/datasources/auth_remote_datasource.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<AuthResponseModel> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    return AuthResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post('/logout');
  }
}
```

- [ ] **Step 4: Annotate ProductRemoteDatasource**

`lib/features/product/data/datasources/product_remote_datasource.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/product/data/models/product_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProductRemoteDatasource {
  final Dio _dio;

  ProductRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<List<ProductModel>> getProducts() async {
    final response = await _dio.get('/product/');
    final list = response.data['data'] as List;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

- [ ] **Step 5: Annotate UserRemoteDatasource**

`lib/features/profile/data/datasources/user_remote_datasource.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserRemoteDatasource {
  final Dio _dio;

  UserRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/user/');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 6: Annotate OrderRemoteDatasource**

`lib/features/order/data/datasources/order_remote_datasource.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/order/data/models/order_model.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
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

- [ ] **Step 7: Verify**

```bash
flutter analyze lib/features/auth/data/datasources/ lib/features/product/data/datasources/ lib/features/profile/data/datasources/ lib/features/order/data/datasources/
```
Expected: No issues found.

---

## Task 4: Annotate repository implementations

**Files:**
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Modify: `lib/features/profile/data/repositories/user_repository_impl.dart`
- Modify: `lib/features/product/data/repositories/product_repository_impl.dart`
- Modify: `lib/features/order/data/repositories/cart_repository_impl.dart`
- Modify: `lib/features/order/data/repositories/order_repository_impl.dart`

- [ ] **Step 1: Annotate AuthRepositoryImpl**

`lib/features/auth/data/repositories/auth_repository_impl.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';
import 'package:flutter_demo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource _remote;
  final TokenLocalDatasource _tokenStorage;

  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  @override
  Future<Result<UserEntity, String>> login(
      String username, String password) async {
    try {
      final result = await _remote.login(username, password);
      await _tokenStorage.saveToken(result.token);
      return Success(result.user.toEntity());
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure('An unexpected error occurred');
    }
  }

  @override
  Future<Result<void, String>> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Ignore API error — still clear local token
    } finally {
      await _tokenStorage.deleteToken();
    }
    return const Success(null);
  }

  String _mapDioError(DioException e) {
    if (e.response?.statusCode == 400) {
      return 'Invalid username or password';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Unable to connect to server';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No network connection';
    }
    return 'An unexpected error occurred (${e.response?.statusCode ?? 'unknown'})';
  }
}
```

- [ ] **Step 2: Annotate UserRepositoryImpl**

`lib/features/profile/data/repositories/user_repository_impl.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_local_datasource.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_remote_datasource.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IUserRepository)
class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDatasource _remote;
  final UserLocalDatasource _local;

  const UserRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<UserEntity, String>> getProfile() async {
    try {
      final model = await _remote.getProfile();
      final entity = model.toEntity();
      await _local.saveUser(entity);
      return Success(entity);
    } on DioException catch (_) {
      final cached = await _local.getUser();
      if (cached != null) return Success(cached);
      return Failure('Failed to load user profile');
    } catch (e) {
      final cached = await _local.getUser();
      if (cached != null) return Success(cached);
      return Failure('An unexpected error occurred');
    }
  }
}
```

- [ ] **Step 3: Annotate ProductRepositoryImpl**

`lib/features/product/data/repositories/product_repository_impl.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDatasource _remote;

  const ProductRepositoryImpl(this._remote);

  @override
  Future<Result<List<ProductEntity>, String>> getProducts() async {
    try {
      final models = await _remote.getProducts();
      return Success(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Failure('No network connection');
      }
      return Failure('Failed to load products');
    } catch (e) {
      return Failure('An unexpected error occurred');
    }
  }
}
```

- [ ] **Step 4: Annotate CartRepositoryImpl**

`lib/features/order/data/repositories/cart_repository_impl.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/cart_local_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ICartRepository)
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

- [ ] **Step 5: Annotate OrderRepositoryImpl**

`lib/features/order/data/repositories/order_repository_impl.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IOrderRepository)
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

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/features/auth/data/repositories/ lib/features/profile/data/repositories/ lib/features/product/data/repositories/ lib/features/order/data/repositories/
```
Expected: No issues found.

---

## Task 5: Annotate use cases

**Files:**
- Modify: `lib/features/auth/domain/usecases/login_usecase.dart`
- Modify: `lib/features/auth/domain/usecases/logout_usecase.dart`
- Modify: `lib/features/product/domain/usecases/get_products_usecase.dart`
- Modify: `lib/features/profile/domain/usecases/get_user_profile_usecase.dart`
- Modify: `lib/features/order/domain/usecases/add_to_cart_usecase.dart`
- Modify: `lib/features/order/domain/usecases/remove_from_cart_usecase.dart`
- Modify: `lib/features/order/domain/usecases/get_cart_usecase.dart`
- Modify: `lib/features/order/domain/usecases/clear_cart_usecase.dart`
- Modify: `lib/features/order/domain/usecases/place_order_usecase.dart`
- Modify: `lib/features/order/domain/usecases/get_orders_usecase.dart`

- [ ] **Step 1: Annotate LoginUseCase**

`lib/features/auth/domain/usecases/login_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final IAuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<Result<UserEntity, String>> call(String username, String password) =>
      _repo.login(username, password);
}
```

- [ ] **Step 2: Annotate LogoutUseCase**

`lib/features/auth/domain/usecases/logout_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final IAuthRepository _repo;
  const LogoutUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.logout();
}
```

- [ ] **Step 3: Annotate GetProductsUseCase**

`lib/features/product/domain/usecases/get_products_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProductsUseCase {
  final IProductRepository _repo;
  const GetProductsUseCase(this._repo);

  Future<Result<List<ProductEntity>, String>> call() => _repo.getProducts();
}
```

- [ ] **Step 4: Annotate GetUserProfileUseCase**

`lib/features/profile/domain/usecases/get_user_profile_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserProfileUseCase {
  final IUserRepository _repo;
  const GetUserProfileUseCase(this._repo);

  Future<Result<UserEntity, String>> call() => _repo.getProfile();
}
```

- [ ] **Step 5: Annotate AddToCartUseCase**

`lib/features/order/domain/usecases/add_to_cart_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddToCartUseCase {
  final ICartRepository _repo;
  const AddToCartUseCase(this._repo);

  Future<Result<void, String>> call(CartItemEntity item) => _repo.addItem(item);
}
```

- [ ] **Step 6: Annotate RemoveFromCartUseCase**

`lib/features/order/domain/usecases/remove_from_cart_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoveFromCartUseCase {
  final ICartRepository _repo;
  const RemoveFromCartUseCase(this._repo);

  Future<Result<void, String>> call(int productId) => _repo.removeItem(productId);
}
```

- [ ] **Step 7: Annotate GetCartUseCase**

`lib/features/order/domain/usecases/get_cart_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCartUseCase {
  final ICartRepository _repo;
  const GetCartUseCase(this._repo);

  Future<Result<List<CartItemEntity>, String>> call() => _repo.getItems();
}
```

- [ ] **Step 8: Annotate ClearCartUseCase**

`lib/features/order/domain/usecases/clear_cart_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClearCartUseCase {
  final ICartRepository _repo;
  const ClearCartUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.clear();
}
```

- [ ] **Step 9: Annotate PlaceOrderUseCase**

`lib/features/order/domain/usecases/place_order_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
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

- [ ] **Step 10: Annotate GetOrdersUseCase**

`lib/features/order/domain/usecases/get_orders_usecase.dart`:
```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrdersUseCase {
  final IOrderRepository _repo;
  const GetOrdersUseCase(this._repo);

  Future<Result<List<OrderEntity>, String>> call() => _repo.getOrders();
}
```

- [ ] **Step 11: Verify**

```bash
flutter analyze lib/features/auth/domain/usecases/ lib/features/product/domain/usecases/ lib/features/profile/domain/usecases/ lib/features/order/domain/usecases/
```
Expected: No issues found.

---

## Task 6: Annotate BLoC and Cubits

**Files:**
- Modify: `lib/features/auth/presentation/bloc/login_bloc.dart`
- Modify: `lib/features/product/presentation/cubit/product_cubit.dart`
- Modify: `lib/features/profile/presentation/cubit/profile_cubit.dart`
- Modify: `lib/features/order/presentation/cubit/cart_cubit.dart`
- Modify: `lib/features/order/presentation/cubit/order_cubit.dart`

- [ ] **Step 1: Annotate LoginBloc**

`lib/features/auth/presentation/bloc/login_bloc.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmitEvent>(_onLoginSubmit);
  }

  Future<void> _onLoginSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (event.username.trim().isEmpty || event.password.isEmpty) {
      emit(const LoginFailure(message: 'Please enter your username and password'));
      return;
    }

    emit(const LoginLoading());
    final result = await _loginUseCase(event.username.trim(), event.password);

    switch (result) {
      case Success(:final value):
        emit(LoginSuccess(user: value));
      case Failure(:final exception):
        emit(LoginFailure(message: exception));
    }
  }
}
```

- [ ] **Step 2: Annotate ProductCubit**

`lib/features/product/presentation/cubit/product_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase _useCase;

  ProductCubit(this._useCase) : super(const ProductInitial());

  Future<void> loadProducts() async {
    emit(const ProductLoading());
    final result = await _useCase();
    switch (result) {
      case Success(:final value):
        emit(ProductLoaded(products: value));
      case Failure(:final exception):
        emit(ProductError(message: exception));
    }
  }
}
```

- [ ] **Step 3: Annotate ProfileCubit**

`lib/features/profile/presentation/cubit/profile_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getProfile;
  final LogoutUseCase _logout;

  ProfileCubit(this._getProfile, this._logout) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    switch (result) {
      case Success(:final value):
        emit(ProfileLoaded(user: value));
      case Failure(:final exception):
        emit(ProfileError(message: exception));
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const ProfileLoggedOut());
  }
}
```

- [ ] **Step 4: Annotate CartCubit**

`lib/features/order/presentation/cubit/cart_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:injectable/injectable.dart';

@injectable
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

- [ ] **Step 5: Annotate OrderCubit**

`lib/features/order/presentation/cubit/order_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:injectable/injectable.dart';

@injectable
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

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/features/auth/presentation/bloc/ lib/features/product/presentation/cubit/ lib/features/profile/presentation/cubit/ lib/features/order/presentation/cubit/
```
Expected: No issues found.

---

## Task 7: Rewrite service_locator.dart

**Files:**
- Modify: `lib/di/service_locator.dart`

- [ ] **Step 1: Replace content of service_locator.dart**

`lib/di/service_locator.dart`:
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'service_locator.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> setupLocator() async => getIt.init();
```

Note: `service_locator.config.dart` does not exist yet — the `import` will show an error in the IDE until build_runner runs in Task 8. This is expected.

---

## Task 8: Run build_runner and verify

- [ ] **Step 1: Run build_runner**

```bash
cd C:/project/nt-flutter-starter/flutter
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected output contains:
```
[INFO] Succeeded after ...
```

This generates `lib/di/service_locator.config.dart`. Do not edit this file.

- [ ] **Step 2: Run flutter analyze**

```bash
flutter analyze
```
Expected: No issues found. (If `service_locator.config.dart` import error remains, it means build_runner did not generate the file — re-run Step 1.)

- [ ] **Step 3: Run flutter test**

```bash
flutter test
```
Expected: All tests pass. (Unit tests do not use `get_it`, so they are unaffected by this change.)

---

## Task 9: Delete injector.dart

**Files:**
- Delete: `lib/di/injector.dart`

- [ ] **Step 1: Delete the file**

```bash
rm lib/di/injector.dart
```

- [ ] **Step 2: Final flutter analyze**

```bash
flutter analyze
```
Expected: No issues found.
