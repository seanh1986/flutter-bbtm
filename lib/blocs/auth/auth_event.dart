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

class OrganizerLoggedInAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedIn_Organizer';
}

class ParticipantLoggedInAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedIn_Participant';
}

class CaptainLoggedInAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedIn_Captain';
}

class LoggedOutAuthEvent extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}
