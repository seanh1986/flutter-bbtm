import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditTournamentWidget extends StatefulWidget {
  final Tournament tournament;

  EditTournamentWidget({Key? key, required this.tournament}) : super(key: key);

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

  // /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  // /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  // late final PlutoGridStateManager stateManager;

  // List<PlutoColumn> _organizerCols = [
  //   PlutoColumn(title: "Email", field: "email", type: PlutoColumnType.text()),
  //   PlutoColumn(
  //       title: "Nafname", field: "nafname", type: PlutoColumnType.text()),
  //   PlutoColumn(
  //       title: "Primary",
  //       field: "primary",
  //       type: PlutoColumnType.select(<String>['Yes', 'No'])),
  // ];

  List<DataColumn> _organizerCols = [
    DataColumn(label: Text("Email")),
    DataColumn(label: Text("NafName")),
    DataColumn(label: Text("Primary")),
  ];

  List<DataRow> _organizerRows = [];

  @override
  void initState() {
    super.initState();

    _name = widget.tournament.info.name;
    _location = widget.tournament.info.location;
    _organizers = widget.tournament.info.organizers;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Tournament Details"),
      subtitle: Text("Edit information/details, coaches, squads, etc."),
      children: [
        ExpansionTile(title: Text("Info"), children: _viewInfos()),
        ExpansionTile(title: Text("Coaches"), children: [_viewCoaches()]),
      ],
    );
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
      _editableTable("Organizers", _organizerCols, _organizerRows),
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
              });
            },
            child: const Text('Discard'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              widget.tournament.info.name = _name;
              widget.tournament.info.location = _location;
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

      _organizerRows.add(DataRow(cells: [
        DataCell(TextFormField(
            initialValue: orga.email,
            onChanged: (value) => {
                  setState(() {
                    orga.email = value;
                  })
                })),
        DataCell(TextFormField(
            initialValue: orga.nafName,
            onChanged: (value) {
              setState(() {
                orga.nafName = value;
              });
            })),
        DataCell(Checkbox(
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
        ))
      ]));
    }
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
      String title, List<DataColumn> cols, List<DataRow> rows) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: DataTable(
        columns: cols,
        rows: rows,
      ),
    );
  }

  Widget _viewCoaches() {
    return Text("Coaches!");
  }
}
