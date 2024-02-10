import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/excel/coach_import_export.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';

class EditParticipantsWidget extends StatefulWidget {
  EditParticipantsWidget({Key? key}) : super(key: key);

  @override
  State<EditParticipantsWidget> createState() {
    return _EditParticipantsWidget();
  }
}

class _EditParticipantsWidget extends State<EditParticipantsWidget> {
  late List<Coach> _coaches = [];

  List<DataColumn2> _coachCols = [];

  late CoachesDataSource _coachSource;

  late DataTable2 _coachDataTable;

  late FToast fToast;

  late Tournament _tournament;

  bool initCoaches = true;

  int? _editIdx;
  Map<int, RenameNafName>? _coachIdxNafRenames;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);
  }

  void _initFromTournament() {
    _coachCols = [
      DataColumn2(
          label: Text("Edit | Remove | Active"),
          size: ColumnSize.S), // Edit Button, Active
      DataColumn2(label: Text("Name")),
      DataColumn2(label: Text("Naf")),
      DataColumn2(label: Text("Team")),
    ];

    if (_tournament.useSquads() || _tournament.useSquadsForInitOnly()) {
      _coachCols.add(DataColumn2(label: Text("Squad")));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _initFromTournament();

    if (initCoaches) {
      _coaches = _tournament.getCoaches().map((c) => Coach.from(c)).toList();
    }

    return Column(children: [
      TitleBar(title: "Edit Tournament Participants"),
      SizedBox(height: 20),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _viewCoaches(context))
    ]);
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
                  _coaches = List.from(_tournament.getCoaches());
                  initCoaches = false;
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

                  context
                      .read<AppBloc>()
                      .add(UpdateCoaches(_tournament.info, _coaches, renames));
                  // LoadingIndicatorDialog().show(context);
                  // bool success = await _tournyBloc.overwriteCoaches(
                  //     _tournament.info, _coaches, renames);
                  // LoadingIndicatorDialog().dismiss();

                  // _showSuccessFailToast(success);
                };

                _showDialogToConfirmOverwrite(context, callback);
              },
              child: const Text('Update'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                CoachImportExport coachImportExport = CoachImportExport();
                coachImportExport.import().then((importedCoaches) {
                  if (importedCoaches.isEmpty) {
                    ToastUtils.show(
                        fToast, "Failed to import coaches (NumberFound: 0)");
                    return;
                  }

                  StringBuffer sb = new StringBuffer();

                  sb.writeln(
                      "Warning this will overwrite existing coach data. Not recommended once tournament has begun! Please confirm!");
                  sb.writeln("");

                  sb.writeln("Imported NumCoaches: " +
                      importedCoaches.length.toString() +
                      " (Active: " +
                      _coaches
                          .where((element) => element.active)
                          .length
                          .toString() +
                      ")");

                  showOkCancelAlertDialog(
                          context: context,
                          title: "Import Coaches",
                          message: sb.toString(),
                          okLabel: "Import",
                          cancelLabel: "Dismiss")
                      .then((value) => {
                            if (value == OkCancelResult.ok)
                              {
                                context.read<AppBloc>().add(UpdateCoaches(
                                    _tournament.info, importedCoaches, []))
                              }
                          });
                });
              },
              child: const Text('Import from File'),
            )
          ]),
        ]));
  }

  void _addNewCoach() {
    setState(() {
      _editIdx = _coaches.length; // soon to be added last one
      _coaches.add(Coach("", "", "", Race.Unknown, "", 0));
      initCoaches = false;
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
          child: _coachDataTable)
    ];
  }

  void _initCoaches() {
    final theme = Theme.of(context);

    _coachSource = CoachesDataSource(
        theme: theme,
        useSquad: _tournament.useSquads() || _tournament.useSquadsForInitOnly(),
        originalCoaches: _coaches,
        editIdx: _editIdx,
        coachIdxNafRenames: _coachIdxNafRenames,
        editCallback: (cIdx, doneEdit, newCoaches, coachIdxNafRenames) {
          setState(() {
            initCoaches = false;
            if (doneEdit) {
              _editIdx = null;
            } else {
              _editIdx = cIdx;
            }
            _coaches = newCoaches;
            _coachIdxNafRenames = coachIdxNafRenames;
          });
        },
        activeCallback: (cIdx, active) {
          setState(() {
            _coaches[cIdx].active = active;
            initCoaches = false;
          });
        },
        removeItemCallback: (nafName) {
          _coaches.removeWhere((c) => c.nafName == nafName);
          setState(() {
            _coaches = _coaches;
            initCoaches = false;
            _editIdx = null;
          });
        });

    _coachDataTable = DataTable2(
      isHorizontalScrollBarVisible: true,
      isVerticalScrollBarVisible: true,
      columnSpacing: 12,
      horizontalMargin: 12,
      border: TableBorder.all(),
      dividerThickness: 1, // this one will be ignored if [border] is set above
      fixedTopRows: 1,
      bottomMargin: 10,
      minWidth: 900,
      empty: Center(
          child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[200],
              child: const Text('No data yet'))),
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

  List<DataRow2> _getCoachRows() {
    List<DataRow2> rows = [];

    _coachSource.newCoaches.forEachIndexed((index, element) {
      DataRow2? row = _coachSource.getRow(index);
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
  List<Coach> originalCoaches;
  List<Coach> newCoaches;

  Function(int, bool, List<Coach>, Map<int, RenameNafName>)
      editCallback; // true if done with edit mode
  Function(int, bool)? activeCallback;
  Function(String)? removeItemCallback;

  int? editIdx;

  Map<int, RenameNafName> coachIdxNafRenames = {};

  ThemeData? theme;

  CoachesDataSource(
      {required this.useSquad,
      required this.originalCoaches,
      required this.editCallback,
      this.activeCallback,
      this.removeItemCallback,
      this.theme,
      this.editIdx,
      Map<int, RenameNafName>? coachIdxNafRenames})
      : newCoaches = originalCoaches.map((c) => Coach.from(c)).toList(),
        coachIdxNafRenames = coachIdxNafRenames ?? {};

  @override
  DataRow2? getRow(int index) {
    Coach c = newCoaches[index];
    Coach cOriginal = originalCoaches[index];

    print("c_idx: " + index.toString() + " -> " + c.coachName);

    Checkbox activeCheckbox = Checkbox(
      value: c.active,
      onChanged: (value) {
        if (value != null && activeCallback != null) {
          activeCallback!(index, value);
        }
      },
    );

    final bool isInEditMode = editIdx == index;

    List<Widget> editRemoveActiveRow = [
      IconButton(
          onPressed: () {
            bool exitEditMode = isInEditMode;
            editCallback(index, exitEditMode, newCoaches, coachIdxNafRenames);
          },
          icon: Icon(isInEditMode ? Icons.check : Icons.edit)),
    ];

    if (!isInEditMode) {
      editRemoveActiveRow.addAll([
        SizedBox(width: 3),
        IconButton(
            onPressed: () {
              if (removeItemCallback != null) {
                removeItemCallback!(c.nafName);
              }
            },
            icon: Icon(Icons.delete)),
        SizedBox(width: 3),
        activeCheckbox,
      ]);
    }

    List<DataCell> cells = [
      DataCell(
        Row(children: editRemoveActiveRow),
      ),
      DataCell(_getName(c, cOriginal, isInEditMode)),
      DataCell(_getNaf(c, cOriginal, index, isInEditMode)),
      DataCell(_getTeam(c, cOriginal, isInEditMode)),
    ];

    if (useSquad) {
      cells.add(DataCell(_getSquad(c, cOriginal, isInEditMode)));
    }

    return DataRow2(
      cells: cells,
      specificRowHeight: isInEditMode ? 160 : null,
    );
  }

  Widget _getName(Coach c, Coach cOriginal, bool isInEditMode) {
    if (!isInEditMode) {
      return Text(c.coachName,
          style: TextStyle(
              color:
                  c.coachName != cOriginal.coachName ? Colors.orange : null));
    }

    TextEditingController coachNameController =
        TextEditingController(text: c.coachName);

    return Expanded(
        child: CustomTextFormField(
            title: "Name",
            controller: coachNameController,
            callback: (value) {
              c.coachName = value;
            }));
  }

  Widget _getNaf(Coach c, Coach cOriginal, int index, bool isInEditMode) {
    if (!isInEditMode) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.nafName,
              style: TextStyle(
                  color:
                      c.nafName != cOriginal.nafName ? Colors.orange : null)),
          Text(c.nafNumber.toString(),
              style: TextStyle(
                  color: c.nafNumber != cOriginal.nafNumber
                      ? Colors.orange
                      : null))
        ],
      );
    }

    ValueChanged<String> nafNameCallback = (value) {
      RenameNafName? renameNafName = coachIdxNafRenames[index];
      if (renameNafName == null) {
        coachIdxNafRenames.putIfAbsent(
            index, () => RenameNafName(originalCoaches[index].nafName, value));
      } else {
        coachIdxNafRenames.update(index,
            (old) => RenameNafName(originalCoaches[index].nafName, value));
      }
      c.nafName = value;
    };

    TextEditingController nafNameController =
        TextEditingController(text: c.nafName);
    CustomTextFormField nafNameField = CustomTextFormField(
        title: "Naf Name",
        controller: nafNameController,
        callback: (value) {
          nafNameCallback(value);
        });

    TextEditingController nafNumberController =
        TextEditingController(text: c.nafNumber.toString());
    CustomTextFormField nafNumberField = CustomTextFormField(
        title: "Naf Number",
        controller: nafNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        callback: (value) =>
            {c.nafNumber = int.parse(nafNumberController.text)});

    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [nafNameField, SizedBox(height: 10), nafNumberField],
    ));
  }

  Widget _getTeam(Coach c, Coach cOriginal, bool isInEditMode) {
    if (!isInEditMode) {
      Text raceText = Text(c.raceName(),
          style: TextStyle(
              color: c.race != cOriginal.race ? Colors.orange : null));

      return c.teamName.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(c.teamName,
                      style: TextStyle(
                          color: c.teamName != cOriginal.teamName
                              ? Colors.orange
                              : null)),
                  raceText
                ])
          : raceText;
    }

    TextEditingController teamNameController =
        TextEditingController(text: c.teamName);
    CustomTextFormField teamNameField = CustomTextFormField(
        title: "Team Name",
        controller: teamNameController,
        callback: (value) => {c.teamName = teamNameController.text});

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
      decoration: InputDecoration(labelText: "Race"),
    );

    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [teamNameField, raceField],
    ));
  }

  Widget _getSquad(Coach c, Coach cOriginal, bool isInEditMode) {
    if (!isInEditMode) {
      return Text(c.squadName,
          style: TextStyle(
              color:
                  c.squadName != cOriginal.squadName ? Colors.orange : null));
    }

    TextEditingController squadController =
        TextEditingController(text: c.squadName);

    return Expanded(
        child: CustomTextFormField(
            title: "Squad",
            controller: squadController,
            callback: (value) => {c.squadName = squadController.text}));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => newCoaches.length;

  @override
  int get selectedRowCount => 0;
}
