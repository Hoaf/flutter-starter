import 'package:flutter_demo/domain/usecases/auth_usecase.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_event.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthUseCase? authUseCase;
  late final IAuthUseCase _authUseCase;

  LoginBloc({this.authUseCase}) : super(LoginInitialState()) {
    _authUseCase = authUseCase ?? GetIt.I<IAuthUseCase>();

    on<CheckBiometricSupportEvent>(_onCheckBiometricSupportEvent);
  }

  void _onCheckBiometricSupportEvent(CheckBiometricSupportEvent event, Emitter<LoginState> emit) async {

  }

}