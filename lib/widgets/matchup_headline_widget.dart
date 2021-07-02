import 'package:amorical_cup/data/i_matchup.dart';
import 'package:flutter/material.dart';

class MatchupHeadlineWidget extends StatefulWidget {
  final IMatchup matchup;

  MatchupHeadlineWidget({Key key, @required this.matchup}) : super(key: key);

  @override
  State<MatchupHeadlineWidget> createState() {
    return _MatchupHeadlineWidget();
  }
}

class _MatchupHeadlineWidget extends State<MatchupHeadlineWidget> {
  IMatchup _matchup;

  @override
  void initState() {
    _matchup = widget.matchup;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Icon(Icons.account_circle),
            title: Text(_matchup.homeName() + ' vs. ' + _matchup.awayName()),
            trailing: Icon(Icons.arrow_forward),
          ),
        ));
  }
}
