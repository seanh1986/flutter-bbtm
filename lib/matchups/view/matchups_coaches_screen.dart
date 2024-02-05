import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

enum AutoSelectOption {
  NONE,
  AUTH_USER_MATCHUP,
  AUTH_USER_SQUAD,
}

class CoachMatchupsPage extends StatefulWidget {
  final AutoSelectOption autoSelectOption;
  final bool refreshState;

  CoachMatchupsPage(
      {Key? key, required this.autoSelectOption, required this.refreshState})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CoachMatchupsPage();
  }
}

class _CoachMatchupsPage extends State<CoachMatchupsPage> {
  late Tournament _tournament;
  late User _user;
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

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    if (_tournament.coachRounds.isNotEmpty) {
      _matchups = List.from(_tournament.coachRounds.last.matches);
    }

    if (_matchups.isEmpty) {
      return _noMatchUpsYet(context);
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
        ? _coachMatchupListUi(context, selectedMatchups)
        : _coachMatchupListUi(context, _matchups);
  }

  void initSelectedMatchupState() {
    _autoSelectOption = widget.autoSelectOption;
    selectedMatchups.clear();
  }

  List<CoachMatchup> findAutoSelectedMatchups() {
    String nafName = _user.getNafName();

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

  Widget _coachMatchupListUi(
      BuildContext context, List<CoachMatchup> matchupsToShow) {
    List<Widget> matchupWidgets = [
      _getRoundTitle(context),
    ];

    matchupsToShow.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
          matchup: m,
          refreshState: widget.refreshState,
        )));

    return SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: matchupWidgets.length,
            itemBuilder: (context, idx) {
              return ListTile(title: matchupWidgets[idx]);
            }));
  }

  Widget _getRoundTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(alignment: WrapAlignment.center, children: [
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Round #" + _tournament.curRoundNumber().toString(),
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium)
        ]),
      ))
    ]);
  }

  Widget _noMatchUpsYet(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        margin: EdgeInsets.fromLTRB(20, 2, 20, 2), // EdgeInsets.all(20),
        width: double.infinity,
        child: Card(
          color: Colors.transparent,
          margin: EdgeInsets.all(10),
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(2),
              child: Text(
                'Matchups not available yet',
                style: theme.textTheme.titleLarge,
              )),
        ));
  }
}
