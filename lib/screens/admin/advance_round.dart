import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament_backup.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';

class AdvanceRoundWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  AdvanceRoundWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<AdvanceRoundWidget> createState() {
    return _AdvanceRoundWidget();
  }
}

class _AdvanceRoundWidget extends State<AdvanceRoundWidget> {
  late TournamentBloc _tournyBloc;

  late FToast fToast;

  List<CoachRound> _coachRounds = [];

  List<DataColumn> _roundSummaryCols = [
    DataColumn(label: Text("Table")),
    DataColumn(label: Text("Home")),
    DataColumn(label: Text("Away")),
    DataColumn(label: Text("Status")),
    DataColumn(label: Text("H TD")),
    DataColumn(label: Text("A TD")),
    DataColumn(label: Text("H Cas")),
    DataColumn(label: Text("A Cas")),
    DataColumn(label: Text("Sport (for H)")),
    DataColumn(label: Text("Sport (for A)")),
  ];

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    _coachRounds = widget.tournament.coachRounds;
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < widget.tournament.coachRounds.length; i++) {
      Widget? widget = _generateRoundSummary(i);
      if (widget != null) {
        widgets.add(widget);
      }
    }

    widgets.add(_advanceOrDiscardRound(context));

    return Container(
        // height: MediaQuery.of(context).size.height * 0.5,
        child: SingleChildScrollView(
            child: ExpansionTile(
      title: Text("Tournament Management"),
      subtitle: Text("Advance round or edit previous rounds"),
      children: widgets,
    )));
  }

  Widget? _generateRoundSummary(int round) {
    if (round >= _coachRounds.length) {
      return null;
    }

    CoachRound coachRound = _coachRounds[round];

    CoachRoundDataSource dataSource =
        CoachRoundDataSource(coachRound: coachRound);

    PaginatedDataTable roundDataTable = PaginatedDataTable(
      columns: _roundSummaryCols,
      source: dataSource,
    );

    return ExpansionTile(
        title: Text("Round " + coachRound.round().toString()),
        children: [
          roundDataTable,
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _coachRounds = widget.tournament.coachRounds;
                  });
                },
                child: const Text('Discard'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  VoidCallback callback = () {
                    widget.tournament.coachRounds[round] = coachRound;
                  };

                  _showDialogToConfirmOverwrite(context, callback);
                },
                child: const Text('Update'),
              )
            ],
          ),
          SizedBox(height: 10),
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
              if (value == OkCancelResult.ok)
                {_processUpdate(confirmedUpdateCallback)}
            });
  }

  void _processUpdate(VoidCallback confirmedUpdateCallback) async {
    confirmedUpdateCallback();

    ToastUtils.show(fToast, "Updating Tournament Data");

    bool success = await _tournyBloc.updateTournament(widget.tournament);

    if (success) {
      ToastUtils.showSuccess(fToast, "Update successful.");
      // _tournyBloc.get(widget.tournament.info.id);
    } else {
      ToastUtils.showFailed(fToast, "Update failed.");
    }
  }

  ExpansionTile _advanceOrDiscardRound(BuildContext context) {
    return ExpansionTile(title: Text("Advance or Discard Round"), children: [
      SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _advanceRoundButton(context),
        SizedBox(width: 20),
        _discardCurrentRoundButton(context),
        SizedBox(width: 20),
        _downloadFileBackup(context),
        SizedBox(width: 20),
        _recoverBackupFromFile(context),
        SizedBox(width: 20),
        _downloadNafUploadFile(context),
        SizedBox(width: 20),
        _downloadGlamFile(context),
      ]),
      SizedBox(height: 10),
    ]);
  }

  Widget _advanceRoundButton(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Advance to Round: ' +
              (widget.tournament.curRoundNumber() + 1).toString()),
          onPressed: () {
            StringBuffer sb = new StringBuffer();
            sb.writeln("Are you sure you want to process round " +
                widget.tournament.curRoundNumber().toString() +
                " and advance to round " +
                (widget.tournament.curRoundNumber() + 1).toString() +
                "?");

            VoidCallback advanceCallback = () async {
              widget.tournament.processRound();

              String msg;
              SwissPairings swiss = SwissPairings(widget.tournament);
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
                ToastUtils.show(fToast, "Updating Tournament Data");

                bool success =
                    await _tournyBloc.updateTournament(widget.tournament);

                if (success) {
                  ToastUtils.showSuccess(
                      fToast, "Tournament data successfully updated.");
                  Tournament? refreshedTournament = await _tournyBloc
                      .getRefreshedTournamentData(widget.tournament.info.id);
                  if (refreshedTournament != null) {
                    _tournyBloc.add(SelectTournamentEvent(refreshedTournament));

                    if (mounted) {
                      setState(() {});
                    }
                  } else {
                    ToastUtils.showFailed(
                        fToast, "Failed to refresh tournament.");
                  }
                } else {
                  ToastUtils.showFailed(
                      fToast, "Tournament data failed to update.");
                }
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
              widget.tournament.curRoundNumber().toString() +
              ")"),
          onPressed: () {
            StringBuffer sb = new StringBuffer();
            sb.writeln(
                "Are you sure you want to discard the current drawn (round " +
                    widget.tournament.curRoundNumber().toString() +
                    ")?");

            VoidCallback discardCallback = () {
              widget.tournament.coachRounds.removeLast();
              ToastUtils.showSuccess(fToast, "Removed Last Round");
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Discard Current Round)",
                    message: sb.toString(),
                    okLabel: "Discard",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {_processUpdate(discardCallback)}
                    });
          },
        ));
  }

  Widget _downloadFileBackup(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Backup'),
          onPressed: () {
            VoidCallback downloadBackupCallback = () async {
              ToastUtils.show(fToast, "Downloading Backup");

              bool success = await _tournyBloc.downloadTournamentBackup(
                  DownloadTournamentBackup(widget.tournament));

              if (success) {
                ToastUtils.showSuccess(
                    fToast, "Backup successfully downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Backup failed to download");
              }
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Download Backup",
                    message:
                        "This will download a backup file which can be used as a backup to restore at a later time",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {_processUpdate(downloadBackupCallback)}
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
              var picked =
                  await FilePicker.platform.pickFiles(allowMultiple: false);

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

                      bool success = await widget.tournyBloc
                          .updateTournament(tournyBackup.tournament);

                      if (success) {
                        ToastUtils.showSuccess(
                            fToast, "Recovering Backup successful.");

                        Tournament? refreshedTournament =
                            await _tournyBloc.getRefreshedTournamentData(
                                widget.tournament.info.id);

                        if (refreshedTournament != null) {
                          ToastUtils.showSuccess(
                              fToast, "Tournament refreshed");
                          _tournyBloc
                              .add(SelectTournamentEvent(refreshedTournament));
                        } else {
                          ToastUtils.showFailed(fToast,
                              "Automatic tournament refresh failed. Please refresh the page.");
                        }
                      } else {
                        ToastUtils.showFailed(
                            fToast, "Recovering Backup failed.");
                      }
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

  Widget _downloadNafUploadFile(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Naf Upload'),
          onPressed: () {
            VoidCallback downloadNafUploadCallback = () async {
              ToastUtils.show(fToast, "Downloading Naf Upload File");

              bool success =
                  await _tournyBloc.downloadNafUploadFile(widget.tournament);

              if (success) {
                ToastUtils.showSuccess(fToast, "Naf Upload downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Naf Upload failed to download");
              }
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Download Naf Upload File",
                    message:
                        "This will download a the naf upload file which can be used to upload tournament results",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {_processUpdate(downloadNafUploadCallback)}
                    });
          },
        ));
  }

  Widget _downloadGlamFile(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Glam'),
          onPressed: () {
            VoidCallback downloadGlamCallback = () async {
              ToastUtils.show(fToast, "Downloading Glam File");

              bool success =
                  await _tournyBloc.downloadGlamFile(widget.tournament);

              if (success) {
                ToastUtils.showSuccess(fToast, "Glam downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Glam failed to download");
              }
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Glam Upload File",
                    message:
                        "This will download a the file which can be used to upload Glam results",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {_processUpdate(downloadGlamCallback)}
                    });
          },
        ));
  }
}

