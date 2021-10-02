import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStartedAuthEvent extends AuthEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedInAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedIn';
}

class LoggedOutAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}
