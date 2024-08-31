import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
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
import 'package:flutter_quill/flutter_quill.dart';

class EditTournamentInfoWidget extends StatefulWidget {
  // Optional can supply tournament object for population (e.g., create tournament)
  final Tournament? tournament;
  final bool createTournament;

  EditTournamentInfoWidget(
      {Key? key, this.tournament, this.createTournament = false})
      : super(key: key);

  @override
  State<EditTournamentInfoWidget> createState() {
    return _EditTournamentInfoWidget();
  }
}

class _EditTournamentInfoWidget extends State<EditTournamentInfoWidget> {
  late String _name;
  late String _location;
  late List<OrganizerInfo> _organizers = [];
  late IndividualScoringDetails _scoringDetails;

  late CasualtyDetails _casualtyDetails;
  late SquadDetails _squadDetails;

  late DateTime? _startDate;
  late DateTime? _endDate;

  bool refreshFields = true;
  bool editDates = false;

  bool editIndividualTieBreakers = false;
  bool editSquadTieBreakers = false;

  List<DataColumn> _organizerCols = [
    DataColumn(label: Text("")), // For add/remove rows
    DataColumn(label: Text("Email")),
    DataColumn(label: Text("NafName")),
    DataColumn(label: Text("Primary")),
  ];
  List<DataRow> _organizerRows = [];
  late DataTable _orgaDataTable;

  late Tournament _tournament;

  QuillController _richTextSpecialRulesController = QuillController.basic();
  QuillController _richTextWeatherController = QuillController.basic();
  QuillController _richTextKickOffController = QuillController.basic();

