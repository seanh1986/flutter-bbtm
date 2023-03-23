import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state (non-authorized)
class AuthStateUninitializd extends AuthState {}

// User is logged in
class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  AuthStateLoggedIn(this.authUser);

  @override
  List<Object> get props => [AuthState];

  @override
  String toString() => 'LoggedInAuthState { $authUser }';
}

// User is logged out
class AuthStateLoggedOut extends AuthState {}

// Login in progress
class AuthStateLoggingIn extends AuthState {}

// Logout in progress
class AuthStateLoggingOut extends AuthState {}
