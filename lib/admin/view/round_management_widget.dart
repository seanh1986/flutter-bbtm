import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:collection/collection.dart';

class RoundManagementWidget extends StatefulWidget {
  RoundManagementWidget({Key? key}) : super(key: key);

  @override
  State<RoundManagementWidget> createState() {
    return _RoundManagementWidget();
  }
}

class _RoundManagementWidget extends State<RoundManagementWidget> {
  late Tournament _tournament;

  bool updateRoundIdx = true;
  bool updateCoachRound = true;

  int _selectedRoundIdx = -1;
  late List<CoachRound> _coachRounds;

  late List<DataColumn2> _roundSummaryCols;
  bool useBonus = false;

  bool hasSwapedMatches = false;

  int? editIdx;
  Set<int>? _editedMatchIndices;

  String _searchValue = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataColumn2> _getRoundSummaryCols() {
    List<DataColumn2> cols = [
      DataColumn2(
          label: Center(
              child: Text(_tournament.isLocked() ? "Table" : "Edit | Table")),
          size: ColumnSize.S),
      DataColumn2(
          label: Center(child: Text("Home | Away")),
          fixedWidth: 200,
          size: ColumnSize.L),
      DataColumn2(label: Center(child: Text("Status"))),
      DataColumn2(label: Center(child: Text("H TD"))),
      DataColumn2(label: Center(child: Text("A TD"))),
      DataColumn2(label: Center(child: Text("H Cas"))),
      DataColumn2(label: Center(child: Text("A Cas"))),
    ];

    if (_tournament.info.scoringDetails.bonusPts.isNotEmpty) {
      useBonus = true;
      cols.add(DataColumn2(label: Center(child: Text("Bonus"))));
    }

    cols.add(DataColumn2(label: Center(child: Text("Sport"))));

    return cols;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _searchValue = appState.screenState.searchValue;

    if (updateCoachRound) {
      _coachRounds =
          _tournament.coachRounds.map((m) => CoachRound.from(m)).toList();
    }

    if (updateRoundIdx && _coachRounds.isNotEmpty) {
      _selectedRoundIdx = _coachRounds.length - 1;
    }

    _roundSummaryCols = _getRoundSummaryCols();

    List<Widget> _widgets = [
      TitleBar(title: "Round Management"),
      _advanceDiscardBackupBtns(context),
      SizedBox(height: 20),
      _generateViewRounds(context)
    ];

    return Column(children: _widgets);
  }

