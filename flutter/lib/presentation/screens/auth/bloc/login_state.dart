import 'package:flutter/material.dart';

@immutable
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginFailureWithNetworkState extends LoginState {}

class ValidationFailedState extends LoginState {
  final bool isEmailError;
  final bool isPasswordError;
  final bool isProducerError;
  final String errorMesssage;

  ValidationFailedState({required this.isEmailError, required this.isPasswordError, required this.isProducerError, required this.errorMesssage});
}

class IncorrectLoginCredentialsState extends LoginState {}

class IncorrectLoginCredentialsWithBiometricState extends LoginState {}

class IncorrectLoginCredentialsTooMuchState extends LoginState {}

class UserDeactivatedState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessfulState extends LoginState {
  final String? producerId;
  LoginSuccessfulState({required this.producerId});
}

class LoginSomeErrorState extends LoginState {}

class CheckBiometricSupportState extends LoginState {
  final List<String> enrolledBiometrics;

  CheckBiometricSupportState({required this.enrolledBiometrics});
}

class LoginWithBiometricLockoutState extends LoginState {
  final String errorMessage;
  LoginWithBiometricLockoutState({required this.errorMessage});
}


class BiometricPermissionDenyState extends LoginState {}

class DisabledBiometricAppSettingsState extends LoginState {}

