import 'dart:async';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthRepository _authRepository;

  LoginBloc({required AuthRepository aRepo})
      : _authRepository = aRepo,
        super(LoginState.empty());

  // @override
  // LoginState get initialState => LoginState.empty();

  // @override
  // Stream<LoginState> transform(
  //   Stream<LoginEvent> events,
  //   Stream<LoginState> Function(LoginEvent event) next,
  // ) {
  //   final observableStream = events as Stream<LoginEvent>;
  //   final nonDebounceStream = observableStream.where((event) {
  //     return (event is! EmailChanged && event is! PasswordChanged);
  //   });
  //   final debounceStream = observableStream.where((event) {
  //     return (event is EmailChanged || event is PasswordChanged);
  //   }).debounce(Duration(milliseconds: 300));
  //   return super.transform(nonDebounceStream.mergeWith([debounceStream]), next);
  // }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // if (event is EmailChanged) {
    //   yield* _mapEmailChangedToState(event.email);
    // } else if (event is PasswordChanged) {
    //   yield* _mapPasswordChangedToState(event.password);
    //   // } else if (event is LoginWithGooglePressed) {
    //   //   yield* _mapLoginWithGooglePressedToState();
    //   // }
    // } else
    // if (event is LoginWithCredentialsPressed) {
    //   yield* _mapLoginWithCredentialsPressedToState(
    //     email: event.email,
    //     password: event.password,
    //   );
    // }
    if (event is AppStartedLoginEvent) {
      //TODO: can check cache to pre-populate login
    } else if (event is LoginWithNafName) {
      yield* _mapLoginWithNafNameToState(
        nafName: event.nafName,
      );
    }
  }

  // Stream<LoginState> _mapEmailChangedToState(String email) async* {
  //   yield currentState.update(
  //     isEmailValid: Validators.isValidEmail(email),
  //   );
  // }

  // Stream<LoginState> _mapPasswordChangedToState(String password) async* {
  //   yield currentState.update(
  //     isPasswordValid: Validators.isValidPassword(password),
  //   );
  // }

  // Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
  //   try {
  //     await _authRepository.signInWithGoogle();
  //     yield LoginState.success();
  //   } catch (_) {
  //     yield LoginState.failure();
  //   }
  // }

  // Stream<LoginState> _mapLoginWithCredentialsPressedToState({
  //   required String email,
  //   required String password,
  // }) async* {
  //   yield LoginState.loading();
  //   try {
  //     await _authRepository.signInWithCredentials(email, password);
  //     yield LoginState.success();
  //   } catch (_) {
  //     yield LoginState.failure();
  //   }
  // }

  Stream<LoginState> _mapLoginWithNafNameToState({
    required String nafName,
  }) async* {
    yield LoginState.loading();
    try {
      _authRepository.signIn(nafName);
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }
}
