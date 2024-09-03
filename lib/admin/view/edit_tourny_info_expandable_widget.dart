import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/admin/view/widgets/tourny_basic_info_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_home_page_info_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_orga_info_widget.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/models/ranking_filter.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/checkbox_formfield/checkbox_list_tile_formfield.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/set_item_list_widget/set_item_list_widget.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// import 'package:meta/meta.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditTournamentInfoExpandableWidget extends StatefulWidget {
  // Optional can supply tournament object for population (e.g., create tournament)
  final Tournament? tournament;
  final bool createTournament;

  EditTournamentInfoExpandableWidget(
      {Key? key, this.tournament, this.createTournament = false})
      : super(key: key);

  @override
  State<EditTournamentInfoExpandableWidget> createState() {
    return _EditTournamentInfoExpandableWidget();
  }
}

class ExpandListItem {
  String title;
  Widget widget;
  ExpandListItem(this.title, this.widget);
}

class _EditTournamentInfoExpandableWidget
    extends State<EditTournamentInfoExpandableWidget> {
  late IndividualScoringDetails _scoringDetails;

  late CasualtyDetails _casualtyDetails;
  late SquadDetails _squadDetails;

  bool refreshFields = true;
  bool editDates = false;

  bool editIndividualTieBreakers = false;
  bool editSquadTieBreakers = false;

  late Tournament _tournament;

  late TournyBasicInfoWidget _tournyBasicInfoWidget;
  late TournyOrganizerInfoWidget _tournyOrganizerInfoWidget;
  late TournyHomePageInfoWidget _tournyHomePageInfoWidget;

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
    if (widget.tournament != null) {
      _tournament = widget.tournament!;
    } else {
      AppState appState = context.select((AppBloc bloc) => bloc.state);
      _tournament = appState.tournamentState.tournament;
    }

    _tournyBasicInfoWidget = TournyBasicInfoWidget(info: _tournament.info);

    _tournyOrganizerInfoWidget =
        TournyOrganizerInfoWidget(info: _tournament.info);

    _tournyHomePageInfoWidget =
        TournyHomePageInfoWidget(info: _tournament.info);

    List<Widget> widgets = [
      TitleBar(
        title: "Edit Tournament Info (Id: " + _tournament.info.id + ")",
        extraWidgets: [
          IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: _tournament.info.id));
                // copied successfully
              },
              icon: Icon(Icons.copy))
        ],
      ),
      SizedBox(height: 20),
      _updateOrDiscard(),
      Divider(),
      _createExpansionTile(
          ExpandListItem("Basic Information", _tournyBasicInfoWidget)),
      _createExpansionTile(
          ExpandListItem("Organizers", _tournyOrganizerInfoWidget)),
      _createExpansionTile(
          ExpandListItem("Home Page Customization", _tournyHomePageInfoWidget)),
    ];

    return Column(
      children: widgets,
    );
  }

  ExpansionTile _createExpansionTile(ExpandListItem item) {
    return ExpansionTile(
      title: Text(item.title),
      // subtitle: Text('Leading expansion arrow icon'),
      controlAffinity: ListTileControlAffinity.leading,
      initiallyExpanded: false,
      children: <Widget>[item.widget],
    );
  }

  List<Widget> _viewInfos(BuildContext context) {
    return [
      _updateOrDiscard(),
      Divider(),
      _createScoringDetails("Coach Scoring:", _scoringDetails,
          _createIndividualTieBreakers(context, _scoringDetails)),
      Divider(),
      _createCasulatyDetails(),
      Divider(),
      _createSquadDetails(),
      Divider(),
      Divider(),
    ];
  }

  Widget _updateOrDiscard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              // refreshFields = true;
            });
          },
          child: const Text('Discard'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            VoidCallback callback = () async {
              TournamentInfo info = _tournament.info;

              _tournyBasicInfoWidget.updateTournamentInfo(info);
              _tournyOrganizerInfoWidget.updateTournamentInfo(info);
              _tournyHomePageInfoWidget.updateTournamentInfo(info);

              // info.scoringDetails = _scoringDetails;
              // info.casualtyDetails = _casualtyDetails;
              // info.squadDetails = _squadDetails;

              // _trySaveRichText();

              // Handle create vs update tournament
              if (widget.createTournament) {
                ToastUtils.show(context, "Creating Tournament");
                context.read<AppBloc>().add(CreateTournament(context, info));
              } else {
                ToastUtils.show(context, "Updating Tournament Info");
                context
                    .read<AppBloc>()
                    .add(UpdateTournamentInfo(context, info));
              }
            };

            _showDialogToConfirmOverwrite(context, callback);
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  Widget _createIndividualTieBreakers(
      BuildContext context, IndividualScoringDetails details) {
    final theme = Theme.of(context);

    List<String> curTiebreakers = EnumToString.toList(details.tieBreakers);

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
              details.tieBreakers = tieBreakers.nonNulls.toList();
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

  Widget _createScoringDetails(
      String title, ScoringDetails details, Widget? tiebreakerWidget) {
    Row winTieLossPts =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      SizedBox(width: 10.0),
      Text(title),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: details.winPts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Wins',
        callback: (value) => details.winPts = double.parse(value),
      )),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: details.tiePts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Ties',
        callback: (value) => details.tiePts = double.parse(value),
      )),
      SizedBox(width: 10.0),
      Expanded(
          child: CustomTextFormField(
        initialValue: details.lossPts.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        title: 'Losses',
        callback: (value) => details.lossPts = double.parse(value),
      ))
    ]);

    List<Widget> children = [
      winTieLossPts,
      SizedBox(height: 10),
    ];

    if (tiebreakerWidget != null) {
      children.addAll([tiebreakerWidget, SizedBox(height: 10)]);
    }

    children.addAll(_getBonusPtsWidgets(details));

    if (details is IndividualScoringDetails) {
      children.addAll(_getCoachRankingFilterWidgets(details));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  List<Widget> _getBonusPtsWidgets(ScoringDetails details) {
    List<Widget> bonusPtsWidgets = [
      ElevatedButton(
        onPressed: () {
          setState(() {
            String bonusPtsIdx = (details.bonusPts.length + 1).toString();
            details.bonusPts.add(BonusDetails("Bonus_" + bonusPtsIdx, 1));
          });
        },
        child: const Text('Add Bonus'),
      )
    ];

    for (int i = 0; i < details.bonusPts.length; i++) {
      String bonusKey = details.bonusPts[i].name;
      double bonusVal = details.bonusPts[i].weight;

      ValueChanged<String> bonusNameCallback = ((value) {
        details.bonusPts[i] = BonusDetails(value, bonusVal);
      });

      ValueChanged<String> bonusPtsCallback = ((value) {
        details.bonusPts[i] = BonusDetails(bonusKey, double.parse(value));
      });

      bonusPtsWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 10.0),
            IconButton(
                onPressed: () {
                  setState(() {
                    details.bonusPts.removeAt(i);
                  });
                },
                icon: Icon(Icons.delete)),
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: bonusKey.toString(),
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.singleLineFormatter
                    // ],
                    keyboardType: TextInputType.number,
                    title: 'Bonus Name',
                    callback: (value) => bonusNameCallback(value))),
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: bonusVal.toString(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    title: 'Bonus Value',
                    callback: (value) => bonusPtsCallback(value)))
          ]));
    }

    return bonusPtsWidgets;
  }

