import 'package:bbnaf/repos/auth/auth_user.dart';
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

class LogInAuthEvent extends AuthEvent {
  final AuthUser authUser;

  LogInAuthEvent({required this.authUser});

  @override
  String toString() =>
      'LoggedIn: ' +
      authUser.user!.email.toString() +
      " - " +
      authUser.getNafName().toString();
}

class LogOutAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}
