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
