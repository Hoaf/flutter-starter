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
