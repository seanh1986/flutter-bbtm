import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/widgets/matchup_coach_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class CoachMatchupsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;
  // final MatchupListClickListener matchupListClickListener;

  CoachMatchupsPage(
      {Key? key, required this.tournament, required this.authUser})
      : super(key: key);

  // void setCoachMatchups(List<CoachMatchup> matchups) {
  //   this.matchups = matchups;
  // }

  @override
  State<StatefulWidget> createState() {
    return _CoachMatchupsPage();
  }
}

class _CoachMatchupsPage extends State<CoachMatchupsPage> {
  late Tournament _tournament;
  late AuthUser _authUser;
  List<CoachMatchup> _matchups = [];
  // MatchupClickListener _listener;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _authUser = widget.authUser;

    if (_tournament.coachRounds.isNotEmpty) {
      _matchups = _tournament.coachRounds.last.matches;
    }
    // _listener = new _MatchupClickListener(widget.matchupListClickListener);
  }

  // TODO: Add CurCoach widget at top if non-null
  @override
  Widget build(BuildContext context) {
    if (_matchups.isEmpty) {
      return _noMatchUpsYet();
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              './assets/images/background/background_football_field.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GroupedListView(
          elements: _matchups,
          groupBy: (IMatchup matchup) => _groupBy(matchup),
          groupSeparatorBuilder: _buildGroupSeparator,
          itemBuilder: (BuildContext context, CoachMatchup matchup) =>
              MatchupCoachWidget(
            tournament: _tournament,
            authUser: _authUser,
            matchup: matchup,
            // listener: _listener,
          ),
          order: GroupedListOrder.ASC,
        ),
      ),
    );
  }

  String _groupBy(IMatchup matchup) {
    return matchup.groupByName(_tournament);
  }

  Widget _buildGroupSeparator(String matchupName) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(matchupName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ])));
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
