import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state (non-authorized)
class AppStartAuthState extends AuthState {}

// Guest that can only view
class GuestAuthState extends AuthState {}

// Participant that can edit their own scores
class ParticipantAuthState extends AuthState {
  final String nafName;

  ParticipantAuthState(this.nafName);

  @override
  List<Object> get props => [nafName];

  @override
  String toString() => 'Participant Authenticated { nafName: $nafName }';
}

// Participant that can edit their own scores
class CaptainAuthState extends AuthState {
  final String squadName;
  final String nafName;

  CaptainAuthState(this.squadName, this.nafName);

  @override
  List<Object> get props => [nafName, squadName];

  @override
  String toString() =>
      'Captain Authenticated { nafName: $nafName, squadName: $squadName }';
}

// Tournament admin
class OrganizerAuthState extends AuthState {
  final String nafName;
  final String email;

  OrganizerAuthState(this.nafName, this.email);

  @override
  List<Object> get props => [nafName, email];

  @override
  String toString() =>
      'Organizer Authenticated { nafName: $nafName, email: $email }';
}
