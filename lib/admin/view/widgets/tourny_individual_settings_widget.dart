// ignore_for_file: must_be_immutable

import 'package:bbnaf/admin/view/widgets/tourny_scoring_details.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/set_item_list_widget/set_item_list_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

class TournyIndividualSettingsWidget extends StatefulWidget {
  late IndividualScoringDetails scoringDetails;
  late TournyScoringDetailsWidget detailsWidget;

  TournyIndividualSettingsWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.scoringDetails = info.scoringDetails;
  }

  @override
  State<TournyIndividualSettingsWidget> createState() {
    return _TournyIndividualSettingsWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.scoringDetails = scoringDetails;
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
    widget.detailsWidget = TournyScoringDetailsWidget(
        title: "Coach Scoring", details: widget.scoringDetails);

    return Column(children: [
      widget.detailsWidget,
      Divider(),
      _createIndividualTieBreakers(context)
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
}
