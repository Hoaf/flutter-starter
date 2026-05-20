# Feature-First Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the Flutter project from layer-first to feature-first architecture by moving files created during API integration into `lib/features/` and `lib/core/`, without touching legacy files.

**Architecture:** Each feature (auth, product, profile) contains its own data/domain/presentation sub-layers. Shared infrastructure (ApiClient, TokenLocalDatasource) lives in `core/`. UserEntity and UserModel live in `features/auth/` since auth owns user identity; profile imports from there.

**Tech Stack:** Flutter, Dart, flutter_bloc, get_it, mocktail, sqflite, flutter_secure_storage

---

## File Map

### Files being MOVED (git mv)

| Old path | New path |
|----------|----------|
| `lib/data/datasources/token_local_datasource.dart` | `lib/core/storage/token_local_datasource.dart` |
| `lib/data/network/api_client.dart` | `lib/core/network/api_client.dart` |
| `lib/domain/entities/user_entity.dart` | `lib/features/auth/domain/entities/user_entity.dart` |
| `lib/domain/repositories/i_auth_repository.dart` | `lib/features/auth/domain/repositories/i_auth_repository.dart` |
| `lib/domain/usecases/login_usecase.dart` | `lib/features/auth/domain/usecases/login_usecase.dart` |
| `lib/domain/usecases/logout_usecase.dart` | `lib/features/auth/domain/usecases/logout_usecase.dart` |
| `lib/data/models/user_model.dart` | `lib/features/auth/data/models/user_model.dart` |
| `lib/data/models/auth_response_model.dart` | `lib/features/auth/data/models/auth_response_model.dart` |
| `lib/data/datasources/auth_remote_datasource.dart` | `lib/features/auth/data/datasources/auth_remote_datasource.dart` |
| `lib/data/repositories/auth_repository_impl.dart` | `lib/features/auth/data/repositories/auth_repository_impl.dart` |
| `lib/presentation/screens/auth/bloc/login_event.dart` | `lib/features/auth/presentation/bloc/login_event.dart` |
| `lib/presentation/screens/auth/bloc/login_state.dart` | `lib/features/auth/presentation/bloc/login_state.dart` |
| `lib/presentation/screens/auth/bloc/login_bloc.dart` | `lib/features/auth/presentation/bloc/login_bloc.dart` |
| `lib/presentation/screens/auth/login_page.dart` | `lib/features/auth/presentation/pages/login_page.dart` |
| `lib/domain/entities/product_entity.dart` | `lib/features/product/domain/entities/product_entity.dart` |
| `lib/domain/repositories/i_product_repository.dart` | `lib/features/product/domain/repositories/i_product_repository.dart` |
| `lib/domain/usecases/get_products_usecase.dart` | `lib/features/product/domain/usecases/get_products_usecase.dart` |
| `lib/data/models/product_model.dart` | `lib/features/product/data/models/product_model.dart` |
| `lib/data/datasources/product_remote_datasource.dart` | `lib/features/product/data/datasources/product_remote_datasource.dart` |
| `lib/data/repositories/product_repository_impl.dart` | `lib/features/product/data/repositories/product_repository_impl.dart` |
| `lib/presentation/screens/home/tabs/product_cubit/product_state.dart` | `lib/features/product/presentation/cubit/product_state.dart` |
| `lib/presentation/screens/home/tabs/product_cubit/product_cubit.dart` | `lib/features/product/presentation/cubit/product_cubit.dart` |
| `lib/presentation/screens/home/tabs/discover_tab.dart` | `lib/features/product/presentation/pages/discover_tab.dart` |
| `lib/domain/repositories/i_user_repository.dart` | `lib/features/profile/domain/repositories/i_user_repository.dart` |
| `lib/domain/usecases/get_user_profile_usecase.dart` | `lib/features/profile/domain/usecases/get_user_profile_usecase.dart` |
| `lib/data/datasources/user_remote_datasource.dart` | `lib/features/profile/data/datasources/user_remote_datasource.dart` |
| `lib/data/datasources/user_local_datasource.dart` | `lib/features/profile/data/datasources/user_local_datasource.dart` |
| `lib/data/repositories/user_repository_impl.dart` | `lib/features/profile/data/repositories/user_repository_impl.dart` |
| `lib/presentation/screens/home/tabs/profile_cubit/profile_state.dart` | `lib/features/profile/presentation/cubit/profile_state.dart` |
| `lib/presentation/screens/home/tabs/profile_cubit/profile_cubit.dart` | `lib/features/profile/presentation/cubit/profile_cubit.dart` |
| `lib/presentation/screens/home/tabs/profile_tab.dart` | `lib/features/profile/presentation/pages/profile_tab.dart` |