  @override
  void initState() {
    super.initState();

    _tryReloadRichText();
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

    if (refreshFields) {
      _name = _tournament.info.name;
      _location = _tournament.info.location;
      _organizers = _tournament.info.organizers;
      _scoringDetails = _tournament.info.scoringDetails;
      _casualtyDetails = _tournament.info.casualtyDetails;
      _squadDetails = _tournament.info.squadDetails;
      _startDate = _tournament.info.dateTimeStart;
      _endDate = _tournament.info.dateTimeEnd;
      _tryReloadRichText();
    }

    // Initialize to false after loading
    refreshFields = false;

    return Column(children: [
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
      Container(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _viewInfos(context)),
      )),
    ]);
  }

  void _addNewOrga() {
    setState(() {
      _organizers.add(OrganizerInfo("", "", false));
    });
  }

  List<Widget> _viewInfos(BuildContext context) {
    _initOrgas();

    return [
      _updateOrDiscard(),
      Divider(),
      CustomTextFormField(
        initialValue: _name,
        title: 'Tournament Name',
        callback: (value) {
          _name = value;
        },
      ),
      CustomTextFormField(
        initialValue: _location,
        title: 'Tournament Location (City, Province)',
        callback: (value) {
          _location = value;
        },
      ),
      Divider(),
      _createStartEndDateUi(),
      Divider(),
      _createOrgaTable(),
      Divider(),
      _createScoringDetails("Coach Scoring:", _scoringDetails,
          _createIndividualTieBreakers(context, _scoringDetails)),
      Divider(),
      _createCasulatyDetails(),
      Divider(),
      _createSquadDetails(),
      Divider(),
      _getRichTextEditor("Special Rules", _richTextSpecialRulesController),
      Divider(),
      _getRichTextEditor("Kick-Off Rules", _richTextKickOffController),
      Divider(),
      _getRichTextEditor("Weather Rules", _richTextWeatherController),
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
              refreshFields = true;
              _name = _tournament.info.name;
              _location = _tournament.info.location;
              _organizers = _tournament.info.organizers;
              _tryReloadRichText();
            });
          },
          child: const Text('Discard'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            VoidCallback callback = () async {
              TournamentInfo info = _tournament.info;

              info.name = _name;
              info.location = _location;

              // Remove empty rows
              _organizers.removeWhere((element) =>
                  element.email.trim().isEmpty ||
                  element.nafName.trim().isEmpty);

              info.organizers = _organizers;

              info.scoringDetails = _scoringDetails;
              info.casualtyDetails = _casualtyDetails;
              info.squadDetails = _squadDetails;

              if (_startDate != null) {
                info.dateTimeStart = _startDate!;
              }
              if (_endDate != null) {
                info.dateTimeEnd = _endDate!;
              }

              _trySaveRichText();

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

  void _initOrgas() {
    _organizerRows.clear();

    for (int i = 0; i < _organizers.length; i++) {
      OrganizerInfo orga = _organizers[i];

      TextEditingController emailController =
          TextEditingController(text: orga.email);
      TextFormField emailForm = TextFormField(
          controller: emailController,
          onChanged: (value) => {orga.email = value});

      TextEditingController nafNameController =
          TextEditingController(text: orga.nafName);
      TextFormField nafNameForm = TextFormField(
          controller: nafNameController,
          onChanged: (value) {
            orga.nafName = value;
          });

      Checkbox primaryCheckbox = Checkbox(
        value: orga.primary,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (value) {
                _organizers.forEach((element) {
                  element.primary = false;
                });
              }
              orga.primary = value;
            });
          }
        },
      );

      ElevatedButton removeOrgaBtn = ElevatedButton(
        onPressed: () {
          setState(() {
            _organizers.removeAt(i);
          });
        },
        child: const Text('-'),
      );

      _organizerRows.add(DataRow(cells: [
        DataCell(removeOrgaBtn),
        DataCell(emailForm),
        DataCell(nafNameForm),
        DataCell(primaryCheckbox),
      ]));
    }

    _orgaDataTable = DataTable(
      columns: _organizerCols,
      rows: _organizerRows,
    );
  }

  Widget _createStartEndDateUi() {
    bool hasStart = _startDate != null;

    if (editDates || !hasStart) {
      return _dateSelector();
    }

    final theme = Theme.of(context);

    bool hasEnd = _endDate != null || _endDate == _startDate;

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    return Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                editDates = true;
              });
            },
            icon: const Icon(Icons.edit)),
        Text(hasEnd ? "Dates: " : "Date: ", style: theme.textTheme.bodyMedium),
        Text(dateFormat.format(_startDate!), style: theme.textTheme.bodyMedium),
        Text(hasEnd ? " - " + dateFormat.format(_endDate!) : "",
            style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _dateSelector() {
    return Column(
      children: [
        CustomDateFormField(
          initialValue: PickerDateRange(_startDate, _endDate),
          callback: (arg) {
            _onDatePickerSelectionChanged(arg);
          },
        ),
        TextButton(
            onPressed: () {
              setState(() {
                editDates = false;
              });
            },
            child: Text(
              "Ok",
              style: Theme.of(context).textTheme.displaySmall,
            ))
      ],
    );
  }

  Widget _createOrgaTable() {
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Text("Organizers", style: TextStyle(fontSize: 18)),
              Text(
                  "[Primary/Total]: " +
                      _organizers
                          .where((element) => element.primary)
                          .length
                          .toString() +
                      " / " +
                      _organizers.length.toString(),
                  style: TextStyle(fontSize: 14))
            ]),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _addNewOrga();
              },
              child: const Text('Add Organizer'),
            )
          ]),
          SizedBox(height: 10),
          _orgaDataTable
        ]));
  }

  void _onDatePickerSelectionChanged(DateRangePickerSelectionChangedArgs arg) {
    if (arg.value is PickerDateRange) {
      _startDate = arg.value.startDate;
      _endDate = arg.value.endDate;

      setState(() {});
    } else if (arg.value is DateTime) {
      _startDate = arg.value;
      _endDate = arg.value;

      setState(() {});
    }
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

  Widget _getRichTextEditor(String title, QuillController controller) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(title, style: theme.textTheme.bodyLarge),
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
        QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            controller: controller,
            // readOnly: false,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
      ],
    );
  }

  void _tryReloadRichText() {
    try {
      final json = jsonDecode(_tournament.info.detailsSpecialRules);
      final doc = Document.fromJson(json);
      _richTextSpecialRulesController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}

    try {
      final json = jsonDecode(_tournament.info.detailsKickOff);
      final doc = Document.fromJson(json);
      _richTextKickOffController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}

    try {
      final json = jsonDecode(_tournament.info.detailsWeather);
      final doc = Document.fromJson(json);
      _richTextWeatherController = QuillController(
          document: doc, selection: TextSelection.collapsed(offset: 0));
    } catch (_) {}
  }

  void _trySaveRichText() {
    var jsonSpecialRules =
        jsonEncode(_richTextSpecialRulesController.document.toDelta().toJson());
    var jsonKickOff =
        jsonEncode(_richTextKickOffController.document.toDelta().toJson());
    var jsonWeather =
        jsonEncode(_richTextWeatherController.document.toDelta().toJson());

    _tournament.info.detailsSpecialRules = jsonSpecialRules;
    _tournament.info.detailsKickOff = jsonKickOff;
    _tournament.info.detailsWeather = jsonWeather;
  }

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data. Please confirm!");
    sb.writeln("");
    sb.writeln("NumOrganizers: " +
        _organizers.length.toString() +
        " (Primary: " +
        _organizers.where((element) => element.primary).length.toString() +
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
