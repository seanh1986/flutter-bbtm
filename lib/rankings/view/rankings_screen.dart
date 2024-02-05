import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/widgets/toggle_widget/models/toggle_widget_item.dart';
import 'package:bbnaf/widgets/toggle_widget/view/toggle_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    _tournament.reProcessAllRounds();

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
    bool showAdminDetails = _tournament.isUserAdmin(_user);

    List<ToggleWidgetItem> items = [
      ToggleWidgetItem("Combined", (context) {
        return RankingCoachPage(
            fields: showAdminDetails
                ? _getCoachRankingFieldsCombinedAdmin()
                : _getCoachRankingFieldsCombined());
      }),
      ToggleWidgetItem("Td", (context) {
        return RankingCoachPage(fields: [
          CoachRankingFields.Td,
          CoachRankingFields.OppTd,
          CoachRankingFields.DeltaTd
        ]);
      }),
      ToggleWidgetItem("Cas", (context) {
        return RankingCoachPage(fields: [
          CoachRankingFields.Cas,
          CoachRankingFields.OppCas,
          CoachRankingFields.DeltaCas
        ]);
      }),
    ];

    if (showAdminDetails) {
      items.add(ToggleWidgetItem("Sport", (context) {
        return RankingCoachPage(fields: [CoachRankingFields.BestSport]);
      }));
    }

    return ToggleWidget(items: items);
  }

  Widget _squadAndCoachTabs() {
    List<ToggleWidgetItem> items = [
      ToggleWidgetItem("Squad Rankings", (context) {
        return RankingSquadsPage(fields: _getSquadRankingFieldsCombined());
      }),
      ToggleWidgetItem("Coach Rankings", (context) {
        return Column(children: [
          SizedBox(height: 1),
          _coachRankingsWithToggles(),
        ]);
      }),
    ];

    return ToggleWidget(items: items);
  }
}