class CoachRoundDataSource extends DataTableSource {
  late CoachRound coachRound;

  CoachRoundDataSource({required this.coachRound});

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

    Text tableNum = Text(m.tableNum().toString());
    Text homeNafName = Text(m.homeNafName);
    Text awayNafName = Text(m.awayNafName);

    ReportedMatchResultWithStatus report = m.getReportedMatchStatus();

    Text textStatus = Text(_convertToString(report));

    TextEditingController homeTdController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.homeTds,
            m.awayReportedResults.homeTds));

    ValueChanged<String> homeTdCallback = (value) {
      int td = int.parse(homeTdController.text);
      m.homeReportedResults.homeTds = td;
      m.awayReportedResults.homeTds = td;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
    };

    TextFormField homeTdField = TextFormField(
        controller: homeTdController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: homeTdCallback);

    TextEditingController awayTdController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.awayTds,
            m.awayReportedResults.awayTds));

    ValueChanged<String> awayTdCallback = (value) {
      int td = int.parse(awayTdController.text);
      m.homeReportedResults.awayTds = td;
      m.awayReportedResults.awayTds = td;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
    };

    TextFormField awayTdField = TextFormField(
        controller: awayTdController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: awayTdCallback);

    TextEditingController homeCasController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.homeCas,
            m.awayReportedResults.homeCas));

    ValueChanged<String> homeCasCallback = (value) {
      int cas = int.parse(homeCasController.text);
      m.homeReportedResults.homeCas = cas;
      m.awayReportedResults.homeCas = cas;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
    };

    TextFormField homeCasField = TextFormField(
        controller: homeCasController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: homeCasCallback);

    TextEditingController awayCasController = TextEditingController(
        text: _getValue(report.status, m.homeReportedResults.awayCas,
            m.awayReportedResults.awayCas));

    ValueChanged<String> awayCasCallback = (value) {
      int cas = int.parse(awayCasController.text);
      m.homeReportedResults.awayCas = cas;
      m.awayReportedResults.awayCas = cas;
      m.homeReportedResults.reported = true;
      m.awayReportedResults.reported = true;
    };

    TextFormField awayCasField = TextFormField(
        controller: awayCasController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: awayCasCallback);

    TextEditingController homeSportController = TextEditingController(
        text: _hasReported(report.status, false)
            ? m.awayReportedResults.bestSportOppRank.toString()
            : "");

    ValueChanged<String> homeSportCallback = (value) {
      int sport = int.parse(homeSportController.text);
      m.awayReportedResults.bestSportOppRank = sport;
      m.awayReportedResults.reported = true;
    };

    TextFormField homeSportField = TextFormField(
        controller: homeSportController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: homeSportCallback);

    TextEditingController awaySportController = TextEditingController(
        text: _hasReported(report.status, true)
            ? m.homeReportedResults.bestSportOppRank.toString()
            : "");

    ValueChanged<String> awaySportCallback = (value) {
      int sport = int.parse(awaySportController.text);
      m.homeReportedResults.bestSportOppRank = sport;
      m.homeReportedResults.reported = true;
    };

    TextFormField awaySportField = TextFormField(
        controller: awaySportController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: awaySportCallback);

    return DataRow(cells: [
      DataCell(tableNum),
      DataCell(homeNafName),
      DataCell(awayNafName),
      DataCell(textStatus),
      DataCell(homeTdField),
      DataCell(awayTdField),
      DataCell(homeCasField),
      DataCell(awayCasField),
      DataCell(homeSportField),
      DataCell(awaySportField),
    ]);
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
    switch (status) {
      case ReportedMatchStatus.BothReportedConflict:
        return homeVal == awayVal ? homeVal.toString() : "";
      case ReportedMatchStatus.AwayReported:
        return awayVal.toString();
      case ReportedMatchStatus.HomeReported:
      case ReportedMatchStatus.BothReportedAgree:
        return homeVal.toString();
      case ReportedMatchStatus.NoReportsYet:
      default:
        return "";
    }
  }
}
