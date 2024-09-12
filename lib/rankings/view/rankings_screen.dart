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

    Widget widget;
    if (_tournament.useSquadRankings()) {
      widget = _squadAndCoachTabs();
    } else {
      widget = _coachRankingsWithToggles();
    }

    return widget;
  }

  List<SquadRankingField> _getSquadRankingFieldsCombined() {
    return [
      SquadRankingField(SquadRankingFieldType.Pts),
      SquadRankingField(SquadRankingFieldType.W_T_L),
      SquadRankingField(SquadRankingFieldType.SumIndividualScore),
      SquadRankingField(SquadRankingFieldType.OppScore),
      SquadRankingField(SquadRankingFieldType.SumTd),
      SquadRankingField(SquadRankingFieldType.SumCas),
    ];
  }

  List<SquadRankingField> _getSquadRankingFieldsCombinedAdmin() {
    return [
      SquadRankingField(SquadRankingFieldType.Pts),
      SquadRankingField(SquadRankingFieldType.W_T_L),
      SquadRankingField(SquadRankingFieldType.SumIndividualScore),
      SquadRankingField(SquadRankingFieldType.OppScore),
      SquadRankingField(SquadRankingFieldType.SumTd),
      SquadRankingField(SquadRankingFieldType.SumCas),
      // SquadRankingField(SquadRankingFieldType.SumBestSport),
    ];
  }

  List<CoachRankingField> _getCoachRankingFieldsCombined() {
    return [
      CoachRankingField(CoachRankingFieldType.Pts),
      CoachRankingField(CoachRankingFieldType.W_T_L),
      CoachRankingField(CoachRankingFieldType.OppScore),
      CoachRankingField(CoachRankingFieldType.Td),
      CoachRankingField(CoachRankingFieldType.Cas),
    ];
  }

  List<CoachRankingField> _getCoachRankingFieldsCombinedAdmin() {
    return [
      CoachRankingField(CoachRankingFieldType.Pts),
      CoachRankingField(CoachRankingFieldType.W_T_L),
      CoachRankingField(CoachRankingFieldType.OppScore),
      CoachRankingField(CoachRankingFieldType.Td),
      CoachRankingField(CoachRankingFieldType.Cas),
      // CoachRankingField(CoachRankingFields.BestSport),
    ];
  }

  Widget _coachRankingsWithToggles() {
    bool showAdminDetails = _tournament.isUserAdmin(_user);

    StuntyFilter stuntyFilter = StuntyFilter();

    List<ToggleWidgetItem> items = [
      ToggleWidgetItem("Combined", (context) {
        return RankingCoachPage(
            title: "Coach Rankings - Combined",
            fields: showAdminDetails
                ? _getCoachRankingFieldsCombinedAdmin()
                : _getCoachRankingFieldsCombined());
      }),
      ToggleWidgetItem("Td", (context) {
        return RankingCoachPage(title: "Coach Touchdowns", fields: [
          CoachRankingField(CoachRankingFieldType.Td),
          CoachRankingField(CoachRankingFieldType.OppTd),
          CoachRankingField(CoachRankingFieldType.DeltaTd),
        ]);
      }),
      ToggleWidgetItem("Cas", (context) {
        return RankingCoachPage(title: "Coach Casualties", fields: [
          CoachRankingField(CoachRankingFieldType.Cas),
          CoachRankingField(CoachRankingFieldType.OppCas),
          CoachRankingField(CoachRankingFieldType.DeltaCas),
        ]);
      }),
      ToggleWidgetItem(stuntyFilter.name, (context) {
        return RankingCoachPage(
            title: "Coach " + stuntyFilter.name,
            filter: stuntyFilter,
            fields: stuntyFilter.fields);
      }),
    ];

    _tournament.info.scoringDetails.coachRaceRankingFilters.forEach((f) {
      items.add(ToggleWidgetItem(f.name, (context) {
        return RankingCoachPage(
            title: "Coach " + f.name,
            filter: f,
            fields: showAdminDetails
                ? _getCoachRankingFieldsCombinedAdmin()
                : _getCoachRankingFieldsCombined());
      }));
    });

    // If we should use bonus points
    ScoringDetails coachScoringDetails = _tournament.info.scoringDetails;
    if (coachScoringDetails.bonusPts.isNotEmpty &&
        _tournament.info.showBonusPtsInRankings) {
      List<CoachRankingField> fields = [];

      for (int i = 0; i < coachScoringDetails.bonusPts.length; i++) {
        fields.add(CoachRankingField(CoachRankingFieldType.Bonus,
            info: _tournament.info, bonusIdx: i));
      }

      items.add(ToggleWidgetItem("Bonuses", (context) {
        return RankingCoachPage(title: "Bonuses", fields: fields);
      }));
    }

// TODO: BestSport
    // if (showAdminDetails) {
    //   items.add(ToggleWidgetItem("Sport", (context) {
    //     return RankingCoachPage(
    //         title: "Coach Best Sport", fields: [CoachRankingFields.BestSport]);
    //   }));
    // }

    return ToggleWidget(items: items);
  }

  Widget _squadRankingsWithToggles() {
    bool showAdminDetails = _tournament.isUserAdmin(_user);

    List<ToggleWidgetItem> items = [
      ToggleWidgetItem("Combined", (context) {
        return RankingSquadsPage(
            title: "Squad Rankings - Combined",
            fields: showAdminDetails
                ? _getSquadRankingFieldsCombinedAdmin()
                : _getSquadRankingFieldsCombined());
      }),
      ToggleWidgetItem("Td", (context) {
        return RankingSquadsPage(title: "Squad Touchdowns", fields: [
          SquadRankingField(SquadRankingFieldType.SumTd),
          SquadRankingField(SquadRankingFieldType.SumOppTd),
          SquadRankingField(SquadRankingFieldType.SumDeltaTd),
        ]);
      }),
      ToggleWidgetItem("Cas", (context) {
        return RankingSquadsPage(title: "Squad Casualties", fields: [
          SquadRankingField(SquadRankingFieldType.SumCas),
          SquadRankingField(SquadRankingFieldType.SumOppCas),
          SquadRankingField(SquadRankingFieldType.SumDeltaCas),
        ]);
      }),
    ];

// TODO: BestSport
    // if (showAdminDetails) {
    //   items.add(ToggleWidgetItem("Sport", (context) {
    //     return RankingSquadsPage(
    //         title: "Squad Best Sports",
    //         fields: [SquadRankingFields.SumBestSport]);
    //   }));
    // }

    _tournament.info.squadDetails.squadRankingFilters.forEach((f) {
      items.add(ToggleWidgetItem(f.name, (context) {
        return RankingSquadsPage(
            title: "Squad " + f.name, filter: f, fields: f.fields);
      }));
    });

    // If we should use bonus points
    ScoringDetails squadScoringDetails =
        _tournament.info.squadDetails.scoringDetails;
    if (squadScoringDetails.bonusPts.isNotEmpty &&
        _tournament.info.showBonusPtsInRankings) {
      List<CoachRankingField> fields = [];

      for (int i = 0; i < squadScoringDetails.bonusPts.length; i++) {
        fields.add(CoachRankingField(CoachRankingFieldType.Bonus,
            info: _tournament.info, bonusIdx: i));
      }

      items.add(ToggleWidgetItem("Bonuses", (context) {
        return RankingCoachPage(title: "Bonuses", fields: fields);
      }));
    }

    return ToggleWidget(items: items);
  }

  Widget _squadAndCoachTabs() {
    List<ToggleWidgetItem> items = [
      ToggleWidgetItem("Squad Rankings", (context) {
        // Material somehow fixed bug with toggling between Squad & Coach
        return Material(
            child: Column(children: [
          SizedBox(height: 1),
          _squadRankingsWithToggles(),
        ]));
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
