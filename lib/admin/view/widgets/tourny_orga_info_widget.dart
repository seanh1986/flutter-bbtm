// ignore_for_file: must_be_immutable

import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';
import 'package:flutter/material.dart';

class TournyOrganizerInfoWidget extends StatefulWidget {
  late List<OrganizerInfo> organizers;

  TournyOrganizerInfoWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.organizers = info.organizers;
  }

  @override
  State<TournyOrganizerInfoWidget> createState() {
    return _TournyBasicInfoWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    // Remove empty rows
    organizers.removeWhere((element) =>
        element.email.trim().isEmpty || element.nafName.trim().isEmpty);

    info.organizers = organizers;
  }
}

class _TournyBasicInfoWidget extends State<TournyOrganizerInfoWidget> {
  List<DataColumn> _organizerCols = [
    DataColumn(label: Text("")), // For add/remove rows
    DataColumn(label: Text("Email")),
    DataColumn(label: Text("NafName")),
    DataColumn(label: Text("Primary")),
  ];
  List<DataRow> _organizerRows = [];
  late DataTable _orgaDataTable;

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
    _initOrgas();

    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Text("Organizers", style: TextStyle(fontSize: 18)),
              Text(
                  "[Primary/Total]: " +
                      widget.organizers
                          .where((element) => element.primary)
                          .length
                          .toString() +
                      " / " +
                      widget.organizers.length.toString(),
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

  void _initOrgas() {
    _organizerRows.clear();

    for (int i = 0; i < widget.organizers.length; i++) {
      OrganizerInfo orga = widget.organizers[i];

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
                widget.organizers.forEach((element) {
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
            widget.organizers.removeAt(i);
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

  void _addNewOrga() {
    setState(() {
      widget.organizers.add(OrganizerInfo("", "", false));
    });
  }
}
