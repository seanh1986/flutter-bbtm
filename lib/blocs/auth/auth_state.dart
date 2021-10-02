import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AppStartAuthState extends AuthState {}

// Guest that can only view
class GuestAuthState extends AuthState {}

class AuthUserState extends AuthState {
  final String nafName;

  AuthUserState(this.nafName);

  @override
  List<Object> get props => [nafName];

  @override
  String toString() => 'Authenticated { nafName: $nafName }';
}

// // User that can edit their own match reports
// class UserAuthState extends AuthenticatedUser {
//   UserAuthState(String nafName) : super(nafName);
// }

// // User that can edit their squad's match reports
// class UserCaptainAuthState extends AuthenticatedUser {
//   UserCaptainAuthState(String nafName) : super(nafName);
// }

// // Tournament admin
// class AdminAuthState extends AuthenticatedUser {
//   AdminAuthState(String nafName) : super(nafName);
// }
