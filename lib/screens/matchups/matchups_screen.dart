import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/screens/matchups/matchups_coaches_screen.dart';
import 'package:bbnaf/screens/matchups/matchups_squad_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchupsPage extends StatefulWidget {
  MatchupsPage({Key? key}) : super(key: key);

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
  late User _user;

  late MatchupSubScreens _subScreen;

  bool refreshSubScreen = true;

  List<MatchupSubScreens> _subScreensAllowed = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initSubScreen() {
    bool allowMyMatchup = false;
    bool allowMySquad = false;

    String nafName = _user.getNafName();

    Coach? coach = _tournament.getCoach(nafName);
    if (coach != null && coach.active) {
      allowMyMatchup = true;
    }

    Squad? squad = _tournament.getCoachSquad(nafName);
    if (squad != null && squad.isActive(_tournament)) {
      allowMySquad = true;
    }

    _subScreensAllowed.clear();
    if (allowMyMatchup) {
      _subScreensAllowed.add(MatchupSubScreens.MY_MATCHUP);
    }
    if (allowMySquad) {
      _subScreensAllowed.add(MatchupSubScreens.MY_SQUAD);
    }
    if (_tournament.useSquadVsSquad()) {
      _subScreensAllowed.add(MatchupSubScreens.SQUAD_MATCHUPS);
    }
    _subScreensAllowed.add(MatchupSubScreens.COACH_MATCHUPS);

    if (refreshSubScreen) {
      if (allowMyMatchup) {
        _subScreen = MatchupSubScreens.MY_MATCHUP;
      } else if (_tournament.useSquadVsSquad()) {
        _subScreen = MatchupSubScreens.SQUAD_MATCHUPS;
      } else {
        _subScreen = MatchupSubScreens.COACH_MATCHUPS;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    _initSubScreen();

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
    final theme = Theme.of(context);

    List<Widget> toggleWidgets = [];

    if (_subScreensAllowed.length > 1) {
      _subScreensAllowed.forEach((element) {
        bool clickable = _subScreen != element;

        toggleWidgets.add(ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          child: Text(element.name.replaceAll("_", " ")),
          onPressed: clickable
              ? () {
                  setState(() {
                    refreshSubScreen = false;
                    _subScreen = element;
                  });
                }
              : null,
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
        if (_tournament.useSquadVsSquad()) {
          return SquadMatchupsPage(
              autoSelectAuthUserMatchup: true, refreshState: true);
        } else {
          return CoachMatchupsPage(
              autoSelectOption: AutoSelectOption.AUTH_USER_SQUAD,
              refreshState: true);
        }
      case MatchupSubScreens.SQUAD_MATCHUPS:
        return SquadMatchupsPage(
            autoSelectAuthUserMatchup: false, refreshState: true);
      case MatchupSubScreens.COACH_MATCHUPS:
        return CoachMatchupsPage(
            autoSelectOption: AutoSelectOption.NONE, refreshState: true);
      case MatchupSubScreens.MY_MATCHUP:
      default:
        return CoachMatchupsPage(
            autoSelectOption: AutoSelectOption.AUTH_USER_MATCHUP,
            refreshState: true);
    }
  }
}
