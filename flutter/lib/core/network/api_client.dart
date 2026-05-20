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
