import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class AppStartLoginState extends LoginState {}

class LoadingLoginState extends LoginState {}

class FailedLoginState extends LoginState {}

class SuccessLoginState extends LoginState {}
