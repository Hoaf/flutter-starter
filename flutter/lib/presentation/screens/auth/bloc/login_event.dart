import 'package:flutter/material.dart';

@immutable
abstract class LoginEvent {}

class LoginInitialEvent extends LoginEvent {}

class CheckBiometricSupportEvent extends LoginEvent {}

