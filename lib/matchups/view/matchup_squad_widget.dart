import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchupSquadWidget extends StatefulWidget {
  final SquadMatchup matchup;
  final int roundIdx;
  final bool refreshState;

  MatchupSquadWidget(
      {Key? key,
      required this.matchup,
      required this.roundIdx,
      required this.refreshState})
      : super(key: key);

  @override
  State<MatchupSquadWidget> createState() {
    return _MatchupSquadWidget();
  }
}

class _MatchupSquadWidget extends State<MatchupSquadWidget> {
  late Tournament _tournament;
  late SquadMatchup _matchup;
  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _matchup = widget.matchup;
  }

  void _refreshState() {
    _matchup = widget.matchup;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;

    if (widget.refreshState) {
      _refreshState();
    }

    return Container(
        alignment: FractionalOffset.center, child: _squadMatchupWidget());
  }

  Widget _squadMatchupWidget() {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Card(
                          color: _getColor(_matchup, true),
                          child: Column(
                            children: [
                              Text(_matchup.homeSquadName,
                                  style: TextStyle(fontSize: titleFontSize)),
                              Text(_matchup.home(_tournament).showRecord(),
                                  style: TextStyle(fontSize: subTitleFontSize)),
                            ],
                          ),
                        ),
                      )),
                      Text(
                        ' vs. ',
                        style: TextStyle(fontSize: titleFontSize),
                      ),
                      Expanded(
                          child: Container(
                        child: Card(
                          color: _getColor(_matchup, false),
                          child: Column(
                            children: [
                              Text(_matchup.awaySquadName,
                                  style: TextStyle(fontSize: titleFontSize)),
                              Text(_matchup.away(_tournament).showRecord(),
                                  style: TextStyle(fontSize: subTitleFontSize)),
                            ],
                          ),
                        ),
                      )),
                    ]))));
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
}
