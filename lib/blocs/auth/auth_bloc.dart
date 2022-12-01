import 'dart:async';
import 'package:bbnaf/blocs/auth/auth_event.dart';
import 'package:bbnaf/blocs/auth/auth_state.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository aRepo})
      : _authRepository = aRepo,
        super(AppStartAuthState());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AppStartedAuthEvent) {
      yield* _mapAppStartedToState();
    } else if (event is OrganizerLoggedInAuthEvent) {
      yield* _mapOrganizerLoggedInToState(event);
    } else if (event is ParticipantLoggedInAuthEvent) {
      yield* _mapParticipantLoggedInToState(event);
    } else if (event is CaptainLoggedInAuthEvent) {
      yield* _mapCaptainLoggedInToState(event);
    } else if (event is LoggedOutAuthEvent) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final String? nafName = _authRepository.getUserDisplayName();
        if (nafName != null) {
          yield ParticipantAuthState(nafName);
        } else {
          yield GuestAuthState();
        }
      } else {
        yield AppStartAuthState();
      }
    } catch (_) {
      yield AppStartAuthState();
    }
  }

  Stream<AuthState> _mapOrganizerLoggedInToState(
      OrganizerLoggedInAuthEvent event) async* {
    print("AuthBloc: _mapLoggedInToState: Organizer");
    String? nafName = _authRepository.getUserDisplayName();
    String? email = _authRepository.getUserEmail();
    if (nafName != null && email != null) {
      yield OrganizerAuthState(nafName, email);
    } else {
      yield GuestAuthState();
    }
  }

  Stream<AuthState> _mapParticipantLoggedInToState(
      ParticipantLoggedInAuthEvent event) async* {
    print("AuthBloc: _mapLoggedInToState: Participant");
    String? nafName = _authRepository.getUserDisplayName();
    if (nafName != null) {
      yield ParticipantAuthState(nafName);
    } else {
      yield GuestAuthState();
    }
  }

  Stream<AuthState> _mapCaptainLoggedInToState(
      CaptainLoggedInAuthEvent event) async* {
    print("AuthBloc: _mapLoggedInToState: Captain");
    String? nafName = _authRepository.getUserDisplayName();
    String? squadName = "";
    //_authRepository.getUserDisplayName(); // TODO: Get Squad Name??
    if (nafName != null) {
      yield CaptainAuthState(nafName, squadName);
    } else {
      yield GuestAuthState();
    }
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    print("AuthBloc: _mapLoggedOutToState");
    yield GuestAuthState();
  }

  @override
  Future<void> close() {
    print("AuthBloc: close");
    return super.close();
  }
}
