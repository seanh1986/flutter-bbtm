import 'dart:async';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthRepository _authRepository;

  LoginBloc({required AuthRepository aRepo})
      : _authRepository = aRepo,
        super(AppStartLoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is AppStartedLoginEvent) {
      //TODO: can check cache to pre-populate login
    } else if (event is LoginWithNafNameEvent) {
      yield* _mapLoginWithNafNameToState(
        nafName: event.nafName,
      );
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
