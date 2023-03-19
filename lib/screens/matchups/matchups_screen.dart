import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/matchups/matchups_coaches_screen.dart';
import 'package:bbnaf/screens/matchups/matchups_squad_screen.dart';
import 'package:flutter/material.dart';

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
  MY_MATCHUP,
  MY_SQUAD,
  SQUAD_MATCHUPS,
  COACH_MATCHUPS,
}

class _MatchupsPage extends State<MatchupsPage> {
  late Tournament _tournament;
  late AuthUser _authUser;

  late MatchupSubScreens _subScreen;

  List<MatchupSubScreens> _subScreensAllowed = [];

  @override
  void initState() {
    super.initState();

    _tournament = widget.tournament;
    _authUser = widget.authUser;

    _initSubScreen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initSubScreen() {
    bool allowMyMatchup = false;
    bool allowMySquad = false;

    if (_authUser.nafName != null) {
      Coach? coach = _tournament.getCoach(_authUser.nafName!);
      if (coach != null && coach.active) {
        allowMyMatchup = true;
      }

      Squad? squad = _tournament.getCoachSquad(_authUser.nafName!);
      if (squad != null && squad.isActive(_tournament)) {
        allowMySquad = true;
      }
    }

    _subScreensAllowed.clear();
    if (allowMyMatchup) {
      _subScreensAllowed.add(MatchupSubScreens.MY_MATCHUP);
    }
    if (allowMySquad) {
      _subScreensAllowed.add(MatchupSubScreens.MY_SQUAD);
    }
    if (_tournament.useSquads() && _tournament.squadRounds.isNotEmpty) {
      _subScreensAllowed.add(MatchupSubScreens.SQUAD_MATCHUPS);
    }
    _subScreensAllowed.add(MatchupSubScreens.COACH_MATCHUPS);

    if (allowMyMatchup) {
      _subScreen = MatchupSubScreens.MY_MATCHUP;
    } else if (_tournament.useSquads() && _tournament.squadRounds.isNotEmpty) {
      _subScreen = MatchupSubScreens.SQUAD_MATCHUPS;
    } else {
      _subScreen = MatchupSubScreens.COACH_MATCHUPS;
    }
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

    if (_subScreensAllowed.length > 1) {
      _subScreensAllowed.forEach((element) {
        toggleWidgets.add(ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text(element.name.replaceAll("_", " ")),
          onPressed: () {
            setState(() {
              _subScreen = element;
            });
          },
        ));

        toggleWidgets.add(SizedBox(width: 10));
      });
    }

    return Container(
        height: toggleWidgets.isNotEmpty ? 60 : 0,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: toggleWidgets));
  }

  Widget? _getSubScreen() {
    switch (_subScreen) {
      case MatchupSubScreens.MY_SQUAD:
        if (_tournament.useSquads() && _tournament.squadRounds.isNotEmpty) {
          return SquadMatchupsPage(
              tournament: _tournament,
              authUser: _authUser,
              autoSelectAuthUserMatchup: true,
              refreshState: true);
        } else {
          return CoachMatchupsPage(
              tournament: _tournament,
              authUser: _authUser,
              autoSelectOption: AutoSelectOption.AUTH_USER_SQUAD,
              refreshState: true);
        }
      case MatchupSubScreens.SQUAD_MATCHUPS:
        return SquadMatchupsPage(
            tournament: _tournament,
            authUser: _authUser,
            autoSelectAuthUserMatchup: false,
            refreshState: true);
      case MatchupSubScreens.COACH_MATCHUPS:
        return CoachMatchupsPage(
            tournament: _tournament,
            authUser: _authUser,
            autoSelectOption: AutoSelectOption.NONE,
            refreshState: true);
      case MatchupSubScreens.MY_MATCHUP:
      default:
        return CoachMatchupsPage(
            tournament: _tournament,
            authUser: _authUser,
            autoSelectOption: AutoSelectOption.AUTH_USER_MATCHUP,
            refreshState: true);
    }
  }
}