### Files being UPDATED (imports only, not moved)

- `lib/di/service_locator.dart`
- `lib/presentation/screens/home/home_page.dart`
- `lib/presentation/routes/routers.dart`

### Test files being MOVED + updated

| Old path | New path |
|----------|----------|
| `test/presentation/auth/bloc/login_bloc_test.dart` | `test/features/auth/bloc/login_bloc_test.dart` |
| `test/domain/usecases/login_usecase_test.dart` | `test/features/auth/usecases/login_usecase_test.dart` |
| `test/presentation/home/product_cubit_test.dart` | `test/features/product/cubit/product_cubit_test.dart` |
| `test/presentation/home/profile_cubit_test.dart` | `test/features/profile/cubit/profile_cubit_test.dart` |

---

## Task 1: Move core infrastructure

**Files:**
- Create dir: `lib/core/storage/`, `lib/core/network/`
- Move: `lib/data/datasources/token_local_datasource.dart` → `lib/core/storage/token_local_datasource.dart`
- Move: `lib/data/network/api_client.dart` → `lib/core/network/api_client.dart`

- [ ] **Step 1: Create directories and move files**

```bash
cd C:/project/nt-flutter-starter/flutter
mkdir -p lib/core/storage lib/core/network
git mv lib/data/datasources/token_local_datasource.dart lib/core/storage/token_local_datasource.dart
git mv lib/data/network/api_client.dart lib/core/network/api_client.dart
```

- [ ] **Step 2: Update imports in `lib/core/network/api_client.dart`**

The file imports `token_local_datasource`. Update it:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';

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

- [ ] **Step 3: Verify (errors expected — other files still have old imports)**

```bash
flutter analyze lib/core/ 2>&1 | head -20
```

Expected: `lib/core/` files themselves have no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/core/
git commit -m "refactor: move core infrastructure to lib/core/"
```

---

## Task 2: Move auth domain layer

**Files:**
- Move: `lib/domain/entities/user_entity.dart` → `lib/features/auth/domain/entities/user_entity.dart`
- Move: `lib/domain/repositories/i_auth_repository.dart` → `lib/features/auth/domain/repositories/i_auth_repository.dart`
- Move: `lib/domain/usecases/login_usecase.dart` → `lib/features/auth/domain/usecases/login_usecase.dart`
- Move: `lib/domain/usecases/logout_usecase.dart` → `lib/features/auth/domain/usecases/logout_usecase.dart`

- [ ] **Step 1: Create directories and move files**

```bash
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/usecases
git mv lib/domain/entities/user_entity.dart lib/features/auth/domain/entities/user_entity.dart
git mv lib/domain/repositories/i_auth_repository.dart lib/features/auth/domain/repositories/i_auth_repository.dart
git mv lib/domain/usecases/login_usecase.dart lib/features/auth/domain/usecases/login_usecase.dart
git mv lib/domain/usecases/logout_usecase.dart lib/features/auth/domain/usecases/logout_usecase.dart
```

- [ ] **Step 2: Update imports in `lib/features/auth/domain/repositories/i_auth_repository.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Result<UserEntity, String>> login(String username, String password);
  Future<Result<void, String>> logout();
}
```

- [ ] **Step 3: Update imports in `lib/features/auth/domain/usecases/login_usecase.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<Result<UserEntity, String>> call(String username, String password) =>
      _repo.login(username, password);
}
```

- [ ] **Step 4: Update imports in `lib/features/auth/domain/usecases/logout_usecase.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository _repo;
  const LogoutUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.logout();
}
```

- [ ] **Step 5: `user_entity.dart` needs no import changes** (only imports equatable). No action.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/domain/
git commit -m "refactor: move auth domain layer to features/auth/domain/"
```

