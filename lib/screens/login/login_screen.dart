import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bbnaf/screens/login/login_screen_participant.dart';
import 'package:bbnaf/screens/login/widget_login_header.dart';
import 'package:flutter/material.dart';
import 'login_screen_organizer.dart';

class LoginPage extends StatefulWidget {
  TournamentInfo tournamentInfo;

  LoginPage(this.tournamentInfo);

  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }

  static dynamic getLogo(
      TournamentInfo tournamentInfo, TournamentRepository tournyRepo) {
    //if (tournamentInfo.logoFileName.isEmpty) {
    return AssetImage('assets/images/logos/amorical_logo.png');
    //}

    // await url = tournyRepo.getFileUrl(tournamentInfo.logoFileName);

    //return NetworkImage("https://fumbbl.com/FUMBBL/Images/Icons/fumbbl.png");

    // return FutureBuilder(
    //   future: tournyRepo.getFileUrl(tournamentInfo.logoFileName),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return const Text(
    //         "Something went wrong",
    //       );
    //     }
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       return Image.network(
    //         snapshot.data.toString(),
    //       );
    //     }
    //     return const Center(child: CircularProgressIndicator());
    //   },
    // );
  }
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
                                    builder: (context) => LoginOrganizerPage(
                                        widget.tournamentInfo)));
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
