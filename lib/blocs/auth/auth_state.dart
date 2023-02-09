import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state (non-authorized)
class NotLoggedInAuthState extends AuthState {}

class LoggedInAuthState extends AuthState {
  final AuthUser authUser;

  LoggedInAuthState(this.authUser);

  @override
  List<Object> get props => [AuthState];

  @override
  String toString() => 'LoggedInAuthState { $authUser }';
}