  Widget _advanceDiscardBackupBtns(BuildContext context) {
    List<Widget> widgets = [];

    if (!_tournament.isLocked()) {
      widgets.addAll([
        SizedBox(width: 20),
        _advanceRoundButton(context),
        SizedBox(width: 20),
      ]);

      if (_tournament.curRoundNumber() > 0) {
        widgets.addAll([
          _discardCurrentRoundButton(context),
          SizedBox(width: 20),
          _swapMatchups(context),
          SizedBox(width: 20),
        ]);
      }

      widgets.addAll([_recoverBackupFromFile(context), SizedBox(width: 20)]);
    }

    widgets.add(_lockOrUnlockTournament(context));

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: widgets));
  }

  Widget _generateViewRounds(BuildContext context) {
    Widget? subScreenWidget = _getRoundSummaryByIdx(context, _selectedRoundIdx);

    List<Widget> children = [
      _viewRoundsToggleButtonsList(context),
      SizedBox(height: 20)
    ];

    if (subScreenWidget != null) {
      children.add(subScreenWidget);
    }

    return Column(children: children);
  }

  Widget _viewRoundsToggleButtonsList(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> toggleWidgets = [];

    for (int i = 0; i < _coachRounds.length; i++) {
      CoachRound r = _coachRounds[i];

      bool clickable = _selectedRoundIdx != i;

      toggleWidgets.add(ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          child: Text(
            "Round " + r.round().toString(),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: clickable
              ? () {
                  setState(() {
                    updateRoundIdx = false;
                    _selectedRoundIdx = i;
                    updateCoachRound = false;
                  });
                }
              : null));

      toggleWidgets.add(SizedBox(width: 10));
    }

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: toggleWidgets));
  }

  Widget? _getRoundSummaryByIdx(BuildContext context, int roundIdx) {
    if (roundIdx < 0 || roundIdx >= _coachRounds.length) {
      return null;
    }

    final theme = Theme.of(context);

    CoachRound coachRound = _coachRounds[roundIdx];

    CoachRoundDataSource dataSource = CoachRoundDataSource(
      context: context,
      info: _tournament.info,
      coachRound: coachRound,
      editedMatchIndices: _editedMatchIndices,
      editIdx: editIdx,
      searchValue: _searchValue,
      editCallback: (mIdx, doneEdit, editedMatchIndices) {
        setState(() {
          if (doneEdit) {
            editIdx = null;
          } else {
            editIdx = mIdx;
          }
          _editedMatchIndices = editedMatchIndices;
          updateCoachRound = false;
        });
      },
    );

    List<DataRow2> rows = [];

    dataSource.coachRound.matches.forEachIndexed((index, element) {
      DataRow2? row = dataSource.getRow(index);
      if (row != null) {
        rows.add(row);
      }
    });

    DataTable2 roundDataTable = DataTable2(
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
              child: Text(
                'No data yet',
                style: theme.textTheme.bodyLarge,
              ))),
      columns: _roundSummaryCols,
      rows: rows,
    );

    List<Widget> roundUpdateAndTableWidgets = [];

    if (!_tournament.isLocked()) {
      roundUpdateAndTableWidgets
          .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              // _coachRounds = _tournament.coachRounds;
              editIdx = null;
              _editedMatchIndices!.clear();
              updateCoachRound = true;
            });
          },
          child: const Text('Discard'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            VoidCallback callback = () async {
              List<UpdateMatchReportEvent> matchesToUpdate = dataSource
                  .editedMatchIndices
                  .map((mIdx) => UpdateMatchReportEvent.admin(
                      _tournament, coachRound.matches[mIdx], _selectedRoundIdx))
                  .toList();

              context.read<AppBloc>().add(UpdateMatchEvents(
                  context: context,
                  tournamentId: _tournament.info.id,
                  newRoundMatchups: hasSwapedMatches ? coachRound : null,
                  matchEvents: matchesToUpdate));
            };

            _showDialogToConfirmOverwrite(context, callback);
          },
          child: const Text('Update'),
        )
      ]));
    }

    roundUpdateAndTableWidgets.add(Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: roundDataTable));

    return Column(children: roundUpdateAndTableWidgets);
  }

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data for all rounds that you modified.");
    sb.writeln(
        "This may discard any unsaved changes to other sections of the admin pain (e.g., Tournament Details)");
    sb.writeln("Please confirm!");
    sb.writeln("");

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

  Widget _advanceRoundButton(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text(
          'Advance to Round: ' + (_tournament.curRoundNumber() + 1).toString()),
      onPressed: () {
        StringBuffer sb = new StringBuffer();
        sb.writeln("Are you sure you want to process round " +
            _tournament.curRoundNumber().toString() +
            " and advance to round " +
            (_tournament.curRoundNumber() + 1).toString() +
            "?");

        VoidCallback advanceCallback = () async {
          _tournament.processRound();

          // Download a backup before processing the round
          Tournament t = Tournament.from(_tournament);
          context.read<AppBloc>().add(DownloadBackup(t));

          String msg;
          SwissPairings swiss = SwissPairings(_tournament);
          RoundPairingError pairingError = swiss.pairNextRound();

          switch (pairingError) {
            case RoundPairingError.NoError:
              msg = "Succesful";
              break;
            case RoundPairingError.MissingPreviousResults:
              msg = "Missing Previous Results";
              break;
            case RoundPairingError.UnableToFindValidMatches:
              msg = "Unable To Find Valid Matches";
              break;
            default:
              msg = "Unknown Error";
              break;
          }

          showOkAlertDialog(
              context: context, title: "Advance Round", message: msg);

          if (pairingError == RoundPairingError.NoError) {
            ToastUtils.show(context, "Round Advanced");

            context.read<AppBloc>().add(AdvanceRound(context, _tournament));

            // Download a backup after a successful round process
            Tournament t = Tournament.from(_tournament);
            context.read<AppBloc>().add(DownloadBackup(t));
          }
        };

        showOkCancelAlertDialog(
                context: context,
                title: "Advance Round",
                message: sb.toString(),
                okLabel: "Advance",
                cancelLabel: "Cancel")
            .then((value) => {
                  if (value == OkCancelResult.ok) {advanceCallback()}
                });
      },
    );
  }

  Widget _discardCurrentRoundButton(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text('Discard Current Round (' +
          _tournament.curRoundNumber().toString() +
          ")"),
      onPressed: () {
        StringBuffer sb = new StringBuffer();
        sb.writeln(
            "Are you sure you want to discard the current drawn (round " +
                _tournament.curRoundNumber().toString() +
                ")?");

        VoidCallback discardCallback = () async {
          context
              .read<AppBloc>()
              .add(DiscardCurrentRound(context, _tournament));
        };

        showOkCancelAlertDialog(
                context: context,
                title: "Discard Current Round)",
                message: sb.toString(),
                okLabel: "Discard",
                cancelLabel: "Cancel")
            .then((value) => {
                  if (value == OkCancelResult.ok) {discardCallback()}
                });
      },
    );
  }

  Widget _swapMatchups(BuildContext context) {
    final theme = Theme.of(context);

    Function(CoachRound newCoachRound) refreshCallback =
        (CoachRound newCoachRound) async {
      setState(() {
        hasSwapedMatches = true;
        _coachRounds.last = newCoachRound;
      });
    };

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text(
          'Swap Match (Round ' + _tournament.curRoundNumber().toString() + ")"),
      onPressed: () {
        _showSwapMatchesDialog((nafName1, nafName2) {
          CoachRound lastRound = _tournament.coachRounds.last;

          CoachMatchup? match1 = lastRound.matches
              .firstWhereOrNull((m) => m.hasParticipantName(nafName1));
          CoachMatchup? match2 = lastRound.matches
              .firstWhereOrNull((m) => m.hasParticipantName(nafName2));

          bool success1 = match1 != null &&
              match1.replaceCoachAndResetMatchReports(nafName1, nafName2);
          bool success2 = match2 != null &&
              match2.replaceCoachAndResetMatchReports(nafName2, nafName1);

          Coach? match1Coach1 =
              match1 != null ? _tournament.getCoach(match1.homeNafName) : null;
          Coach? match1Coach2 =
              match1 != null ? _tournament.getCoach(match1.awayNafName) : null;

          Coach? match2Coach1 =
              match2 != null ? _tournament.getCoach(match2.homeNafName) : null;
          Coach? match2Coach2 =
              match2 != null ? _tournament.getCoach(match2.awayNafName) : null;

          bool validSwap1 =
              success1 && match1Coach1 != null && match1Coach2 != null;
          bool validSwap2 =
              success2 && match2Coach1 != null && match2Coach2 != null;

          if (!validSwap1 && !validSwap2) {
            ToastUtils.show(context, "Failed to swap matches");
          }

          StringBuffer sb = new StringBuffer();
          sb.writeln("Round " +
              _tournament.curRoundNumber().toString() +
              ": Are you sure that you want to swap " +
              nafName1 +
              " & " +
              nafName2 +
              "?");

          sb.writeln();
          sb.writeln("New Matchups:");
          sb.writeln();

          if (validSwap1) {
            sb.writeln("Table " +
                match1.tableNum.toString() +
                ": " +
                match1Coach1.nafName +
                " (" +
                match1Coach1.raceName() +
                ") vs. " +
                match1Coach2.nafName +
                " (" +
                match1Coach2.raceName() +
                ")");
          }

          if (validSwap2) {
            sb.writeln("Table " +
                match2.tableNum.toString() +
                ": " +
                match2Coach1.nafName +
                " (" +
                match2Coach1.raceName() +
                ") vs. " +
                match2Coach2.nafName +
                " (" +
                match2Coach2.raceName() +
                ")");
          }

          sb.writeln("");
          sb.writeln(
              "NOTE: You will still need to click 'Update' to push the change(s) to the server! This allows you to easily swap multiple matches before pushing.");

          showOkCancelAlertDialog(
                  context: context,
                  title: "Swap Matches",
                  message: sb.toString(),
                  okLabel: "Swap",
                  cancelLabel: "Cancel")
              .then((value) => {
                    if (value == OkCancelResult.ok)
                      {refreshCallback.call(lastRound)}
                  });
        });
      },
    );
  }

  Future<void> _showSwapMatchesDialog(
      void Function(String nafName1, String nafName2) callback) async {
    List<Coach> tCoaches = List.from(_tournament.getCoaches());
    tCoaches.sort(
        (a, b) => a.nafName.toLowerCase().compareTo(b.nafName.toLowerCase()));

    List<DropdownMenuItem> coachesDropDown = tCoaches
        .map((Coach c) => c.nafName)
        .map((String r) => DropdownMenuItem(value: r, child: Text(r)))
        .toList();

    String title =
        "Swap Matches (Round " + _tournament.curRoundNumber().toString() + ")";

    String nafName1 = "";
    String nafName2 = "";

    DropdownButtonFormField coachField_1 = DropdownButtonFormField(
      items: coachesDropDown,
      onChanged: (value) {
        nafName1 = value;
      },
      decoration: InputDecoration(labelText: "Nafname_1"),
    );

    DropdownButtonFormField coachField_2 = DropdownButtonFormField(
      items: coachesDropDown,
      onChanged: (value) {
        nafName2 = value;
      },
      decoration: InputDecoration(labelText: "Nafname_2"),
    );

    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10));
    widgets.add(coachField_1);
    widgets.add(SizedBox(height: 10));
    widgets.add(Divider());
    widgets.add(SizedBox(height: 10));
    widgets.add(coachField_2);
    widgets.add(SizedBox(height: 10));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: widgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();

                if (nafName1.isEmpty) {
                  ToastUtils.show(context, "Failed: Nafname_1 was empty");
                } else if (nafName2.isEmpty) {
                  ToastUtils.show(context, "Failed: Nafname_2 was empty");
                } else if (nafName1 == nafName2) {
                  ToastUtils.show(context, "Failed: Nafname_1 == Nafname_2");
                } else {
                  callback.call(nafName1, nafName2);
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _recoverBackupFromFile(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text('Recover Backup'),
      onPressed: () {
        VoidCallback recoveryCallback = () async {
          FilePickerResult? picked;

          if (kIsWeb) {
            picked = await FilePickerWeb.platform.pickFiles();
          } else {
            picked = await FilePicker.platform.pickFiles();
          }

          if (picked != null) {
            print(picked.files.first.name);

            if (picked.files.first.extension == 'json') {
              try {
                String s = new String.fromCharCodes(picked.files.first.bytes!);

                Map<String, dynamic> json = jsonDecode(s);

                TournamentBackup tournyBackup = TournamentBackup.fromJson(json);

                StringBuffer sb = new StringBuffer();
                sb.writeln(
                    "The recovery file has been successfull parsed. Please find a summary below.");
                sb.writeln("");
                sb.writeln(
                    "Tournament Name: " + tournyBackup.tournament.info.name);
                sb.writeln("# of Organizers: " +
                    tournyBackup.tournament.info.organizers.length.toString());
                sb.writeln("# of Squads: " +
                    tournyBackup.tournament.getSquads().length.toString());
                sb.writeln("# of Coaches: " +
                    tournyBackup.tournament.getCoaches().length.toString());
                sb.writeln("CurRound: " +
                    tournyBackup.tournament.curRoundNumber().toString());
                sb.writeln("");
                sb.writeln(
                    "Please confirm that you wish to OVERWRITE your tournament with the recovery file. This process cannot be undone.");

                VoidCallback confirmedRecoveryCallback = () async {
                  ToastUtils.show(context, "Recovering Backup");

                  context
                      .read<AppBloc>()
                      .add(RecoverBackup(context, tournyBackup.tournament));
                };

                showOkCancelAlertDialog(
                        context: context,
                        title: "Process Recovery Backup",
                        message: sb.toString(),
                        okLabel: "Overwrite",
                        cancelLabel: "Cancel")
                    .then((value) => {
                          if (value == OkCancelResult.ok)
                            {confirmedRecoveryCallback()}
                        });
              } catch (_) {
                ToastUtils.showFailed(context, "Failed to parse recovery file");
              }
            } else {
              ToastUtils.showFailed(
                  context, "Incorrect file format (must be .json)");
            }
          } else {
            ToastUtils.show(context, "Recovering Cancelled");
          }
        };

        showOkCancelAlertDialog(
                context: context,
                title: "Recover Backup",
                message:
                    "Uploading a recovery file will reset the tournament info/data. Are you sure you wish to proceed?",
                okLabel: "Yes",
                cancelLabel: "Cancel")
            .then((value) => {
                  if (value == OkCancelResult.ok) {recoveryCallback()}
                });
      },
    );
  }

  Widget _lockOrUnlockTournament(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: IconButton(
          icon: Icon(
            _tournament.isLocked() ? Icons.lock_open : Icons.lock,
            color: theme.iconTheme.color,
          ),
          onPressed: null),
      onPressed: () {
        String title;
        String msg;

        if (_tournament.isLocked()) {
          title = "Unlock tournament";
          msg =
              "Are you sure you want to UNLOCK the tournament? This will allow users & admins to edit matches/data";
        } else {
          title = "Lock tournament";
          msg =
              "Are you sure you want to LOCK the tournament? This will prevent users & admins from editing matches/data";
        }

        VoidCallback discardCallback = () async {
          TournamentInfo info = _tournament.info;

          bool shouldLock = !info.locked;

          info.locked = shouldLock;

          context.read<AppBloc>().add(
              LockOrUnlockTournament(context, _tournament.info, shouldLock));
        };

        showOkCancelAlertDialog(
                context: context,
                title: title,
                message: msg,
                okLabel: "Yes",
                cancelLabel: "Cancel")
            .then((value) => {
                  if (value == OkCancelResult.ok) {discardCallback()}
                });
      },
    );
  }
}

