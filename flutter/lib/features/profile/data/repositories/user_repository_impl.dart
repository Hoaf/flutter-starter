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
