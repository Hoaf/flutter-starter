import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getProfile;
  final LogoutUseCase _logout;

  ProfileCubit(this._getProfile, this._logout) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    switch (result) {
      case Success(:final value):
        emit(ProfileLoaded(user: value));
      case Failure(:final exception):
        emit(ProfileError(message: exception));
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const ProfileLoggedOut());
  }
}
