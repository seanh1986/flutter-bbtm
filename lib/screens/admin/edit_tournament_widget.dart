import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
  List<DataRow> _coachRows = [];
  late DataTable _coachDataTable;

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
        ExpansionTile(title: Text("Coaches"), children: _viewCoaches()),
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
      _editableTable("Organizers", _orgaDataTable, _addNewOrga),
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
              widget.tournament.info.name = _name;
              widget.tournament.info.location = _location;

              // Remove empty rows
              _organizers.removeWhere((element) =>
                  element.email.trim().isEmpty ||
                  element.nafName.trim().isEmpty);

              widget.tournament.info.organizers = _organizers;

              widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
            },
            child: const Text('Update'),
          )
        ],
      ),
      SizedBox(height: 10),
    ];
  }

  void _initOrgas() {
    // _organizers.removeWhere((element) =>
    //     element.email.trim().isEmpty || element.nafName.trim().isEmpty);

    _organizerRows.clear();

    for (int i = 0; i < _organizers.length; i++) {
      OrganizerInfo orga = _organizers[i];

      TextFormField emailForm = TextFormField(
          initialValue: orga.email, onChanged: (value) => {orga.email = value});

      TextFormField nafNamForm = TextFormField(
          initialValue: orga.nafName,
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
          // emailForm.controller?.value = TextEditingValue(text: "");

          // nafNamForm.controller?.value = TextEditingValue(text: "");

          // primaryCheckbox = Checkbox(
          //   value: false,
          //   onChanged: (value) {
          //     if (value != null) {
          //       setState(() {
          //         if (value) {
          //           _organizers.forEach((element) {
          //             element.primary = false;
          //           });
          //         }
          //         orga.primary = value;
          //       });
          //     }
          //   },
          // );

          // _orgaDataTable = DataTable(
          //   columns: _organizerCols,
          //   rows: _organizerRows,
          // );

          setState(() {
            _organizers.removeAt(i);
          });
        },
        child: const Text('-'),
      );

      _organizerRows.add(DataRow(cells: [
        DataCell(removeOrgaBtn),
        DataCell(emailForm),
        DataCell(nafNamForm),
        DataCell(primaryCheckbox)
      ]));
    }

    _orgaDataTable = DataTable(
      columns: _organizerCols,
      rows: _organizerRows,
    );
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

  Widget _editableTable(
      String title, DataTable dataTable, VoidCallback addRowCallback) {
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                addRowCallback();
              },
              child: const Text('+'),
            )
          ]),
          SizedBox(height: 10),
          dataTable
        ]));
  }

  void _addNewCoach() {
    setState(() {
      _coaches.add(Coach("", "", "", Race.Unknown, "", 0));
    });
  }

  List<Widget> _viewCoaches() {
    _initCoaches();

    return [
      _editableTable("Coaches", _coachDataTable, _addNewCoach),
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
              // Remove empty rows
              _coaches.removeWhere((element) =>
                  element.coachName.trim().isEmpty ||
                  element.nafName.trim().isEmpty);

              widget.tournament.updateCoaches(_coaches);

              widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
            },
            child: const Text('Update'),
          )
        ],
      ),
      SizedBox(height: 10)
    ];
  }

  void _initCoaches() {
    _coachRows.clear();

    for (int i = 0; i < _coaches.length; i++) {
      Coach c = _coaches[i];

      TextFormField nafNameField = TextFormField(
          initialValue: c.nafName, onChanged: (value) => {c.nafName = value});

      // TextFormField squadField = TextFormField(
      //     initialValue: c.squadName,
      //     onChanged: (value) => {c.squadName = value});

      TextFormField coachNameField = TextFormField(
          initialValue: c.coachName,
          onChanged: (value) => {c.coachName = value});

      TextFormField teamNameField = TextFormField(
          initialValue: c.teamName, onChanged: (value) => {c.teamName = value});

      TextFormField nafNumberField = TextFormField(
          initialValue: c.nafNumber.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => {c.teamName = value});

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
          if (value != null) {
            setState(() {
              c.active = value;
            });
          }
        },
      );

      ElevatedButton removeBtn = ElevatedButton(
        onPressed: () {
          setState(() {
            _coaches.removeAt(i);
          });
        },
        child: const Text('-'),
      );

      _coachRows.add(DataRow(cells: [
        DataCell(removeBtn),
        DataCell(coachNameField),
        DataCell(nafNameField),
        DataCell(nafNumberField),
        DataCell(raceField),
        DataCell(teamNameField),
        DataCell(activeCheckbox),
      ]));
    }

    _coachDataTable = DataTable(
      columns: _coachCols,
      rows: _coachRows,
    );
  }
}
