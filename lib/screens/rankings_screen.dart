import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/widgets/rankings_coach_widget.dart';
import 'package:bbnaf/widgets/rankings_squads_widget.dart';
import 'package:flutter/material.dart';

class RankingsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;

  RankingsPage({Key? key, required this.tournament, required this.authUser})
      : super(key: key);

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
    if (_tournament.useSquads) {
      return _squadAndCoachTabs();
    }

    return _coachRankingsWithToggles();
  }

  List<Fields> _getFieldsCombined() {
    return [Fields.Pts, Fields.W, Fields.T, Fields.L, Fields.Td, Fields.Cas];
  }

  List<Fields> _getFieldsCombinedAdmin() {
    return [
      Fields.Pts,
      Fields.W,
      Fields.T,
      Fields.L,
      Fields.Td,
      Fields.Cas,
      Fields.BestSport
    ];
  }

  Widget _coachRankingsWithToggles() {
    int tabLength;
    List<Widget> topBar;
    List<Widget> views;

    if (widget.tournament.isUserAdmin(widget.authUser)) {
      tabLength = 4;
      topBar = [
        Tab(text: "Combined"),
        Tab(text: "Td"),
        Tab(text: "Cas"),
        Tab(text: "Sport")
      ];
      views = [
        RankingCoachPage(
            tournament: _tournament, fields: _getFieldsCombinedAdmin()),
        RankingCoachPage(tournament: _tournament, fields: [Fields.Td]),
        RankingCoachPage(tournament: _tournament, fields: [Fields.Cas]),
        RankingCoachPage(tournament: _tournament, fields: [Fields.BestSport])
      ];
    } else {
      tabLength = 3;
      topBar = [Tab(text: "Combined"), Tab(text: "Td"), Tab(text: "Cas")];
      views = [
        RankingCoachPage(tournament: _tournament, fields: _getFieldsCombined()),
        RankingCoachPage(tournament: _tournament, fields: [Fields.Td]),
        RankingCoachPage(tournament: _tournament, fields: [Fields.Cas])
      ];
    }

    return DefaultTabController(
        length: tabLength,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                    tabs: topBar,
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: views,
            )));
  }

  // Deprecated
  Widget _squadAndCoachTabs() {
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
                _coachRankingsWithToggles(),
              ],
            )));
  }
}
