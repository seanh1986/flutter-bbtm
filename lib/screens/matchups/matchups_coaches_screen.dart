import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/matchups/matchup_coach_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

enum AutoSelectOption {
  NONE,
  AUTH_USER_MATCHUP,
  AUTH_USER_SQUAD,
}

class CoachMatchupsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;
  final AutoSelectOption autoSelectOption;
  final bool refreshState;

  CoachMatchupsPage(
      {Key? key,
      required this.tournament,
      required this.authUser,
      required this.autoSelectOption,
      required this.refreshState})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CoachMatchupsPage();
  }
}

class _CoachMatchupsPage extends State<CoachMatchupsPage> {
  late Tournament _tournament;
  late AuthUser _authUser;
  List<CoachMatchup> _matchups = [];

  late AutoSelectOption _autoSelectOption;
  List<CoachMatchup> selectedMatchups = [];

  FToast? fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast!.init(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshState() {
    _tournament = widget.tournament;
    _authUser = widget.authUser;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refreshState) {
      _refreshState();
    }

    if (_tournament.coachRounds.isNotEmpty) {
      _matchups = List.from(_tournament.coachRounds.last.matches);
    }

    if (_matchups.isEmpty) {
      return _noMatchUpsYet();
    }

    if (widget.refreshState) {
      initSelectedMatchupState();
    }

    // Allow for auto selection if not already selected
    if (selectedMatchups.isEmpty &&
        _autoSelectOption != AutoSelectOption.NONE) {
      selectedMatchups = findAutoSelectedMatchups();
    }

    return selectedMatchups.isNotEmpty
        ? _coachMatchupListUi(selectedMatchups)
        : _coachMatchupListUi(_matchups);
  }

  void initSelectedMatchupState() {
    _autoSelectOption = widget.autoSelectOption;
    selectedMatchups.clear();
  }

  List<CoachMatchup> findAutoSelectedMatchups() {
    String nafName = _authUser.getNafName();

    Coach? coach = _tournament.getCoach(nafName);
    if (coach == null) {
      return [];
    }

    switch (_autoSelectOption) {
      case AutoSelectOption.AUTH_USER_MATCHUP:
        CoachMatchup? match = _matchups.firstWhereOrNull(
            (element) => element.hasParticipantName(coach.nafName));
        return match != null ? [match] : [];
      case AutoSelectOption.AUTH_USER_SQUAD:
        return _matchups.where((m) {
          Squad? squad_1 = _tournament.getCoachSquad(m.homeNafName);
          if (squad_1 != null && squad_1.name() == coach.squadName) {
            return true;
          }

          Squad? squad_2 = _tournament.getCoachSquad(m.awayNafName);
          if (squad_2 != null && squad_2.name() == coach.squadName) {
            return true;
          }

          return false;
        }).toList();
      case AutoSelectOption.NONE:
      default:
        return [];
    }
  }

  // Widget _selectedCoachMatchupUi(CoachMatchup m) {
  //   List<Widget> matchupWidgets = [
  //     SizedBox(height: 2),
  //     _getRoundTitle(),
  //     SizedBox(height: 10),
  //   ];

  //   matchupWidgets.add(MatchupCoachWidget(
  //     tournament: _tournament,
  //     authUser: _authUser,
  //     matchup: m,
  //     refreshState: widget.refreshState,
  //   ));

  //   return Expanded(
  //       child: ListView(
  //           children: matchupWidgets,
  //           shrinkWrap: true,
  //           scrollDirection: Axis.vertical));
  // }

  Widget _coachMatchupListUi(List<CoachMatchup> matchupsToShow) {
    List<Widget> matchupWidgets = [
      SizedBox(height: 2),
      _getRoundTitle(),
      SizedBox(height: 10)
    ];

    matchupsToShow.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
          tournament: _tournament,
          authUser: _authUser,
          matchup: m,
          refreshState: widget.refreshState,
        )));

    return Expanded(
        child: ListView(
            children: matchupWidgets,
            shrinkWrap: true,
            scrollDirection: Axis.vertical));
  }

  Widget _getRoundTitle() {
    return Wrap(alignment: WrapAlignment.center, children: [
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Round #" + _tournament.curRoundNumber().toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ]),
      ))
    ]);
  }

  Widget _noMatchUpsYet() {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 2, 20, 2), // EdgeInsets.all(20),
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.all(10),
          child: Container(
              padding: EdgeInsets.all(2),
              child: Text(
                'Matchups not available yet',
                style: TextStyle(fontSize: 20),
              )),
        ));
  }
}
