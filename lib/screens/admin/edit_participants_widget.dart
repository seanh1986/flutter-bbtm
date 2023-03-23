import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

class EditParticipantsWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  EditParticipantsWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<EditParticipantsWidget> createState() {
    return _EditParticipantsWidget();
  }
}

class _EditParticipantsWidget extends State<EditParticipantsWidget> {
  late List<Coach> _coaches = [];

  late TournamentBloc _tournyBloc;

  List<DataColumn> _coachCols = [];

  late CoachesDataSource _coachSource;

  late DataTable _coachDataTable;

  late FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    _initFromTournament(widget.tournament);
  }

  void _initFromTournament(Tournament t) {
    _coaches = List.from(t.getCoaches());

    _coachCols = [
      DataColumn(label: Text("Name")),
      DataColumn(label: Text("Naf Name")),
      DataColumn(label: Text("Naf #")),
      DataColumn(label: Text("Race")),
    ];

    if (t.useSquads() || t.useSquadsForInitOnly()) {
      _coachCols.add(DataColumn(label: Text("Squad")));
    }

    _coachCols.addAll([
      DataColumn(label: Text("Team")),
      DataColumn(label: Text("Active")),
      DataColumn(label: Text("")), // For add/remove rows
    ]);
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      TitleBar(title: "Edit Tournament Participants"),
      SizedBox(height: 20),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _viewCoaches(context))
    ]));
  }

  Widget _createCoachTableHeadline() {
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
              child: const Text('Add Coach'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _coaches = List.from(widget.tournament.getCoaches());
                });
              },
              child: const Text('Discard'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                VoidCallback callback = () async {
                  // Remove empty rows
                  _coaches.removeWhere((element) =>
                      element.coachName.trim().isEmpty &&
                      element.nafName.trim().isEmpty);

                  List<RenameNafName> renames =
                      _coachSource.coachIdxNafRenames.values.toList();

                  bool success = await _tournyBloc.overwriteCoaches(
                      widget.tournament.info, _coaches, renames);

                  _showSuccessFailToast(success);
                };

                _showDialogToConfirmOverwrite(context, callback);
              },
              child: const Text('Update'),
            )
          ]),
        ]));
  }

  // Widget _createCoachTable() {
  //   return Container(
  //       padding: const EdgeInsets.all(15),
  //       child: Column(children: [
  //         SizedBox(height: 10),
  //         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //           Column(children: [
  //             Text("Coaches", style: TextStyle(fontSize: 18)),
  //             Text(
  //                 "[Active/Total]: " +
  //                     _coaches
  //                         .where((element) => element.active)
  //                         .length
  //                         .toString() +
  //                     " / " +
  //                     _coaches.length.toString(),
  //                 style: TextStyle(fontSize: 14))
  //           ]),
  //           SizedBox(width: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               _addNewCoach();
  //             },
  //             child: const Text('Add Coach'),
  //           )
  //         ]),
  //         SizedBox(height: 10),
  //         _coachDataTable
  //       ]));
  // }

  void _addNewCoach() {
    setState(() {
      _coaches.add(Coach("", "", "", Race.Unknown, "", 0));
    });
  }

  List<Widget> _viewCoaches(BuildContext context) {
    _initCoaches();

    return [
      SizedBox(height: 10),
      _createCoachTableHeadline(),
      SizedBox(height: 10),
      Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _coachDataTable,
          ))
    ];
  }

  void _initCoaches() {
    // print("Coach List:");
    // for (int i = 0; i < _coaches.length; i++) {
    //   print("[" + i.toString() + "]: " + _coaches[i].coachName);
    // }

    _coachSource = CoachesDataSource(
        useSquad: widget.tournament.useSquads() ||
            widget.tournament.useSquadsForInitOnly(),
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

    _coachDataTable = DataTable(
      columns: _coachCols,
      rows: _getCoachRows(),
    );
  }

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data. Please confirm!");
    sb.writeln("");

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
              if (value == OkCancelResult.ok) {confirmedUpdateCallback()}
            });
  }

  void _showSuccessFailToast(bool success) {
    if (success) {
      ToastUtils.show(fToast, "Update successful.");
    } else {
      ToastUtils.show(fToast, "Update failed.");
    }
  }

  List<DataRow> _getCoachRows() {
    List<DataRow> rows = [];

    _coachSource.coaches.forEachIndexed((index, element) {
      DataRow? row = _coachSource.getRow(index);
      if (row != null) {
        rows.add(row);
      }
    });

    return rows;
  }
}

class RenameNafName {
  final String oldNafName;
  final String newNafName;
  RenameNafName(this.oldNafName, this.newNafName);
}

class CoachesDataSource extends DataTableSource {
  bool useSquad;
  late List<Coach> coaches;
  Function(int, bool)? activeCallback;
  Function(int)? removeItemCallback;

  Map<int, RenameNafName> coachIdxNafRenames = {};

  CoachesDataSource(
      {required this.useSquad,
      required this.coaches,
      this.activeCallback,
      this.removeItemCallback});

  @override
  DataRow? getRow(int index) {
    Coach c = coaches[index];

    print("c_idx: " + index.toString() + " -> " + c.coachName);

    ValueChanged<String> nafNameCallback = (value) {
      RenameNafName? renameNafName = coachIdxNafRenames[index];
      if (renameNafName == null) {
        coachIdxNafRenames.putIfAbsent(
            index, () => RenameNafName(c.nafName, value));
      } else {
        coachIdxNafRenames.update(
            index, (old) => RenameNafName(c.nafName, value));
      }

      c.nafName = value;
    };

    TextEditingController nafNameController =
        TextEditingController(text: c.nafName);
    TextFormField nafNameField = TextFormField(
        controller: nafNameController, onChanged: nafNameCallback);

    TextEditingController squadController =
        TextEditingController(text: c.squadName);
    TextFormField squadField = TextFormField(
        controller: squadController,
        onChanged: (value) => {c.squadName = squadController.text});

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
        c.race = RaceUtils.getRace(value);
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

    List<DataCell> cells = [
      DataCell(coachNameField),
      DataCell(nafNameField),
      DataCell(nafNumberField),
      DataCell(raceField),
    ];

    if (useSquad) {
      cells.add(DataCell(squadField));
    }

    cells.addAll([
      DataCell(teamNameField),
      DataCell(activeCheckbox),
      DataCell(removeBtn),
    ]);

    return DataRow(cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => coaches.length;

  @override
  int get selectedRowCount => 0;
}
