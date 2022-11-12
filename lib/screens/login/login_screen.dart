import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/screens/login/login_screen_participant.dart';
import 'package:bbnaf/screens/tournament_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_screen_organizer.dart';

enum LoginPageState { LandingPage, OrganizerLogin, ParticipantLogin }

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  LoginPageState _state = LoginPageState.LandingPage;

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case LoginPageState.OrganizerLogin:
        return LoginOrganizerPage();
      case LoginPageState.ParticipantLogin:
        return LoginParticipantPage();
      case LoginPageState.LandingPage:
      default:
        return _landingPage();
    }
  }

  Widget _landingPage() {
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
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          child: Text('Organizer'),
                          onPressed: () {
                            setState(() {
                              _state = LoginPageState.OrganizerLogin;
                            });
                          },
                        )),
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          child: Text('Participant'),
                          onPressed: () {
                            setState(() {
                              _state = LoginPageState.ParticipantLogin;
                            });
                          },
                        )),
                  ],
                )),
          ),
        )
      ],
    );
  }
}
