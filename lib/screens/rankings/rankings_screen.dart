import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/screens/rankings/rankings_coach_widget.dart';
import 'package:bbnaf/screens/rankings/rankings_squads_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RankingsPage extends StatefulWidget {
  RankingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingsPage();
  }
}

class _RankingsPage extends State<RankingsPage> {
  late Tournament _tournament;
  late User _user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshState() {
    _tournament.reProcessAllRounds();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    _refreshState();

    if (_tournament.useSquads()) {
      return _squadAndCoachTabs();
    }

    return _coachRankingsWithToggles();
  }

  List<SquadRankingFields> _getSquadRankingFieldsCombined() {
    return [
      SquadRankingFields.Pts,
      SquadRankingFields.W_T_L,
      SquadRankingFields.SumIndividualScore,
      SquadRankingFields.OppScore,
    ];
  }

  List<CoachRankingFields> _getCoachRankingFieldsCombined() {
    return [
      CoachRankingFields.Pts,
      CoachRankingFields.W_T_L,
      CoachRankingFields.OppScore,
      CoachRankingFields.Td,
      CoachRankingFields.Cas,
    ];
  }

  List<CoachRankingFields> _getCoachRankingFieldsCombinedAdmin() {
    return [
      CoachRankingFields.Pts,
      CoachRankingFields.W_T_L,
      CoachRankingFields.OppScore,
      CoachRankingFields.Td,
      CoachRankingFields.Cas,
      CoachRankingFields.BestSport
    ];
  }

  Widget _coachRankingsWithToggles() {
    int tabLength;
    List<Widget> topBar;
    List<Widget> views;

    if (_tournament.isUserAdmin(_user)) {
      tabLength = 4;
      topBar = [
        Tab(text: "Combined"),
        Tab(text: "Td"),
        Tab(text: "Cas"),
        Tab(text: "Sport")
      ];
      views = [
        RankingCoachPage(fields: _getCoachRankingFieldsCombinedAdmin()),
        RankingCoachPage(fields: [
          CoachRankingFields.Td,
          CoachRankingFields.OppTd,
          CoachRankingFields.DeltaTd
        ]),
        RankingCoachPage(fields: [
          CoachRankingFields.Cas,
          CoachRankingFields.OppCas,
          CoachRankingFields.DeltaCas
        ]),
        RankingCoachPage(fields: [CoachRankingFields.BestSport])
      ];
    } else {
      tabLength = 3;
      topBar = [Tab(text: "Combined"), Tab(text: "Td"), Tab(text: "Cas")];
      views = [
        RankingCoachPage(fields: _getCoachRankingFieldsCombined()),
        RankingCoachPage(fields: [
          CoachRankingFields.Td,
          CoachRankingFields.OppTd,
          CoachRankingFields.DeltaTd
        ]),
        RankingCoachPage(fields: [
          CoachRankingFields.Cas,
          CoachRankingFields.OppCas,
          CoachRankingFields.DeltaCas
        ])
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
              // physics: AlwaysScrollableScrollPhysics(),
              physics: NeverScrollableScrollPhysics(),
            )));
  }

  Widget _squadAndCoachTabs() {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                RankingSquadsPage(fields: _getSquadRankingFieldsCombined()),
                _coachRankingsWithToggles(),
              ],
            )));
  }
}
