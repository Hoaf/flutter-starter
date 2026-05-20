import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmitEvent>(_onLoginSubmit);
  }

  Future<void> _onLoginSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (event.username.trim().isEmpty || event.password.isEmpty) {
      emit(const LoginFailure(message: 'Please enter your username and password'));
      return;
    }

    emit(const LoginLoading());
    final result = await _loginUseCase(event.username.trim(), event.password);

    switch (result) {
      case Success(:final value):
        emit(LoginSuccess(user: value));
      case Failure(:final exception):
        emit(LoginFailure(message: exception));
    }
  }
}
