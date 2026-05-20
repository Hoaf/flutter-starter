import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Result<UserEntity, String>> login(String username, String password);
  Future<Result<void, String>> logout();
}
