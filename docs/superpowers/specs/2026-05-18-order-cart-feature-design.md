# Order & Cart Feature Design

## Goal

Add a Cart (bottom sheet) and Orders tab to the Flutter app. Users add products to a local SQLite cart, place an order via `POST /order/`, then view order history via `GET /order/` in a new Orders tab between Discover and Profile.

## Architecture

Follows the existing feature-first pattern: `lib/features/order/` contains all domain, data, and presentation layers.

**Tech Stack:** Flutter, flutter_bloc (Cubit), sqflite (cart), Dio (order API), get_it, mocktail

---

## File Structure

### New files

```
lib/features/order/
├── domain/
│   ├── entities/
│   │   ├── cart_item_entity.dart       # productId, name, price, priceUnit, image?, quantity
│   │   └── order_entity.dart          # id, status, totalAmount, items, shippingAddress, paymentMethod, createdAt
│   ├── repositories/
│   │   ├── i_cart_repository.dart     # addItem, removeItem, getItems, clear
│   │   └── i_order_repository.dart    # placeOrder, getOrders
│   └── usecases/
│       ├── add_to_cart_usecase.dart
│       ├── get_cart_usecase.dart
│       ├── remove_from_cart_usecase.dart
│       ├── place_order_usecase.dart
│       └── get_orders_usecase.dart
├── data/
│   ├── models/
│   │   ├── cart_item_model.dart
│   │   └── order_model.dart
│   ├── datasources/
│   │   ├── cart_local_datasource.dart    # SQLite CRUD on cart_items table
│   │   └── order_remote_datasource.dart  # POST /order/, GET /order/
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
| `lib/presentation/screens/home/home_page.dart` | Add Orders tab (index 1), add CartCubit + OrderCubit to MultiBlocProvider |
| `lib/features/product/presentation/pages/discover_tab.dart` | Wire [+] button → CartCubit.addItem(), cart icon shows item count badge |
| `lib/di/service_locator.dart` | Register CartLocalDatasource, OrderRemoteDatasource, CartRepositoryImpl, OrderRepositoryImpl, 5 use cases, CartCubit, OrderCubit |

---

## Domain Entities

### CartItemEntity
```dart
class CartItemEntity extends Equatable {
  final int productId;
  final String name;
  final double price;
  final String priceUnit;
  final String? image;
  final int quantity;
}
```

### OrderEntity
```dart
class OrderEntity extends Equatable {
  final int id;
  final String status;           // pending | processing | shipped | delivered | cancelled
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItemEntity> items;
  final String createdAt;
}

