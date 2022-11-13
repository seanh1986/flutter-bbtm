import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/screens/login/widget_login_header.dart';
import 'package:bbnaf/screens/tournament_list/tournament_list_screen.dart';
import 'package:bbnaf/utils/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginOrganizerPage extends StatefulWidget {
  @override
  _LoginOrganizerPage createState() => _LoginOrganizerPage();
}

class _LoginOrganizerPage extends State<LoginOrganizerPage> {
  late LoginBloc _loginBloc;
  late AuthBloc _authBloc;

  // bool _enableEditing = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _loginBloc.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        bloc: _authBloc,
        builder: (context, state) {
          // if (state is OrganizerAuthState) {
          //   return TournamentListPage();
          // } else if (state is CaptainAuthState) {
          //   return TournamentListPage();
          // } else if (state is ParticipantAuthState) {
          //   return TournamentListPage();
          // } else if (state is GuestAuthState) {
          //   return TournamentListPage();
          // } else {
          return _screenUI(context);
          // }
        });
  }

  Widget _screenUI(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (context, state) {
          if (state is SuccessLoginState) {
            _authBloc.add(ParticipantLoggedInAuthEvent());
          } else if (state is FailedLoginState) {
            _authBloc.add(ParticipantLoggedInAuthEvent());
          }

          bool processingLogin = state is LoadingLoginState;

          return Scaffold(
              body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    './assets/images/background/background_football_field.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListView(
                        children: <Widget>[
                          LoginScreenHeader(
                              showBackButton: true,
                              subTitle: "Organizer Login"),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              enableInteractiveSelection:
                                  processingLogin, // _enableEditing,
                              controller: emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: TextField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(primary: Colors.blue),
                            onPressed: () {
                              //forgot password screen
                            },
                            child: Text('Forgot Password'),
                          ),
                          Container(
                              height: 50,
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  textStyle: TextStyle(color: Colors.white),
                                ),
                                child: Text('Sign in'),
                                onPressed: () {
                                  processSignIn(emailController.text,
                                      passwordController.text);
                                },
                              )),
                          Container(
                              child: Row(
                            children: <Widget>[
                              Text('Don\'t have account?',
                                  style: TextStyle(fontSize: 20)),
                              TextButton(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(color: Colors.blue)),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () {
                                  //signup screen
                                },
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ))
                        ],
                      ))),
            ),
          ));
        });
  }

  void processSignIn(String email, String password) {
    _loginBloc.add(
        new AttemptLoginWithFirebaseEvent(email: email, password: password));
  }
}
