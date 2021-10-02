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
    } else if (event is LoggedInAuthEvent) {
      yield* _mapLoggedInToState(event);
    } else if (event is LoggedOutAuthEvent) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final String? displayName = _authRepository.getUserDisplayName();
        if (displayName != null) {
          yield AuthUserState(displayName);
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

  Stream<AuthState> _mapLoggedInToState(LoggedInAuthEvent event) async* {
    print("AuthBloc: _mapLoggedInToState");
    String? nafName = _authRepository.getUserDisplayName();
    if (nafName != null) {
      yield AuthUserState(nafName);
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
