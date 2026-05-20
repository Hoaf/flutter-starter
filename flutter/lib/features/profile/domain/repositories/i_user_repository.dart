import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<Result<UserEntity, String>> getProfile();
}
