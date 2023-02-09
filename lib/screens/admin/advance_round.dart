import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    return BlocBuilder<TournamentBloc, TournamentState>(
        bloc: _tournyBloc,
        builder: (selectContext, selectState) {
          if (selectState is NewTournamentState) {
            _coachRounds = selectState.tournament.coachRounds;

            // ToastUtils.showSuccess(fToast, "Tournament Loaded");
          }
          return Container(
              // height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                  child: ExpansionTile(
            title: Text("Tournament Management"),
            subtitle: Text("Advance round or edit previous rounds"),
            children: widgets,
          )));
        });
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

  void _processUpdate(VoidCallback confirmedUpdateCallback) {
    confirmedUpdateCallback();
    widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
    ToastUtils.show(fToast, "Updating Tournament Data");
  }

  ExpansionTile _advanceOrDiscardRound(BuildContext context) {
    return ExpansionTile(title: Text("Advance or Discard Round"), children: [
      SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _advanceRoundButton(context),
        SizedBox(width: 20),
        _discardCurrentRoundButton(context)
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
            primary: Colors.blue,
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

            VoidCallback advanceCallback = () {
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
                widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
                ToastUtils.show(fToast, "Updating Tournament Data");
              }
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Advance Round",
                    message: sb.toString(),
                    okLabel: "Advance",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {_processUpdate(advanceCallback)}
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
            primary: Colors.blue,
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
              setState(() {});
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
        text: report.status != ReportedMatchStatus.NoReportsYet
            ? report.homeTds.toString()
            : "");

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
        text: report.status != ReportedMatchStatus.NoReportsYet
            ? report.awayTds.toString()
            : "");

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
        text: report.status != ReportedMatchStatus.NoReportsYet
            ? report.homeCas.toString()
            : "");

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
        text: report.status != ReportedMatchStatus.NoReportsYet
            ? report.awayCas.toString()
            : "");

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
        text: report.status != ReportedMatchStatus.NoReportsYet
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
        text: report.status != ReportedMatchStatus.NoReportsYet
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
}
