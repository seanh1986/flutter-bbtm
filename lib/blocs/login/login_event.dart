import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent();

  @override
  List<Object> get props => [];
}

class AppStartedLoginEvent extends LoginEvent {}

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