---

## Task 3: Move auth data layer

**Files:**
- Move: `lib/data/models/user_model.dart` → `lib/features/auth/data/models/user_model.dart`
- Move: `lib/data/models/auth_response_model.dart` → `lib/features/auth/data/models/auth_response_model.dart`
- Move: `lib/data/datasources/auth_remote_datasource.dart` → `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Move: `lib/data/repositories/auth_repository_impl.dart` → `lib/features/auth/data/repositories/auth_repository_impl.dart`

- [ ] **Step 1: Create directories and move files**

```bash
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/datasources
mkdir -p lib/features/auth/data/repositories
git mv lib/data/models/user_model.dart lib/features/auth/data/models/user_model.dart
git mv lib/data/models/auth_response_model.dart lib/features/auth/data/models/auth_response_model.dart
git mv lib/data/datasources/auth_remote_datasource.dart lib/features/auth/data/datasources/auth_remote_datasource.dart
git mv lib/data/repositories/auth_repository_impl.dart lib/features/auth/data/repositories/auth_repository_impl.dart
```

- [ ] **Step 2: Update imports in `lib/features/auth/data/models/user_model.dart`**

```dart
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String role;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        role: json['role'] as String? ?? 'user',
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        role: role,
      );
}
```

- [ ] **Step 3: Update imports in `lib/features/auth/data/models/auth_response_model.dart`**

```dart
import 'package:flutter_demo/features/auth/data/models/user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  const AuthResponseModel({
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'] as String,
      );
}
```

- [ ] **Step 4: Update imports in `lib/features/auth/data/datasources/auth_remote_datasource.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_demo/core/network/api_client.dart';

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

- [ ] **Step 5: Update imports in `lib/features/auth/data/repositories/auth_repository_impl.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';
import 'package:flutter_demo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';

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

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/data/
git commit -m "refactor: move auth data layer to features/auth/data/"
```

---

## Task 4: Move auth presentation layer

**Files:**
- Move: `lib/presentation/screens/auth/bloc/login_event.dart` → `lib/features/auth/presentation/bloc/login_event.dart`
- Move: `lib/presentation/screens/auth/bloc/login_state.dart` → `lib/features/auth/presentation/bloc/login_state.dart`
- Move: `lib/presentation/screens/auth/bloc/login_bloc.dart` → `lib/features/auth/presentation/bloc/login_bloc.dart`
- Move: `lib/presentation/screens/auth/login_page.dart` → `lib/features/auth/presentation/pages/login_page.dart`

- [ ] **Step 1: Create directories and move files**

```bash
mkdir -p lib/features/auth/presentation/bloc
mkdir -p lib/features/auth/presentation/pages
git mv lib/presentation/screens/auth/bloc/login_event.dart lib/features/auth/presentation/bloc/login_event.dart
git mv lib/presentation/screens/auth/bloc/login_state.dart lib/features/auth/presentation/bloc/login_state.dart
git mv lib/presentation/screens/auth/bloc/login_bloc.dart lib/features/auth/presentation/bloc/login_bloc.dart
git mv lib/presentation/screens/auth/login_page.dart lib/features/auth/presentation/pages/login_page.dart
```

- [ ] **Step 2: `login_event.dart` has no internal imports — no changes needed.**

- [ ] **Step 3: Update imports in `lib/features/auth/presentation/bloc/login_state.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 4: Update imports in `lib/features/auth/presentation/bloc/login_bloc.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';

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

- [ ] **Step 5: Update imports in `lib/features/auth/presentation/pages/login_page.dart`**

Replace all 3 bloc import lines at the top:

```dart
// OLD:
import 'package:flutter_demo/presentation/screens/auth/bloc/login_bloc.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_event.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_state.dart';

// NEW:
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
```

