import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent();

  @override
  List<Object> get props => [];
}

class AppStartedLoginEvent extends LoginEvent {}

class AttemptLoginWithFirebaseEvent extends LoginEvent {
  final String email;
  final String password;

  AttemptLoginWithFirebaseEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'AttemptLoginWithFirebaseEvent { email: $email }';
  }
}

class LoginWithNafNameEvent extends LoginEvent {
  final String nafName;

  LoginWithNafNameEvent({required this.nafName});

  @override
  List<Object> get props => [nafName];

  @override
  String toString() {
    return 'LoginWithNafName { nafName: $nafName }';
  }
}
