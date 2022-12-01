import 'dart:async';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthRepository _authRepository;

  LoginBloc({required AuthRepository aRepo})
      : _authRepository = aRepo,
        super(AppStartLoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is AppStartedLoginEvent) {
      //TODO: can check cache to pre-populate login
    } else if (event is AttemptLoginWithFirebaseEvent) {
      yield* _mapAttemptLoginWithFirebaseToState(event);
    } else if (event is LoginWithNafNameEvent) {
      yield* _mapLoginWithNafNameToState(
        nafName: event.nafName,
      );
    }
  }

  Stream<LoginState> _mapAttemptLoginWithFirebaseToState(
      AttemptLoginWithFirebaseEvent event) async* {
    yield LoadingLoginState();
    try {
      AuthUser authUser = await _authRepository.signInWithCredentials(
          event.email, event.password);

      if (authUser.user != null) {
        yield SuccessLoginState();
      } else {
        yield FailedLoginState();
      }
    } catch (_) {
      yield FailedLoginState();
    }
  }

  Stream<LoginState> _mapLoginWithNafNameToState({
    required String nafName,
  }) async* {
    yield LoadingLoginState();
    try {
      _authRepository.signIn(nafName);
      yield SuccessLoginState();
    } catch (_) {
      yield FailedLoginState();
    }
  }
}
