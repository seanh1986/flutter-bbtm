import 'package:bbnaf/models/matchup/squad_matchup.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';

class MatchupSquadWidget extends StatefulWidget {
  final Tournament tournament;
  final SquadMatchup matchup;

  MatchupSquadWidget(
      {Key? key, required this.tournament, required this.matchup})
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
    _tournament = widget.tournament;
    _matchup = widget.matchup;
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Column(
                          children: [
                            Text(_matchup.homeSquadName,
                                style: TextStyle(fontSize: titleFontSize)),
                            Text(_matchup.home(_tournament).showRecord(),
                                style: TextStyle(fontSize: subTitleFontSize)),
                          ],
                        ),
                      )),
                      Text(
                        ' vs. ',
                        style: TextStyle(fontSize: titleFontSize),
                      ),
                      Expanded(
                          child: Container(
                        child: Column(
                          children: [
                            Text(_matchup.awaySquadName,
                                style: TextStyle(fontSize: titleFontSize)),
                            Text(_matchup.away(_tournament).showRecord(),
                                style: TextStyle(fontSize: subTitleFontSize)),
                          ],
                        ),
                      )),
                    ]))));
  }
}
