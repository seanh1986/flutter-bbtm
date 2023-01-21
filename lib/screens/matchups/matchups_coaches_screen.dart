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
    return _matchups.isNotEmpty
        ? GroupedListView(
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
          )
        : _noMatchUpsYet();
  }

  String _groupBy(IMatchup matchup) {
    return matchup.groupByName(_tournament);
  }

  Widget _buildGroupSeparator(String matchupName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        matchupName,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _noMatchUpsYet() {
  return Container(
    child: Text('Matchups not available yet'),
  );
}
