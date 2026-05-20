import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserProfileUseCase {
  final IUserRepository _repo;
  const GetUserProfileUseCase(this._repo);

  Future<Result<UserEntity, String>> call() => _repo.getProfile();
}
