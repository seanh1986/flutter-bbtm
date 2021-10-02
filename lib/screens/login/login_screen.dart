import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/screens/tournament_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  late LoginBloc _loginBloc;
  late AuthBloc _authBloc;

  // bool _enableEditing = true;

  TextEditingController nameController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _loginBloc = BlocProvider.of<LoginBloc>(context);
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
          if (state is AuthUserState) {
            return TournamentListPage();
          } else if (state is GuestAuthState) {
            return TournamentListPage();
          } else {
            return _ScreenUI(context);
          }
        });
  }

  Widget _ScreenUI(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (context, state) {
          if (state is SuccessLoginState) {
            _authBloc.add(LoggedInAuthEvent());
          } else if (state is FailedLoginState) {
            _authBloc.add(LoggedInAuthEvent());
          }

          bool processingLogin = state is LoadingLoginState;
          return Stack(
            children: <Widget>[
              Image.asset(
                './assets/images/background/background_football_field.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Scaffold(
                body: Center(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: ListView(
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Bloodbowl Tournament Manager',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30),
                              )),
                          // Container(
                          //     alignment: Alignment.center,
                          //     padding: EdgeInsets.all(10),
                          //     child: Text(
                          //       'Sign in',
                          //       style: TextStyle(fontSize: 20),
                          //     )),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              enableInteractiveSelection:
                                  processingLogin, // _enableEditing,
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Naf Name',
                              ),
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          //   child: TextField(
                          //     obscureText: true,
                          //     controller: passwordController,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       labelText: 'Password',
                          //     ),
                          //   ),
                          // ),
                          // TextButton(
                          //   style: TextButton.styleFrom(primary: Colors.blue),
                          //   onPressed: () {
                          //     //forgot password screen
                          //   },
                          //   child: Text('Forgot Password'),
                          // ),
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
                                  processSignIn(nameController.text);
                                  // setState(() {
                                  //   _enableEditing = false;
                                  // });
                                },
                              )),
                          // Container(
                          //     child: Row(
                          //   children: <Widget>[
                          //     Text('Does not have account?'),
                          //     TextButton(
                          //       style: TextButton.styleFrom(
                          //           textStyle: TextStyle(color: Colors.blue)),
                          //       child: Text(
                          //         'Sign in',
                          //         style: TextStyle(fontSize: 20),
                          //       ),
                          //       onPressed: () {
                          //         //signup screen
                          //       },
                          //     )
                          //   ],
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          // ))
                        ],
                      )),
                ),
              )
            ],
          );
        });
  }

  void processSignIn(String nafName) {
    _loginBloc.add(new LoginWithNafNameEvent(nafName: nafName));
  }
}
