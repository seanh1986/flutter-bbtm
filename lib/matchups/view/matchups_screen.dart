import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/view/matchups_all_squads_screen.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/widgets/toggle_widget/models/toggle_widget_item.dart';
import 'package:bbnaf/widgets/toggle_widget/view/toggle_widget.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<MatchupSubScreens> _getAllowedSubScreen() {
    bool allowMyMatchup = false;
    bool allowMySquad = false;

    List<MatchupSubScreens> subScreensAllowed = [];

    String nafName = _user.getNafName();

    Coach? coach = _tournament.getCoach(nafName);
    if (coach != null && coach.active) {
      allowMyMatchup = true;
    }

    Squad? squad = _tournament.getCoachSquad(nafName);
    if (squad != null && squad.isActive(_tournament)) {
      allowMySquad = true;
    }

    if (allowMyMatchup) {
      subScreensAllowed.add(MatchupSubScreens.MY_MATCHUP);
    }

    if (allowMySquad) {
      subScreensAllowed.add(MatchupSubScreens.MY_SQUAD);
    }

    if (_tournament.useSquadVsSquad()) {
      subScreensAllowed.add(MatchupSubScreens.SQUAD_MATCHUPS);
    }

    subScreensAllowed.add(MatchupSubScreens.COACH_MATCHUPS);

    return subScreensAllowed;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    List<ToggleWidgetItem> items = [];

    List<MatchupSubScreens> subScreensAllowed = _getAllowedSubScreen();

    subScreensAllowed.forEach((subScreen) {
      items.add(ToggleWidgetItem(subScreen.name.replaceAll("_", " "),
          _getSubScreenBuilder(subScreen)));
    });

    return ToggleWidget(items: items);
  }

  WidgetBuilder _getSubScreenBuilder(MatchupSubScreens subScreen) {
    switch (subScreen) {
      case MatchupSubScreens.MY_SQUAD:
        if (_tournament.useSquadVsSquad()) {
          return (context) {
            String nafName = _user.getNafName();
            Squad? squad = _tournament.getCoachSquad(nafName);
            String squadName = squad != null ? squad.name() : "";
            return SquadMatchupsPage(squadName: squadName);
          };
        } else {
          return (context) {
            return CoachMatchupsPage(
                autoSelectOption: AutoSelectOption.AUTH_USER_SQUAD,
                refreshState: true);
          };
        }
      case MatchupSubScreens.SQUAD_MATCHUPS:
        return (context) {
          return AllSquadsMatchupsPage();
        };
      case MatchupSubScreens.COACH_MATCHUPS:
        return (context) {
          return CoachMatchupsPage(
              autoSelectOption: AutoSelectOption.NONE, refreshState: true);
        };
      case MatchupSubScreens.MY_MATCHUP:
      default:
        return (context) {
          return CoachMatchupsPage(
              autoSelectOption: AutoSelectOption.AUTH_USER_MATCHUP,
              refreshState: true);
        };
    }
  }
}
