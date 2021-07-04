import 'package:amorical_cup/data/squad_matchup.dart';
import 'package:amorical_cup/widgets/matchup_headline_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class MatchupsPage extends StatefulWidget {
  final List<SquadMatchup> squadMatchups;

  MatchupsPage({Key key, @required this.squadMatchups}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MatchupsPage();
  }
}

class _MatchupsPage extends State<MatchupsPage> {
  List<SquadMatchup> _squadMatchups = [];

  @override
  void initState() {
    _squadMatchups = widget.squadMatchups;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _squadMatchups[0].coachMatchups,
      groupBy: (matchup) => matchup.tableNum().toString(),
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: (context, matchup) => MatchupHeadlineWidget(
        matchup: matchup,
      ),
      order: GroupedListOrder.ASC,
    );
  }

  Widget _buildGroupSeparator(String groupTitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Squad Table #' + groupTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