class OrderItemEntity extends Equatable {
  final int productId;
  final int quantity;
  final double price;
}
```

---

## Data Layer

### SQLite — cart_items table

```sql
CREATE TABLE cart_items (
  product_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  price_unit TEXT NOT NULL,
  image TEXT,
  quantity INTEGER NOT NULL DEFAULT 1
)
```

- `addItem`: INSERT OR REPLACE (upsert). If product already in cart, increment quantity.
- `removeItem(productId)`: DELETE WHERE product_id = ?
- `getItems`: SELECT * FROM cart_items
- `clear`: DELETE FROM cart_items

### API — POST /order/

Request body (all fields required by backend):
```json
{
  "items": [{"productId": 1, "quantity": 2, "price": 29.99}],
  "totalAmount": 59.98,
  "shippingAddress": "Default Address",
  "paymentMethod": "cash_on_delivery"
}
```

`shippingAddress` and `paymentMethod` are hardcoded — no UI for these fields.

Response: `{ status: true, data: Order }` — same envelope pattern as other APIs.

### API — GET /order/

Response: `{ status: true, data: Order[] }`

---

## State Machines

### CartCubit

```
CartInitial
CartLoaded(items: List<CartItemEntity>, totalAmount: double)
CartError(message: String)
```

No `CartLoading` — cart operations are fast SQLite reads and emit `CartLoaded` immediately.  
`totalAmount` is computed: `sum(item.price * item.quantity)`.

### OrderCubit

```
OrderInitial
OrderLoading          # GET /order/ in progress
OrderLoaded(orders: List<OrderEntity>)
OrderError(message: String)
OrderPlacing          # POST /order/ in progress — disables Place Order button
OrderSuccess          # POST succeeded — triggers: clear cart, close sheet, show snackbar, switch to Orders tab
```

---

## UI Flow

### Discover Tab changes

1. **[+] button** on product card → `CartCubit.addItem(CartItemEntity from product)`
2. **Cart icon** (top right, `Icons.shopping_cart_outlined`) → badge showing total item count → tap → `CartBottomSheet.show()`

### CartBottomSheet

- `showModalBottomSheet` with `isScrollControlled: true`
- Structure:
  ```
  ┌────────────────────────────┐
  │  Cart (N items)         ✕  │
  ├────────────────────────────┤
  │  [img] Name                │
  │        $XX.XX  [-] N [+]   │  ← quantity controls
  │  ────────────────────────  │
  │  (repeat per item)         │
  ├────────────────────────────┤
  │  Total: $XX.XX             │
  │  [ Place Order ]           │  ← ElevatedButton (disabled during OrderPlacing)
  └────────────────────────────┘
  ```
- `BlocProvider.value` passes existing `CartCubit` and `OrderCubit` into the sheet
- On **Place Order** tap:
  - `OrderCubit.placeOrder(items, total)` → POST /order/
  - `OrderPlacing`: button shows `CircularProgressIndicator`
  - `OrderSuccess`: close sheet → show snackbar "Order placed!" → `HomePage` switches to Orders tab (index 1)
  - `OrderError`: show error snackbar, sheet stays open

### Orders Tab

- `initState`: `OrderCubit.loadOrders()` → GET /order/
- `BlocBuilder` renders:
  - `OrderLoading`: `CircularProgressIndicator`
  - `OrderLoaded`: `ListView` of `_OrderCard` widgets
  - `OrderError`: error message + Retry button
- **OrderCard** (matches mockup):
  ```
  ORDER #ORD-{id}    [STATUS BADGE]    [product image]
  $totalAmount
  Placed on {createdAt}
  [ Reorder ]  [ View Details ]        ← if DELIVERED
  [ Track Order ]                      ← if SHIPPED
  ```
  - Status badge colors: `pending`/`processing` = grey, `shipped` = blue, `delivered` = green, `cancelled` = red
  - "Reorder" and "View Details" buttons are UI-only placeholders (no action) — matching mockup style

### Tab navigation

```
index 0: Home (DiscoverTab)
index 1: Orders (OrdersTab)   ← NEW
index 2: Profile (ProfileTab)
```

`HomePage` wraps its body with a `BlocListener<OrderCubit, OrderState>`. On `OrderSuccess`, the listener sets `_currentIndex = 1` directly — no prop drilling or callbacks needed.

---

## Service Locator additions

```dart
// Datasources
getIt.registerLazySingleton<CartLocalDatasource>(() => CartLocalDatasource());
getIt.registerLazySingleton<OrderRemoteDatasource>(() => OrderRemoteDatasource(getIt()));

// Repositories
getIt.registerLazySingleton<ICartRepository>(() => CartRepositoryImpl(getIt()));
getIt.registerLazySingleton<IOrderRepository>(() => OrderRepositoryImpl(getIt()));

// Use cases
getIt.registerFactory<AddToCartUseCase>(() => AddToCartUseCase(getIt()));
getIt.registerFactory<GetCartUseCase>(() => GetCartUseCase(getIt()));
getIt.registerFactory<RemoveFromCartUseCase>(() => RemoveFromCartUseCase(getIt()));
getIt.registerFactory<PlaceOrderUseCase>(() => PlaceOrderUseCase(getIt()));
getIt.registerFactory<GetOrdersUseCase>(() => GetOrdersUseCase(getIt()));

// Cubits
getIt.registerFactory<CartCubit>(() => CartCubit(getIt(), getIt(), getIt()));
getIt.registerFactory<OrderCubit>(() => OrderCubit(getIt(), getIt()));
```

---

## Unit Tests

Target: maintain >70% coverage in `test/features/`.

| File | Tests |
|------|-------|
| `cart_cubit_test.dart` | initial state, addItem emits CartLoaded, removeItem updates list, clear empties cart |
| `order_cubit_test.dart` | initial state, loadOrders: [Loading→Loaded], loadOrders: [Loading→Error], placeOrder: [Placing→Success], placeOrder: [Placing→Error] |
| `add_to_cart_usecase_test.dart` | delegates to repository, returns Success |
| `place_order_usecase_test.dart` | delegates to repository, returns Success/Failure |

---

## Docs Update

Update `docs/architecture.html`:
- Add `features/order/` section to the architecture diagram and file tables
- Add CartCubit and OrderCubit state flows
- Note: `shippingAddress` and `paymentMethod` are hardcoded in this version
