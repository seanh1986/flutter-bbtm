import 'package:bbnaf/screens/login/login_screen_participant.dart';
import 'package:bbnaf/screens/login/widget_login_header.dart';
import 'package:flutter/material.dart';
import 'login_screen_organizer.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          './assets/images/background/background_football_field.png',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
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
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20),
                    LoginScreenHeader(showBackButton: false),
                    SizedBox(height: 20),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginOrganizerPage()));
                          },
                        )),
                    SizedBox(height: 20),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginParticipantPage()));
                          },
                        )),
                    SizedBox(height: 20),
                  ],
                )),
          ),
        ))
      ],
    );
  }
}
