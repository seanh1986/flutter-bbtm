// ignore_for_file: must_be_immutable

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/rankings/models/ranking_filter.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/set_item_list_widget/set_item_list_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

class TournyRankingSettingsWidget extends StatefulWidget {
  late List<CoachRaceFilter> coachRaceRankingFilters;
  late bool showRankings;

  TournyRankingSettingsWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.coachRaceRankingFilters =
        List.from(info.scoringDetails.coachRaceRankingFilters);
    this.showRankings = info.showRankings;
  }

  @override
  State<TournyRankingSettingsWidget> createState() {
    return _TournyRankingSettingsWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.scoringDetails.coachRaceRankingFilters = coachRaceRankingFilters;
    info.showRankings = showRankings;
  }
}

class _TournyRankingSettingsWidget extends State<TournyRankingSettingsWidget> {
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
    List<Widget> widgets = [
      SizedBox(height: 10),
      _getRankingsOnOffToggle(),
      SizedBox(height: 5),
      Divider(),
      SizedBox(height: 5),
    ];

    widgets.addAll(_getCoachRankingFilterWidgets());

    return Column(children: widgets);
  }

  Widget _getRankingsOnOffToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Show Rankings (for participants)"),
        Checkbox(
          value: widget.showRankings,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                widget.showRankings = value;
              });
            }
          },
        ),
      ],
    );
  }

  List<Widget> _getCoachRankingFilterWidgets() {
    List<Widget> rankingFilterWidgets = [
      ElevatedButton(
        onPressed: () {
          String idx = (widget.coachRaceRankingFilters.length + 1).toString();
          widget.coachRaceRankingFilters
              .add(CoachRaceFilter("RankingFilter_" + idx, []));
          setState(() {});
        },
        child: const Text('Add Race Ranking Filter'),
      )
    ];

    for (int i = 0; i < widget.coachRaceRankingFilters.length; i++) {
      CoachRaceFilter filter = widget.coachRaceRankingFilters[i];

      String label = filter.name;
      List<String> curRaces = EnumToString.toList(filter.races);

      List<String> allRaces = EnumToString.toList(Race.values);

      rankingFilterWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 10.0),
            IconButton(
                onPressed: () {
                  widget.coachRaceRankingFilters.removeAt(i);
                  setState(() {});
                },
                icon: Icon(Icons.delete)),
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: label.toString(),
                    keyboardType: TextInputType.number,
                    title: 'Race Filter Label',
                    callback: (value) {
                      widget.coachRaceRankingFilters[i].name = value;
                    })),
            SizedBox(width: 10.0),
            Expanded(
                child: SetItemListWidget(
                    title: 'Set Races',
                    allItems: allRaces,
                    curItems: curRaces,
                    onComplete: (newItems) {
                      List<Race> races =
                          EnumToString.fromList(Race.values, newItems)
                              .nonNulls
                              .toList();

                      widget.coachRaceRankingFilters[i] =
                          CoachRaceFilter(label, races);
                    }))
          ]));
    }

    return rankingFilterWidgets;
  }
}
