import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';

class RoundManagementWidget extends StatefulWidget {
  RoundManagementWidget({Key? key}) : super(key: key);

  @override
  State<RoundManagementWidget> createState() {
    return _RoundManagementWidget();
  }
}

class _RoundManagementWidget extends State<RoundManagementWidget> {
  late Tournament _tournament;
  late FToast fToast;

  bool updateRoundIdx = true;

  int _selectedRoundIdx = -1;
  List<CoachRound> _coachRounds = [];

  late List<DataColumn> _roundSummaryCols;
  bool useBonus = false;

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

  List<DataColumn> _getRoundSummaryCols() {
    List<DataColumn> cols = [
      DataColumn(label: Text("Table")),
      DataColumn(label: Text("Home")),
      DataColumn(label: Text("Away")),
      DataColumn(label: Text("Status")),
      DataColumn(label: Text("H TD")),
      DataColumn(label: Text("A TD")),
      DataColumn(label: Text("H Cas")),
      DataColumn(label: Text("A Cas")),
    ];

    if (_tournament.info.scoringDetails.bonusPts.isNotEmpty) {
      useBonus = true;
      cols.add(DataColumn(label: Text("Bonus")));
    }

    cols.add(DataColumn(label: Text("Sport")));

    return cols;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;

    _coachRounds = _tournament.coachRounds;

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
    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              SizedBox(width: 20),
              _advanceRoundButton(context),
              SizedBox(width: 20),
              _discardCurrentRoundButton(context),
              SizedBox(width: 20),
              _recoverBackupFromFile(context),
            ]));
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

    CoachRound coachRound = _coachRounds[roundIdx];

    CoachRoundDataSource dataSource = CoachRoundDataSource(
        context: context, info: _tournament.info, coachRound: coachRound);

    PaginatedDataTable roundDataTable = PaginatedDataTable(
      columns: _roundSummaryCols,
      source: dataSource,
    );

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _coachRounds = _tournament.coachRounds;
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
                      _tournament, coachRound.matches[mIdx]))
                  .toList();

              context.read<AppBloc>().add(UpdateMatchEvents(matchesToUpdate));
              // LoadingIndicatorDialog().show(context);
              // bool success =
              //     await _tournyBloc.updateMatchEvents(matchesToUpdate);
              // LoadingIndicatorDialog().dismiss();

              // if (success) {
              //   ToastUtils.showSuccess(
              //       fToast, "Tournament data successfully updated.");

              //   _tournyBloc
              //       .add(TournamentEventRefreshData(widget.tournament.info.id));
              // } else {
              //   ToastUtils.showFailed(
              //       fToast, "Tournament data failed to update.");
              // }
            };

            _showDialogToConfirmOverwrite(context, callback);
          },
          child: const Text('Update'),
        )
      ]),
      Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: roundDataTable,
          ))
    ]);
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

    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          child: Text('Advance to Round: ' +
              (_tournament.curRoundNumber() + 1).toString()),
          onPressed: () {
            StringBuffer sb = new StringBuffer();
            sb.writeln("Are you sure you want to process round " +
                _tournament.curRoundNumber().toString() +
                " and advance to round " +
                (_tournament.curRoundNumber() + 1).toString() +
                "?");

            VoidCallback advanceCallback = () async {
              _tournament.processRound();

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
                ToastUtils.show(fToast, "Round Advanced");

                context.read<AppBloc>().add(AdvanceRound(_tournament));
                // LoadingIndicatorDialog().show(context);
                // bool success =
                //     await _tournyBloc.advanceRound(widget.tournament);
                // LoadingIndicatorDialog().dismiss();

                // if (success) {
                //   ToastUtils.showSuccess(
                //       fToast, "Tournament data successfully updated.");

                //   // Tournament? refreshedTournament = await _tournyBloc
                //   //     .getRefreshedTournamentData(widget.tournament.info.id);
                //   // if (refreshedTournament != null) {
                //   //   _tournyBloc.add(SelectTournamentEvent(refreshedTournament));

                //   //   if (mounted) {
                //   //     setState(() {});
                //   //   }
                //   // } else {
                //   //   ToastUtils.showFailed(
                //   //       fToast, "Failed to refresh tournament.");
                //   // }
                // } else {
                //   ToastUtils.showFailed(
                //       fToast, "Tournament data failed to update.");
                // }
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
        ));
  }

  Widget _discardCurrentRoundButton(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
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
              context.read<AppBloc>().add(DiscardCurrentRound(_tournament));
              // //widget.tournament.coachRounds.removeLast();
              // LoadingIndicatorDialog().show(context);
              // bool success =
              //     await _tournyBloc.discardCurrentRound(widget.tournament);
              // LoadingIndicatorDialog().dismiss();

              // if (success) {
              //   ToastUtils.showSuccess(fToast, "Removed current round");
              //   _tournyBloc
              //       .add(TournamentEventRefreshData(widget.tournament.info.id));
              // } else {
              //   ToastUtils.showFailed(fToast, "Failed to remove current round");
              // }
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
        ));
  }

  Widget _recoverBackupFromFile(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
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
                    String s =
                        new String.fromCharCodes(picked.files.first.bytes!);

                    Map<String, dynamic> json = jsonDecode(s);

                    TournamentBackup tournyBackup =
                        TournamentBackup.fromJson(json);

                    StringBuffer sb = new StringBuffer();
                    sb.writeln(
                        "The recovery file has been successfull parsed. Please find a summary below.");
                    sb.writeln("");
                    sb.writeln("Tournament Name: " +
                        tournyBackup.tournament.info.name);
                    sb.writeln("# of Organizers: " +
                        tournyBackup.tournament.info.organizers.length
                            .toString());
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
                      ToastUtils.show(fToast, "Recovering Backup");

                      context
                          .read<AppBloc>()
                          .add(RecoverBackup(tournyBackup.tournament));

                      // LoadingIndicatorDialog().show(context);
                      // bool success = await widget.tournyBloc
                      //     .recoverTournamentBackup(tournyBackup.tournament);
                      // LoadingIndicatorDialog().dismiss();

                      // if (success) {
                      //   ToastUtils.showSuccess(
                      //       fToast, "Recovering Backup successful.");

                      //   // Tournament? refreshedTournament =
                      //   //     await _tournyBloc.getRefreshedTournamentData(
                      //   //         widget.tournament.info.id);

                      //   // if (refreshedTournament != null) {
                      //   //   ToastUtils.showSuccess(
                      //   //       fToast, "Tournament refreshed");
                      //   //   _tournyBloc
                      //   //       .add(SelectTournamentEvent(refreshedTournament));
                      //   // } else {
                      //   //   ToastUtils.showFailed(fToast,
                      //   //       "Automatic tournament refresh failed. Please refresh the page.");
                      //   // }
                      // } else {
                      //   ToastUtils.showFailed(
                      //       fToast, "Recovering Backup failed.");
                      // }
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
                    ToastUtils.showFailed(
                        fToast, "Failed to parse recovery file");
                  }
                } else {
                  ToastUtils.showFailed(
                      fToast, "Incorrect file format (must be .json)");
                }
              } else {
                ToastUtils.show(fToast, "Recovering Cancelled");
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
        ));
  }
}