The other imports in `login_page.dart` (flutter, flutter_bloc, di, config, routes, widgets) stay unchanged.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/
git commit -m "refactor: move auth presentation layer to features/auth/presentation/"
```

---

## Task 5: Move product feature

**Files:** All product files across domain/data/presentation.

- [ ] **Step 1: Create directories and move all product files**

```bash
mkdir -p lib/features/product/domain/entities
mkdir -p lib/features/product/domain/repositories
mkdir -p lib/features/product/domain/usecases
mkdir -p lib/features/product/data/models
mkdir -p lib/features/product/data/datasources
mkdir -p lib/features/product/data/repositories
mkdir -p lib/features/product/presentation/cubit
mkdir -p lib/features/product/presentation/pages
git mv lib/domain/entities/product_entity.dart lib/features/product/domain/entities/product_entity.dart
git mv lib/domain/repositories/i_product_repository.dart lib/features/product/domain/repositories/i_product_repository.dart
git mv lib/domain/usecases/get_products_usecase.dart lib/features/product/domain/usecases/get_products_usecase.dart
git mv lib/data/models/product_model.dart lib/features/product/data/models/product_model.dart
git mv lib/data/datasources/product_remote_datasource.dart lib/features/product/data/datasources/product_remote_datasource.dart
git mv lib/data/repositories/product_repository_impl.dart lib/features/product/data/repositories/product_repository_impl.dart
git mv lib/presentation/screens/home/tabs/product_cubit/product_state.dart lib/features/product/presentation/cubit/product_state.dart
git mv lib/presentation/screens/home/tabs/product_cubit/product_cubit.dart lib/features/product/presentation/cubit/product_cubit.dart
git mv lib/presentation/screens/home/tabs/discover_tab.dart lib/features/product/presentation/pages/discover_tab.dart
```

- [ ] **Step 2: `product_entity.dart` has no internal imports — no changes needed.**

- [ ] **Step 3: Update `lib/features/product/domain/repositories/i_product_repository.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';

abstract class IProductRepository {
  Future<Result<List<ProductEntity>, String>> getProducts();
}
```

- [ ] **Step 4: Update `lib/features/product/domain/usecases/get_products_usecase.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository _repo;
  const GetProductsUseCase(this._repo);

  Future<Result<List<ProductEntity>, String>> call() => _repo.getProducts();
}
```

- [ ] **Step 5: Update `lib/features/product/data/models/product_model.dart`**

```dart
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String priceUnit;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.priceUnit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String?,
        priceUnit: json['priceUnit'] as String? ?? 'dollar',
      );

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        description: description,
        price: price,
        image: image,
        priceUnit: priceUnit,
      );
}
```

- [ ] **Step 6: Update `lib/features/product/data/datasources/product_remote_datasource.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/product/data/models/product_model.dart';

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

- [ ] **Step 7: Update `lib/features/product/data/repositories/product_repository_impl.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';

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

- [ ] **Step 8: Update `lib/features/product/presentation/cubit/product_state.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 9: Update `lib/features/product/presentation/cubit/product_cubit.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';

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

- [ ] **Step 10: Update `lib/features/product/presentation/pages/discover_tab.dart`**

Replace the 3 internal import lines:

```dart
// OLD:
import 'package:flutter_demo/domain/entities/product_entity.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/product_cubit/product_cubit.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/product_cubit/product_state.dart';

// NEW:
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';
```

All other imports in `discover_tab.dart` (flutter, flutter_bloc, config, font_sizes) stay unchanged.

- [ ] **Step 11: Commit**

```bash
git add lib/features/product/
git commit -m "refactor: move product feature to features/product/"
```

---

## Task 6: Move profile feature

**Files:** All profile files across domain/data/presentation.

- [ ] **Step 1: Create directories and move all profile files**

```bash
mkdir -p lib/features/profile/domain/repositories
mkdir -p lib/features/profile/domain/usecases
mkdir -p lib/features/profile/data/datasources
mkdir -p lib/features/profile/data/repositories
mkdir -p lib/features/profile/presentation/cubit
mkdir -p lib/features/profile/presentation/pages
git mv lib/domain/repositories/i_user_repository.dart lib/features/profile/domain/repositories/i_user_repository.dart
git mv lib/domain/usecases/get_user_profile_usecase.dart lib/features/profile/domain/usecases/get_user_profile_usecase.dart
git mv lib/data/datasources/user_remote_datasource.dart lib/features/profile/data/datasources/user_remote_datasource.dart
git mv lib/data/datasources/user_local_datasource.dart lib/features/profile/data/datasources/user_local_datasource.dart
git mv lib/data/repositories/user_repository_impl.dart lib/features/profile/data/repositories/user_repository_impl.dart
git mv lib/presentation/screens/home/tabs/profile_cubit/profile_state.dart lib/features/profile/presentation/cubit/profile_state.dart
git mv lib/presentation/screens/home/tabs/profile_cubit/profile_cubit.dart lib/features/profile/presentation/cubit/profile_cubit.dart
git mv lib/presentation/screens/home/tabs/profile_tab.dart lib/features/profile/presentation/pages/profile_tab.dart
```

- [ ] **Step 2: Update `lib/features/profile/domain/repositories/i_user_repository.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<Result<UserEntity, String>> getProfile();
}
```

- [ ] **Step 3: Update `lib/features/profile/domain/usecases/get_user_profile_usecase.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';

