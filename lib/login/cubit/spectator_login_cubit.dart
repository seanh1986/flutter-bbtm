import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'spectator_login_state.dart';

class SpectatorLoginCubit extends Cubit<SpectatorLoginState> {
  SpectatorLoginCubit(this._authenticationRepository)
      : super(const SpectatorLoginState()) {
    spectatorSignInSubmitted();
  }

  final AuthenticationRepository _authenticationRepository;

  String _getEmail() {
    return User.createSpectatorLogin();
  }

// Fake PW: naf1234!
  String _getPassword() {
    return "naf1234!";
  }

  Future<void> spectatorSignInSubmitted() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    // First try login
    bool success = await _tryLogin();
    if (!success) {
      success = await _trySignUp();
    }

    if (success) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      return;
    } else {
      emit(
        state.copyWith(
          errorMessage: "Spectator Login Failed",
          status: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<bool> _tryLogin() async {
    String email = _getEmail();
    String password = _getPassword();
    print("Spectator Login: Try Login {" + email + "," + password + "}");
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on LogInWithEmailAndPasswordFailure catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySignUp() async {
    String email = _getEmail();
    String password = _getPassword();
    print("Naf NameLogin: Try Signup {" + email + "," + password + "}");
    try {
      await _authenticationRepository.signUp(
        email: email,
        nafName: state.nafName,
        password: password,
      );
      return true;
    } on SignUpWithEmailAndPasswordFailure catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
