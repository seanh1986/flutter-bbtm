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

    if (_tournament.squadRounds.isNotEmpty) {
      _matchups = List.from(_tournament.squadRounds.last.matches);
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
      SizedBox(height: 10),
      _getSquadVsSquadTitle(context, m),
      SizedBox(height: 10),
    ];

    m.coachMatchups.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
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

  Widget _squadMatchupListUi() {
    List<Widget> matchupWidgets = [
      SizedBox(height: 10),
      _getSquadListRoundTitle(),
      SizedBox(height: 10),
    ];

    _matchups.forEach((m) {
      InkWell inkWell = InkWell(
          child: MatchupSquadWidget(
            matchup: m,
          ),
          onTap: () {
            setState(() {
              _autoSelectAuthUserMatchup = true;
              selectedMatchup = m;
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

  Widget _getSquadVsSquadTitle(BuildContext context, SquadMatchup m) {
    final theme = Theme.of(context);

    StringBuffer sb = StringBuffer();
    sb.writeln("Round #" + _tournament.curRoundNumber().toString() + ":");

    Squad? homeSquad = _tournament.getSquad(m.homeSquadName);
    Squad? awaySquad = _tournament.getSquad(m.awaySquadName);

    sb.write(m.homeSquadName + " ");
    if (homeSquad != null) {
      sb.write("(" +
          homeSquad.wins().toString() +
          "/" +
          homeSquad.ties().toString() +
          "/" +
          homeSquad.losses().toString() +
          ")");
    }
    sb.writeln("");

    sb.write(m.awaySquadName + " ");
    if (awaySquad != null) {
      sb.write("(" +
          awaySquad.wins().toString() +
          "/" +
          awaySquad.ties().toString() +
          "/" +
          awaySquad.losses().toString() +
          ")");
    }

    return Column(children: [
      IconButton(
          color: theme.appBarTheme.iconTheme!.color,
          onPressed: () {
            setState(() {
              _autoSelectAuthUserMatchup = false;
              selectedMatchup = null;
              _reset = false;
            });
          },
          icon: Icon(Icons.arrow_back_rounded)),
      SizedBox(height: 10),
      TitleBar(title: sb.toString())
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
