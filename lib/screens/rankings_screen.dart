import 'package:amorical_cup/data/tournament.dart';
import 'package:amorical_cup/widgets/rankings_coach_widget.dart';
import 'package:amorical_cup/widgets/rankings_squads_widget.dart';
import 'package:flutter/material.dart';
import 'package:amorical_cup/data/coach.dart';

class RankingsPage extends StatefulWidget {
  final Tournament tournament;

  RankingsPage({Key? key, required this.tournament}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingsPage();
  }
}

class _RankingsPage extends State<RankingsPage> {
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                    tabs: <Widget>[
                      Tab(
                        text: "Squad Rankings",
                      ),
                      Tab(
                        text: "Coach Ranking",
                      )
                    ],
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                RankingSquadsPage(tournament: _tournament),
                RankingCoachPage(tournament: _tournament),
              ],
            )));
  }
}