class GetUserProfileUseCase {
  final IUserRepository _repo;
  const GetUserProfileUseCase(this._repo);

  Future<Result<UserEntity, String>> call() => _repo.getProfile();
}
```

- [ ] **Step 4: Update `lib/features/profile/data/datasources/user_remote_datasource.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/auth/data/models/user_model.dart';

class UserRemoteDatasource {
  final Dio _dio;

  UserRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/user/');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 5: Update `lib/features/profile/data/datasources/user_local_datasource.dart`**

```dart
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

- [ ] **Step 6: Update `lib/features/profile/data/repositories/user_repository_impl.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_local_datasource.dart';
import 'package:flutter_demo/features/profile/data/datasources/user_remote_datasource.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';

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

- [ ] **Step 7: Update `lib/features/profile/presentation/cubit/profile_state.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
```

- [ ] **Step 8: Update `lib/features/profile/presentation/cubit/profile_cubit.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';

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

- [ ] **Step 9: Update `lib/features/profile/presentation/pages/profile_tab.dart`**

Replace the 3 internal import lines:

```dart
// OLD:
import 'package:flutter_demo/domain/entities/user_entity.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/profile_cubit/profile_cubit.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/profile_cubit/profile_state.dart';

// NEW:
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';
```

All other imports in `profile_tab.dart` (flutter, flutter_bloc, config, routes) stay unchanged.

- [ ] **Step 10: Commit**

```bash
git add lib/features/profile/
git commit -m "refactor: move profile feature to features/profile/"
```

---

## Task 7: Update consumers

**Files:** `service_locator.dart`, `home_page.dart`, `routers.dart` — imports only, no logic changes.

- [ ] **Step 1: Rewrite `lib/di/service_locator.dart` with updated imports**

```dart
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/core/storage/token_local_datasource.dart';
import 'package:flutter_demo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_demo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
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

  // ── Use cases ─────────────────────────────────────────────
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase(getIt()));
  getIt.registerFactory<GetProductsUseCase>(() => GetProductsUseCase(getIt()));
  getIt.registerFactory<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt()));

  // ── BLoC / Cubit ──────────────────────────────────────────
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt()));
  getIt.registerFactory<ProductCubit>(() => ProductCubit(getIt()));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt(), getIt()));
}
```

- [ ] **Step 2: Update `lib/presentation/screens/home/home_page.dart`**

Replace the 4 internal import lines:

```dart
// OLD:
import 'package:flutter_demo/presentation/screens/home/tabs/discover_tab.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/product_cubit/product_cubit.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/profile_cubit/profile_cubit.dart';
import 'package:flutter_demo/presentation/screens/home/tabs/profile_tab.dart';

// NEW:
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/pages/discover_tab.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/pages/profile_tab.dart';
```

- [ ] **Step 3: Update `lib/presentation/routes/routers.dart`**

```dart
// OLD:
import 'package:flutter_demo/presentation/screens/auth/login_page.dart';

