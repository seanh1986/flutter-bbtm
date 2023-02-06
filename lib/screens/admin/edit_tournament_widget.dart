import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTournamentWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  EditTournamentWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<EditTournamentWidget> createState() {
    return _EditTournamentWidget();
  }
}

enum EditTournamentSections {
  None,
  Info,
  Coaches,
  Squads,
  Rounds,
}

enum ViewState {
  Expanded,
  Compressed,
}

class _EditTournamentWidget extends State<EditTournamentWidget> {
  EditTournamentSections expandedState = EditTournamentSections.None;

  late String _name;
  late String _location;
  late List<OrganizerInfo> _organizers = [];
  late List<Coach> _coaches = [];

  List<DataColumn> _organizerCols = [
    DataColumn(label: Text("")), // For add/remove rows
    DataColumn(label: Text("Email")),
    DataColumn(label: Text("NafName")),
    DataColumn(label: Text("Primary")),
  ];
  List<DataRow> _organizerRows = [];
  late DataTable _orgaDataTable;

  List<DataColumn> _coachCols = [
    DataColumn(label: Text("")), // For add/remove rows
    // DataColumn(label: Text("Squad")),
    DataColumn(label: Text("Name")),
    DataColumn(label: Text("Naf Name")),
    DataColumn(label: Text("Naf #")),
    DataColumn(label: Text("Race")),
    DataColumn(label: Text("Team")),
    DataColumn(label: Text("Active")),
  ];

  late PaginatedDataTable _coachDataTable;

  @override
  void initState() {
    super.initState();

    _name = widget.tournament.info.name;
    _location = widget.tournament.info.location;
    _organizers = widget.tournament.info.organizers;

    _coaches = widget.tournament.getCoaches();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Tournament Details"),
      subtitle: Text("Edit information/details, coaches, squads, etc."),
      children: [
        ExpansionTile(title: Text("Info"), children: _viewInfos()),
        ExpansionTile(title: Text("Coaches"), children: _viewCoaches(context)),
      ],
    );
  }

  void _addNewOrga() {
    setState(() {
      _organizers.add(OrganizerInfo("", "", false));
    });
  }

  List<Widget> _viewInfos() {
    _initOrgas();

    return [
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
      _createOrgaTable(),
      // CustomDateFormField(
      //   initialValue: PickerDateRange(
      //       widget.tournament.info.dateTimeStart,
      //       widget.tournament.info.dateTimeEnd),
      //   callback: (arg) => _onDatePickerSelectionChanged,
      // ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _name = widget.tournament.info.name;
                _location = widget.tournament.info.location;
                _organizers = widget.tournament.info.organizers;
              });
            },
            child: const Text('Discard'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              VoidCallback callback = () {
                widget.tournament.info.name = _name;
                widget.tournament.info.location = _location;

                // Remove empty rows
                _organizers.removeWhere((element) =>
                    element.email.trim().isEmpty ||
                    element.nafName.trim().isEmpty);

                widget.tournament.info.organizers = _organizers;
              };

              _showDialogToConfirmOverwrite(context, callback);
            },
            child: const Text('Update'),
          )
        ],
      ),
      SizedBox(height: 10),
    ];
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
                _addNewCoach();
              },
              child: const Text('Add Row'),
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

  Widget _createCoachTable() {
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Text("Coaches", style: TextStyle(fontSize: 18)),
              Text(
                  "[Active/Total]: " +
                      _coaches
                          .where((element) => element.active)
                          .length
                          .toString() +
                      " / " +
                      _coaches.length.toString(),
                  style: TextStyle(fontSize: 14))
            ]),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _addNewCoach();
              },
              child: const Text('Add Row'),
            )
          ]),
          SizedBox(height: 10),
          _coachDataTable
        ]));
  }

  void _addNewCoach() {
    setState(() {
      _coaches.add(Coach("", "", "", Race.Unknown, "", 0));
    });
  }

  List<Widget> _viewCoaches(BuildContext context) {
    _initCoaches();

    return [
      _createCoachTable(),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _coaches = widget.tournament.getCoaches();
              });
            },
            child: const Text('Discard'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              VoidCallback callback = () {
                // Remove empty rows
                _coaches.removeWhere((element) =>
                    element.coachName.trim().isEmpty &&
                    element.nafName.trim().isEmpty);

                widget.tournament.updateCoaches(_coaches);
              };

              _showDialogToConfirmOverwrite(context, callback);
            },
            child: const Text('Update'),
          )
        ],
      ),
      SizedBox(height: 10)
    ];
  }

  void _initCoaches() {
    print("Coach List:");
    for (int i = 0; i < _coaches.length; i++) {
      print("[" + i.toString() + "]: " + _coaches[i].coachName);
    }

    CoachesDataSource coachSource = CoachesDataSource(
        coaches: _coaches,
        activeCallback: (cIdx, active) {
          setState(() {
            _coaches[cIdx].active = active;
          });
        },
        removeItemCallback: (cIdx) {
          setState(() {
            _coaches.removeAt(cIdx);
          });
        });

    _coachDataTable = PaginatedDataTable(
      columns: _coachCols,
      source: coachSource,
    );
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

    sb.writeln("NumCoaches: " +
        _coaches.length.toString() +
        " (Active: " +
        _coaches.where((element) => element.active).length.toString() +
        ")");

    showOkCancelAlertDialog(
            context: context,
            title: "Update Tournament",
            message: sb.toString(),
            okLabel: "Update",
            cancelLabel: "Dismiss")
        .then((value) => {
              if (value == OkCancelResult.ok)
                {_processUpdate(confirmedUpdateCallback)}
            });
  }

  void _processUpdate(VoidCallback confirmedUpdateCallback) {
    confirmedUpdateCallback();
    widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
  }
}

