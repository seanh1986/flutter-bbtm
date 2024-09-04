// ignore_for_file: must_be_immutable

import 'package:bbnaf/admin/view/widgets/tourny_scoring_details_widget.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/set_item_list_widget/set_item_list_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

class TournyIndividualSettingsWidget extends StatefulWidget {
  late IndividualScoringDetails scoringDetails;
  late CoachDisplayName coachDisplayName;

  TournyIndividualSettingsWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.scoringDetails = info.scoringDetails;
    this.coachDisplayName = info.coachDisplayName;
  }

  @override
  State<TournyIndividualSettingsWidget> createState() {
    return _TournyIndividualSettingsWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.scoringDetails = scoringDetails;
    info.coachDisplayName = coachDisplayName;
  }
}

class _TournyIndividualSettingsWidget
    extends State<TournyIndividualSettingsWidget> {
  bool editIndividualTieBreakers = false;

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
    return Column(children: [
      TournyScoringDetailsWidget(
          title: "Coach Scoring", details: widget.scoringDetails),
      Divider(),
      _createIndividualTieBreakers(context),
      Divider(),
      _createCoachDisplayName(),
    ]);
  }

  Widget _createIndividualTieBreakers(BuildContext context) {
    final theme = Theme.of(context);

    List<String> curTiebreakers =
        EnumToString.toList(widget.scoringDetails.tieBreakers);

    String title = "Individual Tie Breakers";

    if (editIndividualTieBreakers) {
      List<String> allTiebreakers = EnumToString.toList(TieBreaker.values);

      return SetItemListWidget(
          title: title,
          allItems: allTiebreakers,
          curItems: curTiebreakers,
          onComplete: (newItems) {
            List<TieBreaker?> tieBreakers =
                EnumToString.fromList(TieBreaker.values, newItems);

            setState(() {
              widget.scoringDetails.tieBreakers = tieBreakers.nonNulls.toList();
              editIndividualTieBreakers = false;
            });
          });
    } else {
      StringBuffer sb = StringBuffer();
      sb.writeln(title);
      for (int i = 0; i < curTiebreakers.length; i++) {
        int rank = i + 1;
        String tieBreakerName = curTiebreakers[i];
        sb.write(rank.toString() + ". " + tieBreakerName);
        if (i + 1 < curTiebreakers.length) {
          sb.write("\n");
        }
      }

      return Row(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  editIndividualTieBreakers = true;
                });
              },
              icon: Icon(Icons.edit)),
          Text(sb.toString(), style: theme.textTheme.bodyMedium),
        ],
      );
    }
  }

  Row _createCoachDisplayName() {
    final theme = Theme.of(context);

    // Create Row for Display Names
    List<String> coachDisplayNames =
        EnumToString.toList(CoachDisplayName.values);

    List<DropdownMenuItem<String>> dropDown = coachDisplayNames
        .map((String r) => DropdownMenuItem<String>(value: r, child: Text(r)))
        .toList();

    List<Widget> row = [
      SizedBox(width: 10.0),
      Text("Display Names:"),
      SizedBox(width: 10.0),
      SizedBox(
          width: 250,
          child: DropdownButtonFormField<String>(
            style: theme.textTheme.labelMedium,
            value: EnumToString.convertToString(widget.coachDisplayName),
            items: dropDown,
            onChanged: (value) {
              CoachDisplayName? displayName = value is String
                  ? EnumToString.fromString(CoachDisplayName.values, value)
                  : null;
              widget.coachDisplayName =
                  displayName != null ? displayName : CoachDisplayName.NafName;

              setState(() {});
            },
          )),
      SizedBox(width: 10.0),
    ];

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: row);
  }
}
