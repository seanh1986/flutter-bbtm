import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/login/widget_login_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginParticipantPage extends StatefulWidget {
  @override
  _LoginParticipantPage createState() => _LoginParticipantPage();
}

class _LoginParticipantPage extends State<LoginParticipantPage> {
  late AuthBloc _authBloc;

  bool _enableEditing = true;

  TextEditingController nafNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage(
      //         './assets/images/background/background_football_field.png'),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                LoginScreenHeader(
                  showBackButton: true,
                  subTitle: "Participant Login",
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    enableInteractiveSelection: _enableEditing,
                    controller: nafNameController,
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
                        String nafName = nafNameController.text.trim();

                        AuthUser authUser;
                        if (nafName.trim().isEmpty) {
                          authUser = new AuthUser(user: null, error: "");
                        } else {
                          authUser = new AuthUser.nafNameOnly(nafName: nafName);
                        }

                        _authBloc.add(LoggedInAuthEvent(authUser: authUser));

                        setState(() {
                          _enableEditing = false;
                        });
                      },
                    )),
                //   Container(
                //       child: Row(
                //     children: <Widget>[
                //       Text('Does not have account?'),
                //       TextButton(
                //         style: TextButton.styleFrom(
                //             textStyle: TextStyle(color: Colors.blue)),
                //         child: Text(
                //           'Sign in',
                //           style: TextStyle(fontSize: 20),
                //         ),
                //         onPressed: () {
                //           //signup screen
                //         },
                //       )
                //     ],
                //     mainAxisAlignment: MainAxisAlignment.center,
                //   ))
              ],
            )),
      ),
    ));
  }
}
