import 'package:flutter_demo/domain/repositories/auth_repository_interface.dart';
import 'package:injectable/injectable.dart';

abstract class IAuthUseCase {
  void setSecretKey(String secretKey);
  Future<String?> getSecretKey();
}

@Injectable(as: IAuthUseCase)
class AuthUseCase extends IAuthUseCase {

  final IAuthRepository _authRepo;

  AuthUseCase(this._authRepo);

  @override
  void setSecretKey(String secretKey) =>
      _authRepo.setSecretKey(secretKey);

  @override
  Future<String?> getSecretKey() =>
      _authRepo.getSecretKey();
}