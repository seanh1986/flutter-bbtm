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
  final String squadName;
  final VoidCallback? onBackPressed;

  SquadMatchupsPage({Key? key, required this.squadName, this.onBackPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SquadMatchupsPage();
  }
}

class _SquadMatchupsPage extends State<SquadMatchupsPage> {
  late Tournament _tournament;

  List<SquadMatchup> _matchups = [];

  late SquadMatchup? selectedMatchup;

  int? _roundIdx;

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

    if (_roundIdx == null) {
      _roundIdx = _tournament.curRoundIdx();
    }

    if (_tournament.squadRounds.isNotEmpty) {
      _matchups = List.from(_tournament.squadRounds[_roundIdx!].matches);
    }

    if (_matchups.isEmpty) {
      return _noMatchUpsYet();
    }

    selectedMatchup = _matchups
        .firstWhereOrNull((element) => element.hasSquad(widget.squadName));

    return selectedMatchup != null
        ? _selectedSquadMatchupUi(context, selectedMatchup!)
        : Text("Failed to load Squad Matchup. Try again later.");
  }

  Widget _selectedSquadMatchupUi(BuildContext context, SquadMatchup m) {
    List<Widget> matchupWidgets = [
      _getRoundTitle(),
      _getSquadVsSquadTitle(context, m)
    ];

    m.coachMatchups.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
          matchup: m,
          roundIdx: _roundIdx!,
          refreshState: true, // widget.refreshState,
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

  Widget _getRoundTitle() {
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

    List<Widget> rows = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: titleRoundWidgets,
      )
    ];

    if (widget.onBackPressed != null) {
      rows.add(SizedBox(height: 2));
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                widget.onBackPressed?.call();
              },
              child: Text("View All Squad Matchups"))
        ],
      ));
    }

    return Wrap(alignment: WrapAlignment.center, children: [
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: rows),
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
                      style: theme.textTheme.bodyLarge)))),
      Text("vs.", style: theme.textTheme.displaySmall),
      Expanded(
          child: Card(
              color: _getColor(m, false),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(sbAway.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge)))),
    ];

    return Wrap(alignment: WrapAlignment.center, children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: squadVsSquadTitleWidgets,
        ),
        SizedBox(height: 2),
        Divider(
          height: 20,
          thickness: 3,
        ),
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
