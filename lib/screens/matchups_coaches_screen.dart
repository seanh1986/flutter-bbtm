import 'package:amorical_cup/data/coach_matchup.dart';
import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/widgets/matchup_headline_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class CoachMatchupsPage extends StatefulWidget {
  final List<CoachMatchup> matchups;
  // final MatchupListClickListener matchupListClickListener;

  CoachMatchupsPage({Key? key, required this.matchups}) : super(key: key);

  // void setCoachMatchups(List<CoachMatchup> matchups) {
  //   this.matchups = matchups;
  // }

  @override
  State<StatefulWidget> createState() {
    return _CoachMatchupsPage();
  }
}

class _CoachMatchupsPage extends State<CoachMatchupsPage> {
  List<CoachMatchup> _matchups = [];
  // MatchupClickListener _listener;

  @override
  void initState() {
    super.initState();
    _matchups = widget.matchups;
    // _listener = new _MatchupClickListener(widget.matchupListClickListener);
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _matchups,
      groupBy: (IMatchup matchup) => _groupBy(matchup),
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: (BuildContext context, IMatchup matchup) =>
          MatchupHeadlineWidget(
        matchup: matchup,
        // listener: _listener,
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

// class _MatchupClickListener implements MatchupClickListener {
//   final MatchupListClickListener matchupListClickListener;

//   _MatchupClickListener(this.matchupListClickListener);

//   @override
//   void onItemClicked(IMatchup matchup) {
//     List<IMatchup> matchups = [];

//     if (matchup is SquadMatchup) {
//       for (CoachMatchup cm in matchup.coachMatchups) {
//         matchups.add(cm);
//       }
//     } else {
//       matchups.add(matchup);
//     }

//     if (matchupListClickListener != null) {
//       matchupListClickListener.onItemClicked(matchups);
//     }
//   }
// }