// TODO: Need to add UI for adding CoachRankingFilters

  List<Widget> _getCoachRankingFilterWidgets(IndividualScoringDetails details) {
    List<Widget> rankingFilterWidgets = [
      ElevatedButton(
        onPressed: () {
          setState(() {
            String idx =
                (_scoringDetails.coachRaceRankingFilters.length + 1).toString();

            _scoringDetails.coachRaceRankingFilters
                .add(CoachRaceFilter("RankingFilter_" + idx, []));
          });
        },
        child: const Text('Add Race Ranking Filter'),
      )
    ];

    for (int i = 0; i < details.coachRaceRankingFilters.length; i++) {
      CoachRaceFilter filter = details.coachRaceRankingFilters[i];

      String label = filter.name;
      List<String> curRaces = EnumToString.toList(filter.races);

      List<String> allRaces = EnumToString.toList(Race.values);

      rankingFilterWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
                child: CustomTextFormField(
                    initialValue: label.toString(),
                    keyboardType: TextInputType.number,
                    title: 'Race Filter Label',
                    callback: (value) {
                      setState(() {
                        details.coachRaceRankingFilters[i].name = label;
                      });
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

                      details.coachRaceRankingFilters[i] =
                          CoachRaceFilter(label, races);

                      setState(() {});
                    }))
          ]));
    }

    return rankingFilterWidgets;
  }

  Widget _createCasulatyDetails() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(width: 10.0),
        Text("Casualty Details:"),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxListTileFormField(
                title: Text('Spp', style: theme.textTheme.labelMedium),
                initialValue: _casualtyDetails.spp,
                onChanged: (value) {
                  _casualtyDetails.spp = value;
                },
                autovalidateMode: AutovalidateMode.always,
                contentPadding: EdgeInsets.all(1))),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxListTileFormField(
          title: Text('Foul', style: theme.textTheme.labelMedium),
          initialValue: _casualtyDetails.foul,
          onChanged: (value) {
            _casualtyDetails.foul = value;
          },
          autovalidateMode: AutovalidateMode.always,
          contentPadding: EdgeInsets.all(1),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxListTileFormField(
          title: Text('Surf', style: theme.textTheme.labelMedium),
          initialValue: _casualtyDetails.surf,
          onChanged: (value) {
            _casualtyDetails.surf = value;
          },
          autovalidateMode: AutovalidateMode.always,
          contentPadding: EdgeInsets.all(1),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxListTileFormField(
          title: Text('Weapon', style: theme.textTheme.labelMedium),
          initialValue: _casualtyDetails.weapon,
          onChanged: (value) {
            _casualtyDetails.weapon = value;
          },
          autovalidateMode: AutovalidateMode.always,
          contentPadding: EdgeInsets.all(1),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxListTileFormField(
          title: Text('Dodge', style: theme.textTheme.labelMedium),
          initialValue: _casualtyDetails.dodge,
          onChanged: (value) {
            _casualtyDetails.dodge = value;
          },
          autovalidateMode: AutovalidateMode.always,
          contentPadding: EdgeInsets.all(1),
        )),
      ],
    );
  }

  Widget _createSquadDetails() {
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
        value: EnumToString.convertToString(_squadDetails.type),
        items: squadUsageTypesDropDown,
        onChanged: (value) {
          SquadUsage? usage = value is String
              ? EnumToString.fromString(SquadUsage.values, value)
              : null;
          _squadDetails.type = usage != null ? usage : SquadUsage.NO_SQUADS;

          // Update UI based on toggle
          setState(() {});
        },
      ))
    ];

    if (_squadDetails.type == SquadUsage.SQUADS) {
      mainSquadDetailsRow.addAll([
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue: _squadDetails.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Active Coaches / Squad',
          callback: (value) =>
              _squadDetails.requiredNumCoachesPerSquad = int.parse(value),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue: _squadDetails.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Max Coaches / Squad',
          callback: (value) =>
              _squadDetails.maxNumCoachesPerSquad = int.parse(value),
        ))
      ]);
    }

    List<Widget> mainContent = [
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: mainSquadDetailsRow)
    ];

    if (_squadDetails.type == SquadUsage.SQUADS) {
      // Update Main Content w/ squad scoring type
      mainContent.addAll([
        SizedBox(height: 10),
        _getSquadScoringSelection(),
        SizedBox(height: 10),
      ]);

      if (_squadDetails.scoringType == SquadScoring.SQUAD_RESULT_W_T_L) {
        // Update Main Content w/ squad scoring parameters
        mainContent.addAll([
          SizedBox(height: 10),
          _createScoringDetails("Squad Scoring:", _squadDetails.scoringDetails,
              _createSquadTieBreakers(context, _squadDetails)),
        ]);
      }

      // Update Main Content w/ squad matching
      mainContent.addAll([
        SizedBox(height: 10),
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
        value: EnumToString.convertToString(_squadDetails.scoringType),
        items: squadScoringTypesDropDown,
        onChanged: (value) {
          SquadScoring? scoringTypes = value is String
              ? EnumToString.fromString(SquadScoring.values, value)
              : null;
          _squadDetails.scoringType = scoringTypes != null
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
        value: EnumToString.convertToString(_squadDetails.matchMaking),
        style: theme.textTheme.labelMedium,
        items: squadMatchMakingTypesDropDown,
        onChanged: (value) {
          SquadMatchMaking? matchMakingType = value is String
              ? EnumToString.fromString(SquadMatchMaking.values, value)
              : null;
          _squadDetails.matchMaking = matchMakingType != null
              ? matchMakingType
              : SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES;
        },
      ))
    ];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: squadMatchMakingRow);
  }

  Widget _createSquadTieBreakers(BuildContext context, SquadDetails details) {
    final theme = Theme.of(context);

    List<String> curTiebreakers = EnumToString.toList(details.squadTieBreakers);

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
              details.squadTieBreakers = tieBreakers.nonNulls.toList();
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

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data. Please confirm!");
    sb.writeln("");
    sb.writeln("NumOrganizers: " +
        _tournyOrganizerInfoWidget.organizers.length.toString() +
        " (Primary: " +
        _tournyOrganizerInfoWidget.organizers
            .where((element) => element.primary)
            .length
            .toString() +
        ")");

    showOkCancelAlertDialog(
            context: context,
            title: "Update Tournament",
            message: sb.toString(),
            okLabel: "Update",
            cancelLabel: "Dismiss")
        .then((value) => {
              if (value == OkCancelResult.ok) {confirmedUpdateCallback()}
              // {_processUpdate(confirmedUpdateCallback)}
            });
  }
}
