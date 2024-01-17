import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditTournamentInfoWidget extends StatefulWidget {
  EditTournamentInfoWidget({Key? key}) : super(key: key);

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

  List<DataColumn> _organizerCols = [
    DataColumn(label: Text("")), // For add/remove rows
    DataColumn(label: Text("Email")),
    DataColumn(label: Text("NafName")),
    DataColumn(label: Text("Primary")),
  ];
  List<DataRow> _organizerRows = [];
  late DataTable _orgaDataTable;

  late FToast fToast;

  late Tournament _tournament;

  bool _initVars = true;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;

    if (_initVars) {
      _name = _tournament.info.name;
      _location = _tournament.info.location;
      _organizers = _tournament.info.organizers;
      _scoringDetails = _tournament.info.scoringDetails;
      _casualtyDetails = _tournament.info.casualtyDetails;
      _squadDetails = _tournament.info.squadDetails;
    }

    return Column(children: [
      TitleBar(title: "Edit Tournament Info"),
      SizedBox(height: 20),
      Column(
          mainAxisAlignment: MainAxisAlignment.center, children: _viewInfos())
    ]);
  }

  void _addNewOrga() {
    setState(() {
      _organizers.add(OrganizerInfo("", "", false));
    });
  }

  List<Widget> _viewInfos() {
    _initOrgas();

    return [
      _updateOrDiscard(),
      Divider(),
      CustomTextFormField(
        initialValue: _name,
        title: 'Tournament Name',
        callback: (value) => _name = value,
      ),
      CustomTextFormField(
        initialValue: _location,
        title: 'Tournament Location (City, Province)',
        callback: (value) => _location = value,
      ),
      Divider(),
      _createOrgaTable(),
      // CustomDateFormField(
      //   initialValue: PickerDateRange(
      //       widget.tournament.info.dateTimeStart,
      //       widget.tournament.info.dateTimeEnd),
      //   callback: (arg) => _onDatePickerSelectionChanged,
      // ),
      Divider(),
      _createScoringDetails("Coach Scoring:", _scoringDetails),
      Divider(),
      _createCasulatyDetails(_casualtyDetails),
      Divider(),
      _createSquadDetails(_squadDetails),
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
              _initVars = false;
              _name = _tournament.info.name;
              _location = _tournament.info.location;
              _organizers = _tournament.info.organizers;
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

              ToastUtils.show(fToast, "Updating Tournament Info");

              context.read<AppBloc>().add(UpdateTournamentInfo(context, info));
              // LoadingIndicatorDialog().show(context);
              // bool success =
              //     await widget.tournyBloc.overwriteTournamentInfo(info);
              // LoadingIndicatorDialog().dismiss();

              // _showSuccessFailToast(success);
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
        DataCell(primaryCheckbox)
      ]));
    }

    _orgaDataTable = DataTable(
      columns: _organizerCols,
      rows: _organizerRows,
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

  // void _onDatePickerSelectionChanged(DateRangePickerSelectionChangedArgs arg) {
  //   if (arg.value is PickerDateRange) {
  //     widget.tournament.info.dateTimeStart = arg.value.startDate;
  //     widget.tournament.info.dateTimeEnd = arg.value.endDate;
  //   } else if (arg.value is DateTime) {
  //     widget.tournament.info.dateTimeStart = arg.value;
  //     widget.tournament.info.dateTimeEnd = arg.value;
  //   }
  // }

  Widget _createIndividualScoringDetails(
      String title, IndividualScoringDetails details) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _createScoringDetails(title, details),
      SizedBox(height: 10),
    ]);
  }

  // Widget _createIndividualTieBreakers(
  //     String title, IndividualScoringDetails details) {
  //   List<String> allTiebreakers = EnumToString.toList(TieBreaker.values);

  //   List<DropdownMenuItem<String>> squadUsageTypesDropDown = squadUsageTypes
  //       .map((String r) => DropdownMenuItem<String>(value: r, child: Text(r)))
  //       .toList();

  //   return Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: <Widget>[
  //         SizedBox(width: 10.0),
  //         Text(title),
  //         SizedBox(width: 10.0),
  //         Expanded(
  //           child: Column(children: [],),
  //         )
  //       ]);

  //   ReorderableListView(
  //     padding: const EdgeInsets.symmetric(horizontal: 40),
  //     proxyDecorator: proxyDecorator,
  //     children: <Widget>[
  //       for (int index = 0; index < _items.length; index += 1)
  //         ListTile(
  //           key: Key('$index'),
  //           tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
  //           title: Text('Item ${_items[index]}'),
  //         ),
  //     ],
  //     onReorder: (int oldIndex, int newIndex) {
  //       setState(() {
  //         if (oldIndex < newIndex) {
  //           newIndex -= 1;
  //         }
  //         final String item = _items.removeAt(oldIndex);
  //         _items.insert(newIndex, item);
  //       });
  //     },
  //   );
  // }

  Widget _createScoringDetails(String title, ScoringDetails details) {
    Row winTieLossPts = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
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
            callback: (value) => details.tiePts = double.parse(value),
          ))
        ]);

    List<Widget> bonusPtsWidgets = [
      ElevatedButton(
        onPressed: () {
          setState(() {
            String bonusPtsIdx =
                (_scoringDetails.bonusPts.length + 1).toString();
            _scoringDetails.bonusPts
                .add(BonusDetails("Bonus_" + bonusPtsIdx, 1));
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

    List<Widget> children = [winTieLossPts, SizedBox(height: 5)];

    children.addAll(bonusPtsWidgets);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  Widget _createCasulatyDetails(CasualtyDetails details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(width: 10.0),
        Text("Casualty Details:"),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxFormField(
          title: Text('Spp'),
          initialValue: details.spp,
          onSaved: (value) => details.spp = value != null && value,
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxFormField(
          title: Text('Foul'),
          initialValue: details.foul,
          onSaved: (value) => details.foul = value != null && value,
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxFormField(
          title: Text('Surf'),
          initialValue: details.surf,
          onSaved: (value) => details.surf = value != null && value,
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxFormField(
          title: Text('Weapon'),
          initialValue: details.weapon,
          onSaved: (value) => details.weapon = value != null && value,
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CheckboxFormField(
          title: Text('Dodge'),
          initialValue: details.dodge,
          onSaved: (value) => details.dodge = value != null && value,
        )),
      ],
    );
  }

  Widget _createSquadDetails(SquadDetails details) {
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
        value: EnumToString.convertToString(details.type),
        items: squadUsageTypesDropDown,
        onChanged: (value) {
          SquadUsage? usage = value is String
              ? EnumToString.fromString(SquadUsage.values, value)
              : null;
          details.type = usage != null ? usage : SquadUsage.NO_SQUADS;

          // Update UI based on toggle
          setState(() {
            _squadDetails = details;
          });
        },
      ))
    ];

    if (details.type == SquadUsage.SQUADS) {
      mainSquadDetailsRow.addAll([
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue: details.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Active Coaches / Squad',
          callback: (value) =>
              details.requiredNumCoachesPerSquad = int.parse(value),
        )),
        SizedBox(width: 10.0),
        Expanded(
            child: CustomTextFormField(
          initialValue: details.requiredNumCoachesPerSquad.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          title: '# Max Coaches / Squad',
          callback: (value) => details.maxNumCoachesPerSquad = int.parse(value),
        ))
      ]);
    }

    List<Widget> mainContent = [
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: mainSquadDetailsRow)
    ];

    if (details.type == SquadUsage.SQUADS) {
      // Update Main Content w/ squad scoring type
      mainContent.addAll([
        SizedBox(height: 10),
        _getSquadScoringSelection(details),
      ]);

      if (details.scoringType == SquadScoring.SQUAD_RESULT_W_T_L) {
        // Update Main Content w/ squad scoring parameters
        mainContent.addAll([
          SizedBox(height: 10),
          _createScoringDetails("Squad Scoring:", _squadDetails.scoringDetails),
        ]);
      }

      // Update Main Content w/ squad matching
      mainContent.addAll([
        SizedBox(height: 10),
        _getSquadMatchingSelection(details),
      ]);
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: mainContent);
  }

  Row _getSquadScoringSelection(SquadDetails details) {
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
        value: EnumToString.convertToString(details.scoringType),
        items: squadScoringTypesDropDown,
        onChanged: (value) {
          SquadScoring? scoringTypes = value is String
              ? EnumToString.fromString(SquadScoring.values, value)
              : null;
          details.scoringType = scoringTypes != null
              ? scoringTypes
              : SquadScoring.CUMULATIVE_PLAYER_SCORES;

          setState(() {
            _squadDetails = details;
          });
        },
      ))
    ];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: squadScoringRow);
  }

  Row _getSquadMatchingSelection(SquadDetails details) {
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
        value: EnumToString.convertToString(details.matchMaking),
        items: squadMatchMakingTypesDropDown,
        onChanged: (value) {
          SquadMatchMaking? matchMakingType = value is String
              ? EnumToString.fromString(SquadMatchMaking.values, value)
              : null;
          details.matchMaking = matchMakingType != null
              ? matchMakingType
              : SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES;
        },
      ))
    ];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: squadMatchMakingRow);
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

  void _showSuccessFailToast(bool success) {
    if (success) {
      ToastUtils.show(fToast, "Update successful.");
    } else {
      ToastUtils.show(fToast, "Update failed.");
    }
  }
}
