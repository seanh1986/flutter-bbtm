import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'naf_name_login_state.dart';

class NafNameLoginCubit extends Cubit<NafNameLoginState> {
  NafNameLoginCubit(this._authenticationRepository)
      : super(const NafNameLoginState());

  final AuthenticationRepository _authenticationRepository;

  void nafNameChanged(String nafName) {
    emit(
      state.copyWith(
        nafName: nafName,
        isValid: nafName.trim().isNotEmpty,
      ),
    );
  }

  String _getEmail() {
    return User.createNafNameLogin(state.nafName);
  }

// Fake PW: naf1234!
  String _getPassword() {
    return "naf1234!";
  }

  Future<void> nafNameSignInSubmitted() async {
    if (!state.isValid) return;
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
          errorMessage: "Naf Name Login Failed",
          status: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<bool> _tryLogin() async {
    String email = _getEmail();
    String password = _getPassword();
    print("Naf Name Login: Try Login {" + email + "," + password + "}");
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
