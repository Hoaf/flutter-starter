// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_demo/core/network/api_client.dart' as _i800;
import 'package:flutter_demo/core/storage/token_local_datasource.dart' as _i926;
import 'package:flutter_demo/di/injection_module.dart' as _i269;
import 'package:flutter_demo/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i625;
import 'package:flutter_demo/features/auth/data/repositories/auth_repository_impl.dart'
    as _i347;
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart'
    as _i991;
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart'
    as _i666;
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart'
    as _i913;
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart'
    as _i414;
import 'package:flutter_demo/features/order/data/datasources/cart_local_datasource.dart'
    as _i530;
import 'package:flutter_demo/features/order/data/datasources/order_remote_datasource.dart'
    as _i800;
import 'package:flutter_demo/features/order/data/repositories/cart_repository_impl.dart'
    as _i845;
import 'package:flutter_demo/features/order/data/repositories/order_repository_impl.dart'
    as _i836;
import 'package:flutter_demo/features/order/domain/repositories/i_cart_repository.dart'
    as _i237;
import 'package:flutter_demo/features/order/domain/repositories/i_order_repository.dart'
    as _i633;
import 'package:flutter_demo/features/order/domain/usecases/add_to_cart_usecase.dart'
    as _i1062;
import 'package:flutter_demo/features/order/domain/usecases/clear_cart_usecase.dart'
    as _i35;
import 'package:flutter_demo/features/order/domain/usecases/get_cart_usecase.dart'
    as _i398;
import 'package:flutter_demo/features/order/domain/usecases/get_orders_usecase.dart'
    as _i769;
import 'package:flutter_demo/features/order/domain/usecases/place_order_usecase.dart'
    as _i876;
import 'package:flutter_demo/features/order/domain/usecases/remove_from_cart_usecase.dart'
    as _i313;
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart'
    as _i172;
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart'
    as _i243;
import 'package:flutter_demo/features/product/data/datasources/product_remote_datasource.dart'
    as _i478;
import 'package:flutter_demo/features/product/data/repositories/product_repository_impl.dart'
    as _i344;
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart'
    as _i877;
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart'
    as _i631;
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart'
    as _i932;
import 'package:flutter_demo/features/profile/data/datasources/user_local_datasource.dart'
    as _i413;
import 'package:flutter_demo/features/profile/data/datasources/user_remote_datasource.dart'
    as _i73;
import 'package:flutter_demo/features/profile/data/repositories/user_repository_impl.dart'
    as _i1050;
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart'
    as _i455;
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart'
    as _i990;
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart'
    as _i560;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => injectionModule.secureStorage,
    );
    gh.lazySingleton<_i530.CartLocalDatasource>(
      () => _i530.CartLocalDatasource(),
    );
    gh.lazySingleton<_i413.UserLocalDatasource>(
      () => _i413.UserLocalDatasource(),
    );
    gh.lazySingleton<_i237.ICartRepository>(
      () => _i845.CartRepositoryImpl(gh<_i530.CartLocalDatasource>()),
    );
    gh.lazySingleton<_i926.TokenLocalDatasource>(
      () => _i926.TokenLocalDatasource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i1062.AddToCartUseCase>(
      () => _i1062.AddToCartUseCase(gh<_i237.ICartRepository>()),
    );
    gh.factory<_i35.ClearCartUseCase>(
      () => _i35.ClearCartUseCase(gh<_i237.ICartRepository>()),
    );
    gh.factory<_i398.GetCartUseCase>(
      () => _i398.GetCartUseCase(gh<_i237.ICartRepository>()),
    );
    gh.factory<_i313.RemoveFromCartUseCase>(
      () => _i313.RemoveFromCartUseCase(gh<_i237.ICartRepository>()),
    );
    gh.lazySingleton<_i800.ApiClient>(
      () => _i800.ApiClient(gh<_i926.TokenLocalDatasource>()),
    );
    gh.factory<_i172.CartCubit>(
      () => _i172.CartCubit(
        gh<_i1062.AddToCartUseCase>(),
        gh<_i313.RemoveFromCartUseCase>(),
        gh<_i398.GetCartUseCase>(),
      ),
    );
    gh.lazySingleton<_i625.AuthRemoteDatasource>(
      () => _i625.AuthRemoteDatasource(gh<_i800.ApiClient>()),
    );
    gh.lazySingleton<_i800.OrderRemoteDatasource>(
      () => _i800.OrderRemoteDatasource(gh<_i800.ApiClient>()),
    );
    gh.lazySingleton<_i478.ProductRemoteDatasource>(
      () => _i478.ProductRemoteDatasource(gh<_i800.ApiClient>()),
    );
    gh.lazySingleton<_i73.UserRemoteDatasource>(
      () => _i73.UserRemoteDatasource(gh<_i800.ApiClient>()),
    );
    gh.lazySingleton<_i877.IProductRepository>(
      () => _i344.ProductRepositoryImpl(gh<_i478.ProductRemoteDatasource>()),
    );
    gh.lazySingleton<_i991.IAuthRepository>(
      () => _i347.AuthRepositoryImpl(
        gh<_i625.AuthRemoteDatasource>(),
        gh<_i926.TokenLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i455.IUserRepository>(
      () => _i1050.UserRepositoryImpl(
        gh<_i73.UserRemoteDatasource>(),
        gh<_i413.UserLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i633.IOrderRepository>(
      () => _i836.OrderRepositoryImpl(gh<_i800.OrderRemoteDatasource>()),
    );
    gh.factory<_i666.LoginUseCase>(
      () => _i666.LoginUseCase(gh<_i991.IAuthRepository>()),
    );
    gh.factory<_i913.LogoutUseCase>(
      () => _i913.LogoutUseCase(gh<_i991.IAuthRepository>()),
    );
    gh.factory<_i631.GetProductsUseCase>(
      () => _i631.GetProductsUseCase(gh<_i877.IProductRepository>()),
    );
    gh.factory<_i769.GetOrdersUseCase>(
      () => _i769.GetOrdersUseCase(gh<_i633.IOrderRepository>()),
    );
    gh.factory<_i876.PlaceOrderUseCase>(
      () => _i876.PlaceOrderUseCase(gh<_i633.IOrderRepository>()),
    );
    gh.factory<_i990.GetUserProfileUseCase>(
      () => _i990.GetUserProfileUseCase(gh<_i455.IUserRepository>()),
    );
    gh.factory<_i560.ProfileCubit>(
      () => _i560.ProfileCubit(
        gh<_i990.GetUserProfileUseCase>(),
        gh<_i913.LogoutUseCase>(),
      ),
    );
    gh.factory<_i414.LoginBloc>(
      () => _i414.LoginBloc(gh<_i666.LoginUseCase>()),
    );
    gh.factory<_i932.ProductCubit>(
      () => _i932.ProductCubit(gh<_i631.GetProductsUseCase>()),
    );
    gh.factory<_i243.OrderCubit>(
      () => _i243.OrderCubit(
        gh<_i876.PlaceOrderUseCase>(),
        gh<_i769.GetOrdersUseCase>(),
        gh<_i35.ClearCartUseCase>(),
      ),
    );
    return this;
  }
}

class _$InjectionModule extends _i269.InjectionModule {}