class CoachRoundDataSource extends DataTableSource {
  BuildContext context;
  TournamentInfo info;
  CoachRound coachRound;
  String? searchValue;

  Function(int, bool, Set<int>)
      editCallback; // true if done with edit mode, edited match indices
  int? editIdx;

  Set<int> editedMatchIndices = {};

  CoachRoundDataSource(
      {required this.context,
      required this.info,
      required this.coachRound,
      required this.editCallback,
      this.editIdx,
      this.searchValue,
      Set<int>? editedMatchIndices})
      : editedMatchIndices = editedMatchIndices ?? {};

  Widget _getTd(CoachMatchup m, int index, bool isInEditMode, bool homeTds) {
    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    TextStyle? tdStyle = _getTextStyle(
        report.status,
        homeTds ? m.homeReportedResults.homeTds : m.homeReportedResults.awayTds,
        homeTds
            ? m.awayReportedResults.homeTds
            : m.awayReportedResults.awayTds);

    if (!isInEditMode) {
      return Center(
          child: Text(
              _getValue(
                  report.status,
                  homeTds
                      ? m.homeReportedResults.homeTds
                      : m.homeReportedResults.awayTds,
                  homeTds
                      ? m.awayReportedResults.homeTds
                      : m.awayReportedResults.awayTds),
              style: tdStyle,
              textAlign: TextAlign.center));
    }

    TextEditingController tdController = TextEditingController(
        text: _getValue(
            report.status,
            homeTds
                ? m.homeReportedResults.homeTds
                : m.homeReportedResults.awayTds,
            homeTds
                ? m.awayReportedResults.homeTds
                : m.awayReportedResults.awayTds));

    ValueChanged<String> tdCallback = (value) {
      int td = int.parse(tdController.text);

      if (homeTds) {
        m.homeReportedResults.homeTds = td;
        m.awayReportedResults.homeTds = td;
      } else {
        m.homeReportedResults.awayTds = td;
        m.awayReportedResults.awayTds = td;
      }

      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    return Center(
        child: TextFormField(
            controller: tdController,
            style: tdStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: tdCallback));
  }

  Widget _getCas(CoachMatchup m, int index, bool isInEditMode, bool homeCas) {
    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    TextStyle? casStyle = _getTextStyle(
        report.status,
        homeCas ? m.homeReportedResults.homeCas : m.homeReportedResults.awayCas,
        homeCas
            ? m.awayReportedResults.homeCas
            : m.awayReportedResults.awayCas);

    if (!isInEditMode) {
      return Center(
          child: Text(
              _getValue(
                  report.status,
                  homeCas
                      ? m.homeReportedResults.homeCas
                      : m.homeReportedResults.awayCas,
                  homeCas
                      ? m.awayReportedResults.homeCas
                      : m.awayReportedResults.awayCas),
              style: casStyle));
    }

    TextEditingController casController = TextEditingController(
        text: _getValue(
            report.status,
            homeCas
                ? m.homeReportedResults.homeCas
                : m.homeReportedResults.awayCas,
            homeCas
                ? m.awayReportedResults.homeCas
                : m.awayReportedResults.awayCas));

    ValueChanged<String> casCallback = (value) {
      int cas = int.parse(casController.text);

      if (homeCas) {
        m.homeReportedResults.homeCas = cas;
        m.awayReportedResults.homeCas = cas;
      } else {
        m.homeReportedResults.awayCas = cas;
        m.awayReportedResults.awayCas = cas;
      }

      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    return Center(
        child: TextFormField(
            controller: casController,
            style: casStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: casCallback));
  }

  Widget _getConfirmed(CoachMatchup m) {
    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    switch (report.status) {
      case ReportedMatchStatus.HomeReported:
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("H"), Icon(Icons.check)]);
      case ReportedMatchStatus.AwayReported:
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("A"), Icon(Icons.check)]);
      case ReportedMatchStatus.BothReportedAgree:
        return Center(child: Icon(Icons.check, color: Colors.green));
      case ReportedMatchStatus.BothReportedConflict:
        return Center(
            child: Icon(Icons.error_outline_sharp, color: Colors.red));
      case ReportedMatchStatus.NoReportsYet:
      default:
        return Center(child: Icon(Icons.question_mark_sharp));
    }
  }

  @override
  DataRow2? getRow(int index) {
    CoachMatchup m = coachRound.matches[index];

    if (searchValue != null && !m.matchSearch(searchValue!)) {
      return null;
    }

    bool isRowPrevEdited = editedMatchIndices.contains(index);

    // print("m_idx: " +
    //     index.toString() +
    //     " -> " +
    //     m.homeNafName +
    //     " vs. " +
    //     m.awayNafName);

    final bool isInEditMode = editIdx == index;

    List<Widget> editTableNumRow = [];

    if (!info.locked) {
      editTableNumRow.addAll([
        IconButton(
            onPressed: () {
              bool exitEditMode = isInEditMode;
              editCallback(index, exitEditMode, editedMatchIndices);
            },
            icon: Icon(isInEditMode ? Icons.check : Icons.edit)),
        SizedBox(width: 3)
      ]);
    }
    editTableNumRow.add(Text(m.tableNum.toString(),
        style: TextStyle(color: isRowPrevEdited ? Colors.orange : null)));

    Text homeNafName = Text(m.homeNafName);
    Text awayNafName = Text(m.awayNafName);

    Column homeAwayNafNames = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [homeNafName, awayNafName],
    );

    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    List<DataCell> cellRows = [
      DataCell(Row(children: editTableNumRow)),
      DataCell(homeAwayNafNames),
      DataCell(_getConfirmed(m)),
      DataCell(_getTd(m, index, isInEditMode, true)),
      DataCell(_getTd(m, index, isInEditMode, false)),
      DataCell(_getCas(m, index, isInEditMode, true)),
      DataCell(_getCas(m, index, isInEditMode, false)),
    ];

    if (info.scoringDetails.bonusPts.isNotEmpty) {
      cellRows.add(DataCell(_btnBonus(report, index)));
    }

    cellRows.add(DataCell(_btnBestSport(report, index)));

    return DataRow2(
        cells: cellRows, specificRowHeight: isInEditMode ? 100 : null);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => coachRound.matches.length;

  @override
  int get selectedRowCount => 0;

  bool _hasReported(ReportedMatchStatus status, bool home) {
    if (home) {
      return status == ReportedMatchStatus.HomeReported ||
          status == ReportedMatchStatus.BothReportedAgree ||
          status == ReportedMatchStatus.BothReportedConflict;
    } else {
      return status == ReportedMatchStatus.AwayReported ||
          status == ReportedMatchStatus.BothReportedAgree ||
          status == ReportedMatchStatus.BothReportedConflict;
    }
  }

  String _getValue(ReportedMatchStatus status, int homeVal, int awayVal) {
    return _getValueWithDefault(status, homeVal, awayVal, null);
  }

  String _getValueWithDefault(
      ReportedMatchStatus status, int homeVal, int awayVal, int? defaultVal) {
    switch (status) {
      case ReportedMatchStatus.BothReportedConflict:
        return homeVal == awayVal
            ? homeVal.toString()
            : homeVal.toString() + " / " + awayVal.toString();
      case ReportedMatchStatus.AwayReported:
        return awayVal.toString();
      case ReportedMatchStatus.HomeReported:
      case ReportedMatchStatus.BothReportedAgree:
        return homeVal.toString();
      case ReportedMatchStatus.NoReportsYet:
      default:
        return defaultVal != null ? defaultVal.toString() : "";
    }
  }

  TextStyle? _getTextStyle(
      ReportedMatchStatus status, int homeVal, int awayVal) {
    switch (status) {
      case ReportedMatchStatus.BothReportedConflict:
      case ReportedMatchStatus.BothReportedAgree:
        return homeVal == awayVal
            ? TextStyle(color: Colors.greenAccent)
            : TextStyle(color: Colors.redAccent);
      case ReportedMatchStatus.AwayReported:
      case ReportedMatchStatus.HomeReported:
      case ReportedMatchStatus.NoReportsYet:
      default:
        return null;
    }
  }

  Widget _btnBestSport(ReportedMatchResultWithStatus report, int index) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _showBestSportDialog(report, index);
        },
        child: Text("Sport"),
      ),
    );
  }

  Future<void> _showBestSportDialog(
      ReportedMatchResultWithStatus report, int index) async {
    CoachMatchup m = coachRound.matches[index];

    String title = "Best Sport";

    bool reportedHomeSport = _hasReported(report.status, false);

    TextStyle? homeSportStyle = reportedHomeSport
        ? TextStyle(color: Colors.greenAccent)
        : TextStyle(color: Colors.redAccent);

    ValueChanged<String> homeSportCallback = (value) {
      int sport = int.parse(value);
      m.awayReportedResults.bestSportOppRank = sport;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    bool reportedAwaySport = _hasReported(report.status, true);

    TextStyle? awaySportStyle = reportedAwaySport
        ? TextStyle(color: Colors.greenAccent)
        : TextStyle(color: Colors.redAccent);

    ValueChanged<String> awaySportCallback = (value) {
      int sport = int.parse(value);
      m.homeReportedResults.bestSportOppRank = sport;
      m.homeReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(width: 10.0),
                      Expanded(
                          child: CustomTextFormField(
                              title: 'Home Sport (1-5)',
                              initialValue: m
                                  .awayReportedResults.bestSportOppRank
                                  .toString(),
                              textStyle: homeSportStyle,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                              callback: (value) {
                                homeSportCallback(value);
                              })),
                    ]),
                SizedBox(width: 10.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: CustomTextFormField(
                              initialValue: m
                                  .homeReportedResults.bestSportOppRank
                                  .toString(),
                              textStyle: awaySportStyle,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                              title: 'Away Sport (1-5)',
                              callback: (value) {
                                awaySportCallback(value);
                              }))
                    ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _btnBonus(ReportedMatchResultWithStatus report, int index) {
    return Center(
        child: ElevatedButton(
      onPressed: () {
        _showBonusDialog(info, index);
      },
      child: Text("Bonus"),
    ));
  }

  Future<void> _showBonusDialog(TournamentInfo info, int index) async {
    CoachMatchup m = coachRound.matches[index];

    String title = "Bonus Points: " + m.homeNafName + " vs. " + m.awayNafName;

    if (m.homeReportedResults.homeBonusPts.isEmpty) {
      for (int i = 0; i < info.scoringDetails.bonusPts.length; i++) {
        m.homeReportedResults.homeBonusPts.add(0);
      }
    }
    if (m.homeReportedResults.awayBonusPts.isEmpty) {
      for (int i = 0; i < info.scoringDetails.bonusPts.length; i++) {
        m.homeReportedResults.awayBonusPts.add(0);
      }
    }
    if (m.awayReportedResults.homeBonusPts.isEmpty) {
      for (int i = 0; i < info.scoringDetails.bonusPts.length; i++) {
        m.awayReportedResults.homeBonusPts.add(0);
      }
    }
    if (m.awayReportedResults.awayBonusPts.isEmpty) {
      for (int i = 0; i < info.scoringDetails.bonusPts.length; i++) {
        m.awayReportedResults.awayBonusPts.add(0);
      }
    }

    List<Widget> homeWidgets = [
      SizedBox(width: 10.0),
      Text(m.homeNafName, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(width: 10.0),
    ];

    List<Widget> awayWidgets = [
      SizedBox(width: 10.0),
      Text(m.awayNafName, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(width: 10.0),
    ];

    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    for (int i = 0; i < info.scoringDetails.bonusPts.length; i++) {
      String bonusName = info.scoringDetails.bonusPts[i].name;
      double bonusWeight = info.scoringDetails.bonusPts[i].weight;

      String bonusTitle = bonusName + " (w: " + bonusWeight.toString() + ")";

      int homeBonusHomeReported = m.homeReportedResults.homeBonusPts[i];

      int homeBonusAwayReported = m.awayReportedResults.homeBonusPts[i];

      String homeBonus = _getValueWithDefault(
          report.status, homeBonusHomeReported, homeBonusAwayReported, 0);
      TextStyle? homeBonusStyle = _getTextStyle(
          report.status, homeBonusHomeReported, homeBonusAwayReported);

      ValueChanged<String> homeBonusCallback = (value) {
        int numPts = int.parse(value);
        m.homeReportedResults.homeBonusPts[i] = numPts;
        m.awayReportedResults.homeBonusPts[i] = numPts;
        m.homeReportedResults.reported = true;
        m.awayReportedResults.reported = true;
        editedMatchIndices.add(index);
      };

      homeWidgets.add(Row(
        children: [
          Expanded(
              child: CustomTextFormField(
                  title: m.homeNafName.toString() + " -> " + bonusTitle,
                  initialValue: homeBonus.toString(),
                  textStyle: homeBonusStyle,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  callback: (value) {
                    homeBonusCallback(value);
                  }))
        ],
      ));

      int awayBonusHomeReported = m.homeReportedResults.awayBonusPts[i];

      int awayBonusAwayReported = m.awayReportedResults.awayBonusPts[i];

      String awayBonus = _getValueWithDefault(
          report.status, awayBonusHomeReported, awayBonusAwayReported, 0);
      TextStyle? awayBonusStyle = _getTextStyle(
          report.status, awayBonusHomeReported, awayBonusAwayReported);

      ValueChanged<String> awayBonusCallback = (value) {
        int numPts = int.parse(value);
        m.homeReportedResults.awayBonusPts[i] = numPts;
        m.awayReportedResults.awayBonusPts[i] = numPts;
        m.homeReportedResults.reported = true;
        m.awayReportedResults.reported = true;
        editedMatchIndices.add(index);
      };

      awayWidgets.add(Row(
        children: [
          Expanded(
              child: CustomTextFormField(
                  title: m.awayNafName.toString() + " -> " + bonusTitle,
                  initialValue: awayBonus.toString(),
                  textStyle: awayBonusStyle,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  callback: (value) {
                    awayBonusCallback(value);
                  }))
        ],
      ));
    }

    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10));
    widgets.addAll(homeWidgets);
    widgets.add(SizedBox(height: 10));
    widgets.add(Divider());
    widgets.add(SizedBox(height: 10));
    widgets.addAll(awayWidgets);
    widgets.add(SizedBox(height: 10));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: widgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
