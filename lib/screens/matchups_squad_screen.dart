import 'package:amorical_cup/models/coach_matchup.dart';
import 'package:amorical_cup/models/i_matchup.dart';
import 'package:amorical_cup/models/squad_matchup.dart';
import 'package:amorical_cup/widgets/matchup_squad_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';

class SquadMatchupsPage extends StatefulWidget {
  final List<SquadMatchup> matchups;
  final CoachMatchupListClickListener? coachMatchupListeners;

  SquadMatchupsPage(
      {Key? key, required this.matchups, this.coachMatchupListeners})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SquadMatchupsPage();
  }
}

class _SquadMatchupsPage extends State<SquadMatchupsPage> {
  List<SquadMatchup> _matchups = [];
  MatchupClickListener? _listener;

  @override
  void initState() {
    _matchups = widget.matchups;
    _listener = new _MatchupClickListener(widget.coachMatchupListeners);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _matchups,
      groupBy: (IMatchup matchup) => _groupBy(matchup),
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: (BuildContext context, SquadMatchup matchup) =>
          MatchupSquadWidget(
        matchup: matchup,
        listener: _listener,
      ),
      order: GroupedListOrder.ASC,
    );
  }

  String _groupBy(IMatchup matchup) {
    return matchup.matchupName();
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