// NEW:
import 'package:flutter_demo/features/auth/presentation/pages/login_page.dart';
```

- [ ] **Step 4: Run flutter analyze — expect zero errors**

```bash
flutter analyze 2>&1 | grep -E "error|warning" | grep -v "^$" | head -30
```

Expected: no `error` lines. Warnings about unused legacy files are fine.

- [ ] **Step 5: Commit**

```bash
git add lib/di/service_locator.dart lib/presentation/screens/home/home_page.dart lib/presentation/routes/routers.dart
git commit -m "refactor: update consumers to use new feature-first import paths"
```

---

## Task 8: Restructure test files

**Files:** Move 4 test files and update their imports.

- [ ] **Step 1: Create test directories and move files**

```bash
mkdir -p test/features/auth/bloc
mkdir -p test/features/auth/usecases
mkdir -p test/features/product/cubit
mkdir -p test/features/profile/cubit
git mv test/presentation/auth/bloc/login_bloc_test.dart test/features/auth/bloc/login_bloc_test.dart
git mv test/domain/usecases/login_usecase_test.dart test/features/auth/usecases/login_usecase_test.dart
git mv test/presentation/home/product_cubit_test.dart test/features/product/cubit/product_cubit_test.dart
git mv test/presentation/home/profile_cubit_test.dart test/features/profile/cubit/profile_cubit_test.dart
```

- [ ] **Step 2: Rewrite `test/features/auth/bloc/login_bloc_test.dart`**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockUseCase;
  late LoginBloc bloc;

  const mockUser = UserEntity(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    age: 25,
    role: 'user',
  );

  setUp(() {
    mockUseCase = MockLoginUseCase();
    bloc = LoginBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('LoginBloc', () {
    test('initial state is LoginInitial', () {
      expect(bloc.state, const LoginInitial());
    });

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginSuccess] on successful login',
      build: () {
        when(() => mockUseCase(any(), any()))
            .thenAnswer((_) async => const Success(mockUser));
        return bloc;
      },
      act: (b) => b.add(const LoginSubmitEvent(
          username: 'testuser', password: 'password123')),
      expect: () => [
        const LoginLoading(),
        const LoginSuccess(user: mockUser),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginFailure] on wrong password',
      build: () {
        when(() => mockUseCase(any(), any())).thenAnswer(
            (_) async => const Failure('Invalid username or password'));
        return bloc;
      },
      act: (b) => b.add(const LoginSubmitEvent(
          username: 'testuser', password: 'wrongpassword')),
      expect: () => [
        const LoginLoading(),
        const LoginFailure(message: 'Invalid username or password'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginFailure] immediately when username is empty (no API call)',
      build: () => bloc,
      act: (b) =>
          b.add(const LoginSubmitEvent(username: '', password: 'pass')),
      expect: () => [
        const LoginFailure(
            message: 'Please enter your username and password'),
      ],
      verify: (_) => verifyNever(() => mockUseCase(any(), any())),
    );
  });
}
```

- [ ] **Step 3: Rewrite `test/features/auth/usecases/login_usecase_test.dart`**

```dart
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockRepo;
  late LoginUseCase useCase;

  const mockUser = UserEntity(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    age: 25,
    role: 'user',
  );

  setUp(() {
    mockRepo = MockIAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('returns Success when repository returns a user', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => const Success(mockUser));

      final result = await useCase('testuser', 'password123');

      expect(result, isA<Success<UserEntity, String>>());
      final success = result as Success<UserEntity, String>;
      expect(success.value.username, 'testuser');
    });

    test('returns Failure when repository returns an error', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer(
          (_) async => const Failure('Invalid username or password'));

      final result = await useCase('testuser', 'wrongpass');

      expect(result, isA<Failure<UserEntity, String>>());
      final failure = result as Failure<UserEntity, String>;
      expect(failure.exception, 'Invalid username or password');
    });

    test('delegates to repository with correct arguments', () async {
      when(() => mockRepo.login('user1', 'pass1'))
          .thenAnswer((_) async => const Success(mockUser));

      await useCase('user1', 'pass1');

      verify(() => mockRepo.login('user1', 'pass1')).called(1);
    });
  });
}
```

- [ ] **Step 4: Rewrite `test/features/product/cubit/product_cubit_test.dart`**

```dart
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
```

