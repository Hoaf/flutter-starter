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