class CoachesDataSource extends DataTableSource {
  late List<Coach> coaches;
  Function(int, bool)? activeCallback;
  Function(int)? removeItemCallback;

  CoachesDataSource(
      {required this.coaches, this.activeCallback, this.removeItemCallback});

  @override
  DataRow? getRow(int index) {
    Coach c = coaches[index];

    print("c_idx: " + index.toString() + " -> " + c.coachName);

    TextEditingController nafNameController =
        TextEditingController(text: c.nafName);
    TextFormField nafNameField = TextFormField(
        controller: nafNameController,
        onChanged: (value) => {c.nafName = nafNameController.text});

    TextEditingController coachNameController =
        TextEditingController(text: c.coachName);
    TextFormField coachNameField = TextFormField(
        controller: coachNameController,
        onChanged: (value) => {c.coachName = coachNameController.text});

    TextEditingController teamNameController =
        TextEditingController(text: c.teamName);
    TextFormField teamNameField = TextFormField(
        controller: teamNameController,
        onChanged: (value) => {c.teamName = teamNameController.text});

    TextEditingController nafNumberController =
        TextEditingController(text: c.nafNumber.toString());
    TextFormField nafNumberField = TextFormField(
        controller: nafNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) =>
            {c.nafNumber = int.parse(nafNumberController.text)});

    List<DropdownMenuItem> raceDropDown = Race.values
        .map((Race r) => RaceUtils.getName(r))
        .map((String r) => DropdownMenuItem(value: r, child: Text(r)))
        .toList();

    DropdownButtonFormField raceField = DropdownButtonFormField(
      value: c.raceName(),
      items: raceDropDown,
      onChanged: (value) {
        c.setRace(RaceUtils.getRace(value));
      },
    );

    Checkbox activeCheckbox = Checkbox(
      value: c.active,
      onChanged: (value) {
        if (value != null && activeCallback != null) {
          activeCallback!(index, value);
        }
      },
    );

    ElevatedButton removeBtn = ElevatedButton(
      onPressed: () {
        coaches.removeAt(index);
        if (removeItemCallback != null) {
          removeItemCallback!(index);
        }
      },
      child: const Text('-'),
    );

    return DataRow(cells: [
      DataCell(removeBtn),
      DataCell(coachNameField),
      DataCell(nafNameField),
      DataCell(nafNumberField),
      DataCell(raceField),
      DataCell(teamNameField),
      DataCell(activeCheckbox),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => coaches.length;

  @override
  int get selectedRowCount => 0;
}
