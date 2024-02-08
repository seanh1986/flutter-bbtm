import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

class SquadMatchupsPage extends StatefulWidget {
  final bool autoSelectAuthUserMatchup;
  final bool refreshState;

  SquadMatchupsPage(
      {Key? key,
      required this.autoSelectAuthUserMatchup,
      required this.refreshState})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SquadMatchupsPage();
  }
}

class _SquadMatchupsPage extends State<SquadMatchupsPage> {
  late Tournament _tournament;
  late User _user;
  List<SquadMatchup> _matchups = [];

  late bool _autoSelectAuthUserMatchup;
  SquadMatchup? selectedMatchup;

  bool _reset = true;

  int? _roundIdx;

  FToast? fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast!.init(context);

    _reset = true;
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

    if (_roundIdx == null) {
      _roundIdx = _tournament.curRoundIdx();
    }

    if (_tournament.squadRounds.isNotEmpty) {
      _matchups = List.from(_tournament.squadRounds[_roundIdx!].matches);
    }

    if (_matchups.isEmpty) {
      return _noMatchUpsYet();
    }

    if (_reset) {
      _autoSelectAuthUserMatchup = widget.autoSelectAuthUserMatchup;
      // Allow for auto selection if not already selected
      if (_autoSelectAuthUserMatchup) {
        selectedMatchup = findAutoSelectedMatchup();
      }
    }

    // so that when it reloads, it will reset
    // This will get reset if setState is called again
    _reset = true;

    bool selectMatchup = selectedMatchup != null && _autoSelectAuthUserMatchup;

    return selectMatchup
        ? _selectedSquadMatchupUi(context, selectedMatchup!)
        : _squadMatchupListUi();
  }

  SquadMatchup? findAutoSelectedMatchup() {
    String nafName = _user.getNafName();

    if (!_autoSelectAuthUserMatchup || nafName.isEmpty) {
      return null;
    }

    Squad? squad = _tournament.getCoachSquad(nafName);
    if (squad == null) {
      return null;
    }

    return _matchups
        .firstWhereOrNull((element) => element.hasSquad(squad.name()));
  }

  Widget _selectedSquadMatchupUi(BuildContext context, SquadMatchup m) {
    List<Widget> matchupWidgets = [
      _getSquadListRoundTitle(),
      _getSquadVsSquadTitle(context, m)
    ];

    m.coachMatchups.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
          matchup: m,
          roundIdx: _roundIdx!,
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

  Widget _squadMatchupListUi() {
    List<Widget> matchupWidgets = [_getSquadListRoundTitle()];

    _matchups.forEach((m) {
      InkWell inkWell = InkWell(
          child: MatchupSquadWidget(
            refreshState: true,
            matchup: m,
            roundIdx: _roundIdx!,
          ),
          onTap: () {
            setState(() {
              _autoSelectAuthUserMatchup = true;
              selectedMatchup = m;
              _roundIdx = _roundIdx;
              _reset = false;
            });
          });
      matchupWidgets.add(inkWell);
    });

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

  Widget _getSquadListRoundTitle() {
    final theme = Theme.of(context);

    bool hasPrevRound = _roundIdx! > 0;
    bool hasNextRound = _roundIdx! < _tournament.curRoundIdx();

    List<Widget> titleRoundWidgets = [];

    titleRoundWidgets.add(IconButton(
        color: !hasPrevRound ? Colors.transparent : null,
        onPressed: hasPrevRound
            ? () {
                setState(() {
                  _roundIdx = _roundIdx! - 1;
                });
              }
            : null,
        icon: hasPrevRound ? Icon(Icons.chevron_left) : Text("")));

    titleRoundWidgets.add(Text("Round #" + (_roundIdx! + 1).toString(),
        textAlign: TextAlign.center, style: theme.textTheme.titleMedium));

    titleRoundWidgets.add(IconButton(
        color: !hasNextRound ? Colors.transparent : null,
        onPressed: hasNextRound
            ? () {
                setState(() {
                  _roundIdx = _roundIdx! + 1;
                });
              }
            : null,
        icon: hasNextRound ? Icon(Icons.chevron_right) : Text("")));

    return Wrap(alignment: WrapAlignment.center, children: [
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: titleRoundWidgets,
          )
        ]),
      ))
    ]);
  }

  Widget _getSquadVsSquadTitle(BuildContext context, SquadMatchup m) {
    final theme = Theme.of(context);

    Squad? homeSquad = _tournament.getSquad(m.homeSquadName);
    Squad? awaySquad = _tournament.getSquad(m.awaySquadName);

    StringBuffer sbHome = StringBuffer();
    sbHome.write(m.homeSquadName + "\n");
    if (homeSquad != null) {
      sbHome.write("(" +
          homeSquad.wins().toString() +
          "/" +
          homeSquad.ties().toString() +
          "/" +
          homeSquad.losses().toString() +
          ")");
    }

    StringBuffer sbAway = StringBuffer();
    sbAway.write(m.awaySquadName + "\n");
    if (awaySquad != null) {
      sbAway.write("(" +
          awaySquad.wins().toString() +
          "/" +
          awaySquad.ties().toString() +
          "/" +
          awaySquad.losses().toString() +
          ")");
    }

    List<Widget> squadVsSquadTitleWidgets = [
      Expanded(
          child: Card(
              color: _getColor(m, true),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(sbHome.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall)))),
      Text("vs.", style: theme.textTheme.displaySmall),
      Expanded(
          child: Card(
              color: _getColor(m, false),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(sbAway.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall)))),
    ];

    return Wrap(alignment: WrapAlignment.center, children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: squadVsSquadTitleWidgets,
        )
      ]),
    ]);
  }

  Color? _getColor(SquadMatchup m, bool home) {
    if (!m.hasResult()) {
      return null;
    }

    MatchResult result = m.getResult();

    switch (result) {
      case MatchResult.HomeWon:
        return home ? Colors.green : Colors.red;
      case MatchResult.AwayWon:
        return home ? Colors.red : Colors.green;
      case MatchResult.Draw:
        return Colors.orange;
      case MatchResult.Conflict:
      case MatchResult.NoResult:
      default:
        return null;
    }
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
