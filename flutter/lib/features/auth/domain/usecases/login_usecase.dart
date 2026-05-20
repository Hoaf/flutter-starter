import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final IAuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<Result<UserEntity, String>> call(String username, String password) =>
      _repo.login(username, password);
}
