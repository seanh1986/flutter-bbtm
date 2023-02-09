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

class LoggedInAuthEvent extends AuthEvent {
  final AuthUser authUser;

  LoggedInAuthEvent({required this.authUser});

  @override
  String toString() =>
      'LoggedIn: ' +
      authUser.user!.email.toString() +
      " - " +
      authUser.nafName!.toString();
}

class LoggedOutAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}
