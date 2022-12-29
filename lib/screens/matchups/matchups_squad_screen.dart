import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/widgets/matchup_squad_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:bbnaf/utils/item_click_listener.dart';

class SquadMatchupsPage extends StatefulWidget {
  final Tournament tournament;
  final List<SquadMatchup> matchups;
  final CoachMatchupListClickListener? coachMatchupListeners;
  final Squad? curSquad;

  SquadMatchupsPage(
      {Key? key,
      required this.tournament,
      required this.matchups,
      this.coachMatchupListeners,
      this.curSquad})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SquadMatchupsPage();
  }
}

class _SquadMatchupsPage extends State<SquadMatchupsPage> {
  late Tournament _tournament;
  List<SquadMatchup> _matchups = [];
  MatchupClickListener? _listener;
  Squad? _curSquad;

  @override
  void initState() {
    _tournament = widget.tournament;
    _matchups = widget.matchups;
    _listener = new _MatchupClickListener(widget.coachMatchupListeners);
    _curSquad = widget.curSquad;
    super.initState();
  }

  // TODO: Add CurSquad widget at top if non-null
  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _matchups,
      groupBy: (IMatchup matchup) => _groupBy(matchup),
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: (BuildContext context, SquadMatchup matchup) =>
          MatchupSquadWidget(
        tournament: _tournament,
        matchup: matchup,
        listener: _listener,
      ),
      order: GroupedListOrder.ASC,
    );
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

class _MatchupClickListener implements MatchupClickListener {
  final CoachMatchupListClickListener? coachMatchupListeners;

  _MatchupClickListener(this.coachMatchupListeners);

  @override
  void onItemClicked(IMatchup matchup) {
    List<IMatchup> matchups = [];

    if (coachMatchupListeners != null && matchup is SquadMatchup) {
      for (CoachMatchup cm in matchup.coachMatchups) {
        matchups.add(cm);
      }

      coachMatchupListeners!.onItemClicked(matchup.coachMatchups);
    }
  }
}
