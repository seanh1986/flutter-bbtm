import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AllSquadsMatchupsPage extends StatefulWidget {
  AllSquadsMatchupsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AllSquadsMatchupsPage();
  }
}

class _AllSquadsMatchupsPage extends State<AllSquadsMatchupsPage> {
  late Tournament _tournament;

  List<SquadMatchup> _matchups = [];

  int? _roundIdx;

  String? _selectedSquadName;

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

    if (_selectedSquadName != null) {
      return SquadMatchupsPage(
          squadName: _selectedSquadName!,
          onBackPressed: () {
            setState(() {
              _selectedSquadName = null;
            });
          });
    }

    return _squadMatchupListUi();
  }

  Widget _squadMatchupListUi() {
    List<Widget> matchupWidgets = [_getRoundTitle()];

    _matchups.forEach((m) {
      InkWell inkWell = InkWell(
          child: MatchupSquadWidget(
            refreshState: true,
            matchup: m,
            roundIdx: _roundIdx!,
          ),
          onTap: () {
            setState(() {
              _roundIdx = _roundIdx;
              _selectedSquadName = m.homeSquadName;
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