class CoachRoundDataSource extends DataTableSource {
  BuildContext context;
  TournamentInfo info;
  CoachRound coachRound;

  Set<int> editedMatchIndices = {};

  CoachRoundDataSource(
      {required this.context, required this.info, required this.coachRound});

  String _convertToString(ReportedMatchResultWithStatus r) {
    switch (r.status) {
      case ReportedMatchStatus.NoReportsYet:
        return "None";
      case ReportedMatchStatus.HomeReported:
        return "Home Only";
      case ReportedMatchStatus.AwayReported:
        return "Away Only";
      case ReportedMatchStatus.BothReportedAgree:
        return "Confirmed";
      case ReportedMatchStatus.BothReportedConflict:
        return "Error";
      default:
        return "N/A";
    }
  }

  @override
  DataRow? getRow(int index) {
    CoachMatchup m = coachRound.matches[index];

    // print("m_idx: " +
    //     index.toString() +
    //     " -> " +
    //     m.homeNafName +
    //     " vs. " +
    //     m.awayNafName);

    Text tableNum = Text(m.tableNum.toString());
    Text homeNafName = Text(m.homeNafName);
    Text awayNafName = Text(m.awayNafName);

    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    Text textStatus = Text(_convertToString(report));

    TextEditingController homeTdController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.homeTds,
            m.awayReportedResults.homeTds));

    TextStyle? homeTdStyle = _getTextStyle(report.status,
        m.homeReportedResults.homeTds, m.awayReportedResults.homeTds);

    ValueChanged<String> homeTdCallback = (value) {
      int td = int.parse(homeTdController.text);
      m.homeReportedResults.homeTds = td;
      m.awayReportedResults.homeTds = td;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    TextFormField homeTdField = TextFormField(
        controller: homeTdController,
        style: homeTdStyle,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: homeTdCallback);

    TextEditingController awayTdController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.awayTds,
            m.awayReportedResults.awayTds));

    TextStyle? awayTdStyle = _getTextStyle(report.status,
        m.homeReportedResults.awayTds, m.awayReportedResults.awayTds);

    ValueChanged<String> awayTdCallback = (value) {
      int td = int.parse(awayTdController.text);
      m.homeReportedResults.awayTds = td;
      m.awayReportedResults.awayTds = td;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    TextFormField awayTdField = TextFormField(
        controller: awayTdController,
        style: awayTdStyle,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: awayTdCallback);

    TextEditingController homeCasController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.homeCas,
            m.awayReportedResults.homeCas));

    TextStyle? homeCasStyle = _getTextStyle(report.status,
        m.homeReportedResults.homeCas, m.awayReportedResults.homeCas);

    ValueChanged<String> homeCasCallback = (value) {
      int cas = int.parse(homeCasController.text);
      m.homeReportedResults.homeCas = cas;
      m.awayReportedResults.homeCas = cas;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    TextFormField homeCasField = TextFormField(
        controller: homeCasController,
        style: homeCasStyle,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: homeCasCallback);

    TextEditingController awayCasController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.awayCas,
            m.awayReportedResults.awayCas));

    TextStyle? awayCasStyle = _getTextStyle(report.status,
        m.homeReportedResults.awayCas, m.awayReportedResults.awayCas);

    ValueChanged<String> awayCasCallback = (value) {
      int cas = int.parse(awayCasController.text);
      m.homeReportedResults.awayCas = cas;
      m.awayReportedResults.awayCas = cas;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
      editedMatchIndices.add(index);
    };

    TextFormField awayCasField = TextFormField(
        controller: awayCasController,
        style: awayCasStyle,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: awayCasCallback);

    List<DataCell> cellRows = [
      DataCell(tableNum),
      DataCell(homeNafName),
      DataCell(awayNafName),
      DataCell(textStatus),
      DataCell(homeTdField),
      DataCell(awayTdField),
      DataCell(homeCasField),
      DataCell(awayCasField),
    ];

    if (info.scoringDetails.bonusPts.isNotEmpty) {
      cellRows.add(DataCell(_btnBonus(report, index)));
    }

    cellRows.add(DataCell(_btnBestSport(report, index)));

    return DataRow(cells: cellRows);
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
    return ElevatedButton(
      onPressed: () {
        _showBestSportDialog(report, index);
      },
      child: Text("Sport"),
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
    return ElevatedButton(
      onPressed: () {
        _showBonusDialog(info, index);
      },
      child: Text("Bonus"),
    );
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

      homeWidgets.add(Expanded(
          child: CustomTextFormField(
              title: m.homeNafName.toString() + " -> " + bonusTitle,
              initialValue: homeBonus.toString(),
              textStyle: homeBonusStyle,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              callback: (value) {
                homeBonusCallback(value);
              })));

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

      awayWidgets.add(Expanded(
          child: CustomTextFormField(
              title: m.awayNafName.toString() + " -> " + bonusTitle,
              initialValue: awayBonus.toString(),
              textStyle: awayBonusStyle,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              callback: (value) {
                awayBonusCallback(value);
              })));
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
