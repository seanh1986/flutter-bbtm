// ignore_for_file: must_be_immutable

import 'package:bbnaf/admin/view/widgets/tourny_scoring_details_widget.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/set_item_list_widget/set_item_list_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TournySquadSettingsWidget extends StatefulWidget {
  late SquadDetails squadDetails;

  TournySquadSettingsWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.squadDetails = info.squadDetails;
  }

  @override
  State<TournySquadSettingsWidget> createState() {
    return _TournySquadSettingsWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    info.squadDetails = squadDetails;
  }
}

class _TournySquadSettingsWidget extends State<TournySquadSettingsWidget> {
  bool editSquadTieBreakers = false;

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
    final theme = Theme.of(context);

    List<String> squadUsageTypes = EnumToString.toList(SquadUsage.values);

    List<DropdownMenuItem<String>> squadUsageTypesDropDown = squadUsageTypes
        .map((String r) => DropdownMenuItem<String>(value: r, child: Text(r)))
        .toList();

    List<Widget> mainSquadDetailsRow = [
      SizedBox(width: 10.0),
      Text("Squad Details:"),
      SizedBox(width: 10.0),
      Expanded(
          child: DropdownButtonFormField<String>(
        style: theme.textTheme.labelMedium,
        value: EnumToString.convertToString(widget.squadDetails.type),
        items: squadUsageTypesDropDown,
        onChanged: (value) {
          SquadUsage? usage = value is String
              ? EnumToString.fromString(SquadUsage.values, value)
              : null;
          widget.squadDetails.type =
              usage != null ? usage : SquadUsage.NO_SQUADS;

          // Update UI based on toggle
          setState(() {});
        },
      ))
    ];

    if (widget.squadDetails.type == SquadUsage.SQUADS) {
      mainSquadDetailsRow.addAll([
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue:
              widget.squadDetails.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Active Coaches / Squad',
          callback: (value) =>
              widget.squadDetails.requiredNumCoachesPerSquad = int.parse(value),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue:
              widget.squadDetails.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Max Coaches / Squad',
          callback: (value) =>
              widget.squadDetails.maxNumCoachesPerSquad = int.parse(value),
        ))
      ]);
    }

    List<Widget> mainContent = [
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: mainSquadDetailsRow)
    ];

    if (widget.squadDetails.type == SquadUsage.SQUADS) {
      // Update Main Content w/ squad scoring type
      mainContent.addAll([
        Divider(),
        _getSquadScoringSelection(),
      ]);

      if (widget.squadDetails.scoringType == SquadScoring.SQUAD_RESULT_W_T_L) {
        // Update Main Content w/ squad scoring parameters
        mainContent.addAll([
          Divider(),
          TournyScoringDetailsWidget(
              title: "Squad Scoring",
              details: widget.squadDetails.scoringDetails),
          Divider(),
          _createSquadTieBreakers(context)
        ]);
      }

      // Update Main Content w/ squad matching
      mainContent.addAll([
        Divider(),
        _getSquadMatchingSelection(),
      ]);
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: mainContent);
  }

  Row _getSquadScoringSelection() {
    final theme = Theme.of(context);

    // Create Row for Squad Scoring
    List<String> squadScoringTypes = EnumToString.toList(SquadScoring.values);

    List<DropdownMenuItem<String>> squadScoringTypesDropDown = squadScoringTypes
        .map((String r) => DropdownMenuItem<String>(value: r, child: Text(r)))
        .toList();

    List<Widget> squadScoringRow = [
      SizedBox(width: 10.0),
      Text("Squad Scoring Type:"),
      SizedBox(width: 10.0),
      Expanded(
          child: DropdownButtonFormField<String>(
        style: theme.textTheme.labelMedium,
        value: EnumToString.convertToString(widget.squadDetails.scoringType),
        items: squadScoringTypesDropDown,
        onChanged: (value) {
          SquadScoring? scoringTypes = value is String
              ? EnumToString.fromString(SquadScoring.values, value)
              : null;
          widget.squadDetails.scoringType = scoringTypes != null
              ? scoringTypes
              : SquadScoring.CUMULATIVE_PLAYER_SCORES;

          setState(() {});
        },
      )),
    ];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: squadScoringRow);
  }

  Row _getSquadMatchingSelection() {
    final theme = Theme.of(context);

    // Create Row for Squad Scoring
    List<String> squadMatchMakingTypes =
        EnumToString.toList(SquadMatchMaking.values);

    List<DropdownMenuItem<String>> squadMatchMakingTypesDropDown =
        squadMatchMakingTypes
            .map((String r) =>
                DropdownMenuItem<String>(value: r, child: Text(r)))
            .toList();

    List<Widget> squadMatchMakingRow = [
      SizedBox(width: 10.0),
      Text("Squad Match Making:"),
      SizedBox(width: 10.0),
      Expanded(
          child: DropdownButtonFormField<String>(
        value: EnumToString.convertToString(widget.squadDetails.matchMaking),
        style: theme.textTheme.labelMedium,
        items: squadMatchMakingTypesDropDown,
        onChanged: (value) {
          SquadMatchMaking? matchMakingType = value is String
              ? EnumToString.fromString(SquadMatchMaking.values, value)
              : null;
          widget.squadDetails.matchMaking = matchMakingType != null
              ? matchMakingType
              : SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES;
        },
      ))
    ];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: squadMatchMakingRow);
  }

  Widget _createSquadTieBreakers(BuildContext context) {
    final theme = Theme.of(context);

    List<String> curTiebreakers =
        EnumToString.toList(widget.squadDetails.squadTieBreakers);

    String title = "Squad Tie Breakers";

    if (editSquadTieBreakers) {
      List<String> allTiebreakers =
          EnumToString.toList(SquadTieBreakers.values);

      return SetItemListWidget(
          title: title,
          allItems: allTiebreakers,
          curItems: curTiebreakers,
          onComplete: (newItems) {
            List<SquadTieBreakers?> tieBreakers =
                EnumToString.fromList(SquadTieBreakers.values, newItems);

            setState(() {
              widget.squadDetails.squadTieBreakers =
                  tieBreakers.nonNulls.toList();
              editSquadTieBreakers = false;
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
                  editSquadTieBreakers = true;
                });
              },
              icon: Icon(Icons.edit)),
          Text(sb.toString(), style: theme.textTheme.bodyMedium),
        ],
      );
    }
  }
}
