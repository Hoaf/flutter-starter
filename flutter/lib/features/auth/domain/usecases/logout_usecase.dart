import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final IAuthRepository _repo;
  const LogoutUseCase(this._repo);

  Future<Result<void, String>> call() => _repo.logout();
}