- [ ] **Step 5: Rewrite `test/features/profile/cubit/profile_cubit_test.dart`**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockGetUserProfileUseCase mockGetProfile;
  late MockLogoutUseCase mockLogout;
  late ProfileCubit cubit;

  const mockUser = UserEntity(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    age: 25,
    role: 'user',
  );

  setUp(() {
    mockGetProfile = MockGetUserProfileUseCase();
    mockLogout = MockLogoutUseCase();
    cubit = ProfileCubit(mockGetProfile, mockLogout);
  });

  tearDown(() => cubit.close());

  group('ProfileCubit', () {
    test('initial state is ProfileInitial', () {
      expect(cubit.state, const ProfileInitial());
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] on successful profile load',
      build: () {
        when(() => mockGetProfile())
            .thenAnswer((_) async => const Success(mockUser));
        return cubit;
      },
      act: (c) => c.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(user: mockUser),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] on API error',
      build: () {
        when(() => mockGetProfile()).thenAnswer(
            (_) async => const Failure('Failed to load user profile'));
        return cubit;
      },
      act: (c) => c.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Failed to load user profile'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoggedOut] after logout()',
      build: () {
        when(() => mockLogout())
            .thenAnswer((_) async => const Success(null));
        return cubit;
      },
      act: (c) => c.logout(),
      expect: () => [const ProfileLoggedOut()],
    );
  });
}
```

- [ ] **Step 6: Commit**

```bash
git add test/features/
git commit -m "refactor: restructure tests to follow feature-first layout"
```

---

## Task 9: Verify and update docs

- [ ] **Step 1: Run flutter analyze — must show zero errors**

```bash
flutter analyze 2>&1
```

Expected output ends with: `No issues found!` (warnings about unused legacy files are acceptable)

If errors appear, they will be unresolved imports. Fix each by checking the new path in the file map table at the top of this plan.

- [ ] **Step 2: Run all tests — must pass 14/14**

```bash
flutter test test/features/ 2>&1
```

Expected:
```
+14: All tests passed!
```

- [ ] **Step 3: Update `docs/architecture.md`**

In the "Files liên quan" tables across all sections, update paths to reflect the new structure. Key path changes:

| Old | New |
|-----|-----|
| `data/datasources/token_local_datasource.dart` | `core/storage/token_local_datasource.dart` |
| `data/network/api_client.dart` | `core/network/api_client.dart` |
| `domain/entities/user_entity.dart` | `features/auth/domain/entities/user_entity.dart` |
| `domain/repositories/i_auth_repository.dart` | `features/auth/domain/repositories/i_auth_repository.dart` |
| `domain/usecases/login_usecase.dart` | `features/auth/domain/usecases/login_usecase.dart` |
| `domain/usecases/logout_usecase.dart` | `features/auth/domain/usecases/logout_usecase.dart` |
| `data/models/user_model.dart` | `features/auth/data/models/user_model.dart` |
| `data/repositories/auth_repository_impl.dart` | `features/auth/data/repositories/auth_repository_impl.dart` |
| `screens/auth/bloc/login_bloc.dart` | `features/auth/presentation/bloc/login_bloc.dart` |
| `screens/auth/login_page.dart` | `features/auth/presentation/pages/login_page.dart` |
| `domain/entities/product_entity.dart` | `features/product/domain/entities/product_entity.dart` |
| `tabs/product_cubit/product_cubit.dart` | `features/product/presentation/cubit/product_cubit.dart` |
| `tabs/discover_tab.dart` | `features/product/presentation/pages/discover_tab.dart` |
| `domain/repositories/i_user_repository.dart` | `features/profile/domain/repositories/i_user_repository.dart` |
| `tabs/profile_cubit/profile_cubit.dart` | `features/profile/presentation/cubit/profile_cubit.dart` |
| `tabs/profile_tab.dart` | `features/profile/presentation/pages/profile_tab.dart` |

Also update Section 1 (Clean Architecture) to reflect the new folder layout, and add a note that `UserEntity`/`UserModel` live in `features/auth/` and are imported by `features/profile/`.

- [ ] **Step 4: Update `docs/architecture.html`** with the same path changes (find/replace in the diagram and table sections).

- [ ] **Step 5: Final commit**

```bash
git add docs/
git commit -m "docs: update architecture docs to reflect feature-first structure"
```
