import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/matchups/matchups_coaches_screen.dart';
import 'package:bbnaf/screens/matchups/matchups_squad_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MatchupsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;

  MatchupsPage({Key? key, required this.tournament, required this.authUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MatchupsPage();
  }
}

enum MatchupSubScreens {
  SQUAD_MATCHUPS,
  COACH_MATCHUPS,
}

class _MatchupsPage extends State<MatchupsPage> {
  late Tournament _tournament;
  late AuthUser _authUser;

  FToast? fToast;

  late MatchupSubScreens subScreen;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast!.init(context);

    _tournament = widget.tournament;
    _authUser = widget.authUser;

    subScreen = _tournament.useSquads
        ? MatchupSubScreens.SQUAD_MATCHUPS
        : MatchupSubScreens.COACH_MATCHUPS;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [
      _toggleButtonsList(context),
      SizedBox(height: 20),
    ];

    Widget? subScreenWidget = _getSubScreen();

    if (subScreenWidget != null) {
      _widgets.add(subScreenWidget);
    }

    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                './assets/images/background/background_football_field.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(children: _widgets),
        ));
  }

  Widget _toggleButtonsList(BuildContext context) {
    List<Widget> toggleWidgets = [];

    MatchupSubScreens.values.forEach((element) {
      toggleWidgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(color: Colors.white),
        ),
        child: Text(element.name.replaceAll("_", " ")),
        onPressed: () {
          setState(() {
            subScreen = element;
          });
        },
      ));

      toggleWidgets.add(SizedBox(width: 10));
    });

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: toggleWidgets));
  }

  Widget? _getSubScreen() {
    switch (subScreen) {
      case MatchupSubScreens.SQUAD_MATCHUPS:
        return SquadMatchupsPage(tournament: _tournament, authUser: _authUser);
      case MatchupSubScreens.COACH_MATCHUPS:
      default:
        return CoachMatchupsPage(tournament: _tournament, authUser: _authUser);
    }
  }
}
