import 'dart:async';
import 'package:bbnaf/blocs/auth/auth_event.dart';
import 'package:bbnaf/blocs/auth/auth_state.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository aRepo})
      : _authRepository = aRepo,
        super(NotLoggedInAuthState());

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
        AuthUser authUser = _authRepository.getAuthUser();
        yield LoggedInAuthState(authUser);
      } else {
        yield NotLoggedInAuthState();
      }
    } catch (_) {
      yield NotLoggedInAuthState();
    }
  }

  Stream<AuthState> _mapLoggedInToState(LoggedInAuthEvent event) async* {
    print("AuthBloc: _mapLoggedInToState: Logged In");
    yield LoggedInAuthState(event.authUser);
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    print("AuthBloc: _mapLoggedOutToState");

    await _authRepository.signOut();

    yield NotLoggedInAuthState();
  }

  @override
  Future<void> close() {
    print("AuthBloc: close");
    return super.close();
  }
}
