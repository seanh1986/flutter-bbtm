import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/auth/auth_bloc.dart';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/repos/auth/firebase_auth_repo.dart';
import 'package:bbnaf/screens/tournament_list/tournament_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginOrganizerPage extends StatefulWidget {
  @override
  _LoginOrganizerPage createState() => _LoginOrganizerPage();
}

class _LoginOrganizerPage extends State<LoginOrganizerPage> {
  AuthRepository _authRepo = FirebaseAuthRepository();

  late AuthBloc _authBloc;

  final String keyNafName = "nafName";

  AuthUser _authUser = AuthUser();

  List<UserFormField> _additionalFields = [];

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _additionalFields
        .add(new UserFormField(keyName: keyNafName, displayName: "NAF Name"));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Bloodbowl Tournament Manager',
      logo: AssetImage('assets/images/logos/amorical_logo.png'),
      additionalSignupFields: _additionalFields,
      userValidator: (value) {
        if (!value!.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      loginAfterSignUp: true,
      navigateBackAfterRecovery: true,
      onSignup: _signupUser,
      onLogin: _tryLoginUser,
      hideForgotPasswordButton: true,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        debugPrint('onSubmitAnimationCompleted');

        _authBloc.add(new LoggedInAuthEvent(authUser: _authUser));

        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => TournamentListPage(
        //     authUser: _authUser,
        //   ),
        // ));
      },
    );
  }

  Future<String?> _tryLoginUser(LoginData data) async {
    debugPrint('Email: ${data.name}, Password: ${data.password}');

    String email = data.name;
    String password = data.password;

    _authUser = await _authRepo.signInWithCredentials(email, password);

    return _authUser.error;
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup info');
    debugPrint('Name: ${data.name}');
    debugPrint('Password: ${data.password}');

    data.additionalSignupData?.forEach((key, value) {
      debugPrint('$key: $value');
    });

    String? optionalNafName = data.additionalSignupData?[keyNafName];

    if (data.name == null || data.password == null || optionalNafName == null) {
      return null;
    }

    String email = data.name.toString();
    String password = data.password.toString();
    String nafName = optionalNafName.toString();

    _authUser = await _authRepo.signUp(
        nafName: nafName, email: email, password: password);

    return _authUser.error;
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Email: $name');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }
}
