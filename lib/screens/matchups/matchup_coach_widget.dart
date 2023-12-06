import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/matchups/matchup_report_widget.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/screens/matchups/best_sport_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MatchupCoachWidget extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;
  final CoachMatchup matchup;
  final bool refreshState;

  MatchupCoachWidget(
      {Key? key,
      required this.tournament,
      required this.authUser,
      required this.matchup,
      required this.refreshState})
      : super(key: key);

  @override
  State<MatchupCoachWidget> createState() {
    return _MatchupHeadlineWidget();
  }
}

enum UploadState {
  NotYetSet, // Not a valid state (this means not yet initialized)
  NotAuthorized, // Not authorized to edit match results
  Editing, // Currently editing
  // UploadedAwaiting, // Upload pending
  CanConfirm, // Opponent submitted, please confirm
  CanEdit, // User already submitted but can edit
  UploadedConfirmed, // Confirmed that both sides agree
  Error, // Disagreement in reported results
}

class _MatchupHeadlineWidget extends State<MatchupCoachWidget> {
  late Tournament _tournament;
  late AuthUser _authUser;
  late CoachMatchup _matchup;

  late TournamentBloc _tournyBloc;

  late ReportedMatchResultWithStatus _reportWithStatus;
  UploadState _state = UploadState.NotYetSet;

  final double titleFontSize = kIsWeb ? 20.0 : 12.0;
  final double subTitleFontSize = kIsWeb ? 14.0 : 10.0;

  final double uploadIconSize = kIsWeb ? 24.0 : 12.0;
  final double errUploadIconSize = kIsWeb ? 20.0 : 10.0;

  final double itemUploadSize = kIsWeb ? 50.0 : 30.0;

  final double vsTableNumWidth = kIsWeb ? 55.0 : 35.0;

  late MatchupReportWidget homeReportWidget;
  late MatchupReportWidget awayReportWidget;

  late FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  void _refreshState() {
    _tournament = widget.tournament;
    _authUser = widget.authUser;
    _matchup = widget.matchup;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refreshState) {
      _refreshState();
    }

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    _reportWithStatus = _matchup.getReportedMatchStatus();

    Authorization authorization =
        _tournament.getMatchAuthorization(_matchup, _authUser);

    _state = _getMatchUploadState(_reportWithStatus, authorization);

    print("Matchup: " +
        _matchup.homeNafName +
        " vs. " +
        _matchup.awayNafName +
        " -> " +
        _state.toString());

    homeReportWidget = MatchupReportWidget(
        tounamentInfo: _tournament.info,
        reportedMatch: _reportWithStatus,
        participant: _matchup.home(_tournament),
        showHome: true,
        state: _state,
        refreshState: widget.refreshState);

    awayReportWidget = MatchupReportWidget(
        tounamentInfo: _tournament.info,
        reportedMatch: _reportWithStatus,
        participant: _matchup.away(_tournament),
        showHome: false,
        state: _state,
        refreshState: widget.refreshState);

    return Container(
        alignment: FractionalOffset.center,
        child: _coachMatchupWidget(context));
  }

  Widget _coachMatchupWidget(BuildContext context) {
    Widget rowItemWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 10.0),
                  child: homeReportWidget)),
          _getVsAndTableWidget(context),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 10.0),
                  child: awayReportWidget)),
        ]);

    List<Widget> matchAndSportWidgets = [rowItemWidget];

    Widget? bestSportWidget = _getBestSportWidget(context);

    if (bestSportWidget != null) {
      matchAndSportWidgets.add(SizedBox(height: 5));
      matchAndSportWidgets.add(bestSportWidget);
      matchAndSportWidgets.add(SizedBox(height: 5));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: matchAndSportWidgets,
    );
  }

  Widget? _getBestSportWidget(BuildContext context) {
    // bool enableEditing =
    //     _state == UploadState.Editing || _state == UploadState.Error;

    // bool enableEditing = true;

    Widget? bestSportWidget;

    ReportedMatchResult? result;
    Coach? opponent;
    Color? color;
    Alignment alignment = Alignment.center;

    String nafName = _authUser.getNafName();

    if (_matchup.isHome(nafName)) {
      result = _matchup.homeReportedResults;
      opponent = _tournament.getCoach(_matchup.awayNafName);
      color = Theme.of(context).colorScheme.primary;
      alignment = Alignment.centerLeft;
    } else if (_matchup.isAway(nafName)) {
      result = _matchup.awayReportedResults;
      opponent = _tournament.getCoach(_matchup.homeNafName);
      color = Theme.of(context).colorScheme.secondary;
      alignment = Alignment.centerRight;
    }

    // if (!enableEditing) {
    //   color = Colors.grey;
    // }

    if (result != null && opponent != null) {
      bestSportWidget = Padding(
          padding: EdgeInsets.all(5.0),
          child: Align(
              alignment: alignment,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                  child: Text(
                    'Rate opponent\'s sportsmanship',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onPressed: () {
                  // Give meaningful error message if editing is disabled
                  // if (!enableEditing) {
                  //   int curRating = 3;

                  //   if (_matchup.isHome(_authUser.nafName)) {
                  //     curRating = _matchup.homeReportedResults.bestSportOppRank;
                  //   } else if (_matchup.isAway(_authUser.nafName)) {
                  //     curRating = _matchup.awayReportedResults.bestSportOppRank;
                  //   }

                  //   StringBuffer sb = new StringBuffer();
                  //   sb.writeln("You have already submitted your results.");
                  //   sb.writeln(
                  //       "If you wish to edit them, please press the edit icon to update your sportsmanship rating and then re-submit.");
                  //   sb.writeln("");
                  //   sb.writeln("Your current rating is: " +
                  //       curRating.toString() +
                  //       "\u272D");

                  //   showOkAlertDialog(
                  //       context: context,
                  //       title: "Rate opponent\'s sportsmanship",
                  //       message: sb.toString());
                  //   return;
                  // }

                  BestSportWidget widget =
                      BestSportWidget(result: result!, opponent: opponent!);

                  AlertDialog alert = AlertDialog(
                    content: widget,
                    actions: [
                      ElevatedButton(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                          child: Text(
                            'Confirm',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        onPressed: () {
                          print("bestSportOppRank: " +
                              widget.result.bestSportOppRank.toString());

                          String nafName = _authUser.getNafName();

                          ReportedMatchResult? result;
                          bool? isHome;

                          if (_matchup.isHome(nafName)) {
                            result = _matchup.homeReportedResults;
                            isHome = true;
                          } else if (_matchup.isAway(nafName)) {
                            result = _matchup.awayReportedResults;
                            isHome = false;
                          } else if (_tournament.isSquadCaptainFor(
                              nafName, _matchup.homeNafName)) {
                            result = _matchup.homeReportedResults;
                            isHome = true;
                          } else if (_tournament.isSquadCaptainFor(
                              nafName, _matchup.awayNafName)) {
                            result = _matchup.awayReportedResults;
                            isHome = false;
                          }

                          if (result != null) {
                            result.bestSportOppRank =
                                widget.result.bestSportOppRank;

                            if (result.reported && isHome != null) {
                              LoadingIndicatorDialog().show(context);
                              _tournyBloc.updateMatchEvent(
                                  UpdateMatchReportEvent(
                                      _tournament, _matchup, isHome));
                              LoadingIndicatorDialog().dismiss();
                            }
                          }

                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                      )
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                },
              )));
    }

    return bestSportWidget;
  }

  Widget _getVsAndTableWidget(BuildContext context) {
    List<Widget> tableVsDetails = [];

    if (!_hideItemUploadBtn()) {
      Widget? uploadIcon = _itemUploadIcon();
      Widget? statusIcon = _itemStatusIcon();

      List<Widget> widgets = [];

      if (statusIcon != null) {
        widgets.add(_createButton(
            statusIcon,
            () => {
                  if (!_hideItemUploadBtn()) {_showStatusDialog()}
                }));
        widgets.add(SizedBox(height: 10));
      }

      if (uploadIcon != null) {
        widgets.add(_createButton(
            uploadIcon,
            () => {
                  if (!_hideItemUploadBtn()) {_checkIfUploadToServer(context)}
                }));
      }

      tableVsDetails.add(Container(
          child: Wrap(
        children: widgets,
      )));
    } else {
      tableVsDetails
          .add(SizedBox(width: uploadIconSize, height: uploadIconSize));
    }

    tableVsDetails
        .add(Text(' vs. ', style: TextStyle(fontSize: subTitleFontSize)));
    tableVsDetails.add(Text('T#' + _matchup.tableNum.toString(),
        style: TextStyle(fontSize: subTitleFontSize)));

    return SizedBox(
        width: vsTableNumWidth,
        child: Card(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tableVsDetails),
        ));
  }

  RawMaterialButton _createButton(Widget iconWidget, VoidCallback? onPressed) {
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: Theme.of(context).primaryColorLight,
      elevation: 0.0,
      child: iconWidget,
      onPressed: () => {
        if (onPressed != null) {onPressed()}
      },
    );
  }

  Future<void> _showStatusDialog() async {
    String title = "Match Report Status";

    StringBuffer sb = StringBuffer();
    sb.writeln("home: " + _matchup.homeNafName);
    sb.writeln("away: " + _matchup.awayNafName);

    ReportedMatchResult homeResult = _matchup.homeReportedResults;
    ReportedMatchResult awayResult = _matchup.awayReportedResults;

    Text homeVsAway = Text(sb.toString());

    Widget homeTds = _getReportedResultItemWidget(
        "Home Tds",
        homeResult.reported ? homeResult.homeTds : null,
        awayResult.reported ? awayResult.homeTds : null);

    Widget awayTds = _getReportedResultItemWidget(
        "Away Tds",
        homeResult.reported ? homeResult.awayTds : null,
        awayResult.reported ? awayResult.awayTds : null);

    Widget homeCas = _getReportedResultItemWidget(
        "Home Cas",
        homeResult.reported ? homeResult.homeCas : null,
        awayResult.reported ? awayResult.homeCas : null);

    Widget awayCas = _getReportedResultItemWidget(
        "Away Cas",
        homeResult.reported ? homeResult.awayCas : null,
        awayResult.reported ? awayResult.awayCas : null);

    List<Widget> widgets = [
      homeVsAway,
      SizedBox(height: 5),
      Divider(),
      SizedBox(height: 5),
      homeTds,
      awayTds,
      SizedBox(height: 5),
      Divider(),
      SizedBox(height: 5),
      homeCas,
      awayCas,
    ];

    List<BonusDetails> bonuses = widget.tournament.info.scoringDetails.bonusPts;
    if (bonuses.isNotEmpty) {
      for (int i = 0; i < bonuses.length; i++) {
        BonusDetails bonusDetails = bonuses[i];

        Widget homeBonus = _getReportedResultItemWidget(
            "Home Bonus: " +
                bonusDetails.name +
                "(w:" +
                bonusDetails.weight.toString() +
                ")",
            homeResult.reported ? homeResult.homeBonusPts[i] : null,
            awayResult.reported ? awayResult.homeBonusPts[i] : null);

        Widget awayBonus = _getReportedResultItemWidget(
            "Away Bonus: " +
                bonusDetails.name +
                "(w:" +
                bonusDetails.weight.toString() +
                ")",
            homeResult.reported ? homeResult.awayBonusPts[i] : null,
            awayResult.reported ? awayResult.awayBonusPts[i] : null);

        widgets.add(SizedBox(height: 5));
        widgets.add(Divider());
        widgets.add(SizedBox(height: 5));
        widgets.add(homeBonus);
        widgets.add(awayBonus);
      }
    }

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
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getReportedResultItemWidget(
      String resultItem, int? homeReportedValue, int? awayReportedValue) {
    List<Widget> children = [
      Text(resultItem,
          style: TextStyle(
            decoration: TextDecoration.underline,
          )),
      Text(": "),
      SizedBox(width: 10)
    ];

    if (homeReportedValue != null && awayReportedValue != null) {
      if (homeReportedValue == awayReportedValue) {
        children.add(Text(homeReportedValue.toString(),
            style: TextStyle(color: Colors.green)));
      } else {
        children.add(Text(
            homeReportedValue.toString() + " / " + awayReportedValue.toString(),
            style: TextStyle(color: Colors.red)));
      }
    } else if (homeReportedValue == null && awayReportedValue == null) {
      children.add(Text("? / ?", style: TextStyle(color: Colors.orange)));
    } else if (homeReportedValue != null) {
      children.add(Text(homeReportedValue.toString() + " / ?",
          style: TextStyle(color: Colors.orange)));
    } else if (awayReportedValue != null) {
      children.add(Text("? / " + awayReportedValue.toString(),
          style: TextStyle(color: Colors.orange)));
    }

    return Row(children: children);
  }

  void _checkIfUploadToServer(BuildContext context) async {
    int homeTds = homeReportWidget.getTds();
    int homeCas = homeReportWidget.getCas();

    int awayTds = awayReportWidget.getTds();
    int awayCas = awayReportWidget.getCas();

    StringBuffer sb = StringBuffer();
    sb.writeln("Match Report");
    sb.writeln("");
    sb.writeln("home: " + _matchup.homeNafName);
    sb.writeln("away: " + _matchup.awayNafName);
    sb.writeln("");
    sb.writeln("homeTds: " + homeTds.toString());
    sb.writeln("awayTds: " + awayTds.toString());
    sb.writeln("");
    sb.writeln("homeCas: " + homeCas.toString());
    sb.writeln("awayCas: " + awayCas.toString());

    List<BonusDetails> bonuses = widget.tournament.info.scoringDetails.bonusPts;
    if (bonuses.isNotEmpty) {
      List<int> homeBonuses = homeReportWidget.getBonusPts();
      List<int> awayBonuses = awayReportWidget.getBonusPts();

      sb.writeln("");
      sb.writeln("Bonuses:");

      for (int i = 0; i < bonuses.length; i++) {
        BonusDetails bonusDetails = bonuses[i];

        sb.writeln("");

        sb.writeln("home -> " +
            bonusDetails.name +
            "(w: " +
            bonusDetails.weight.toString() +
            "): " +
            homeBonuses[i].toString());

        sb.writeln("away -> " +
            bonusDetails.name +
            "(w: " +
            bonusDetails.weight.toString() +
            "): " +
            awayBonuses[i].toString());
      }
    }

    String msg = sb.toString();

    OkCancelResult result =
        await showOkCancelAlertDialog(context: context, message: msg);
    if (result == OkCancelResult.ok) {
      _uploadToServer();
    }
  }

  void _uploadToServer() async {
    String nafName = _authUser.getNafName();

    bool? isHome; // fall back (e.g. for admin)
    if (_matchup.isHome(nafName) ||
        _tournament.isSquadCaptainFor(nafName, _matchup.homeNafName)) {
      isHome = true;
      _matchup.homeReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.homeReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.homeReportedResults.homeBonusPts =
          homeReportWidget.getBonusPts();

      _matchup.homeReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.homeReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.homeReportedResults.awayBonusPts =
          awayReportWidget.getBonusPts();

      _matchup.homeReportedResults.reported = true;
    } else if (_matchup.isAway(nafName) ||
        _tournament.isSquadCaptainFor(nafName, _matchup.awayNafName)) {
      isHome = false;
      _matchup.awayReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.awayReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.awayReportedResults.homeBonusPts =
          homeReportWidget.getBonusPts();

      _matchup.awayReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.awayReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.awayReportedResults.awayBonusPts =
          awayReportWidget.getBonusPts();

      _matchup.awayReportedResults.reported = true;
    } else {
      _matchup.homeReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.homeReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.homeReportedResults.homeBonusPts =
          homeReportWidget.getBonusPts();

      _matchup.homeReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.homeReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.homeReportedResults.awayBonusPts =
          awayReportWidget.getBonusPts();

      _matchup.homeReportedResults.reported = true;

      _matchup.awayReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.awayReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.awayReportedResults.homeBonusPts =
          homeReportWidget.getBonusPts();

      _matchup.awayReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.awayReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.awayReportedResults.awayBonusPts =
          awayReportWidget.getBonusPts();

      _matchup.awayReportedResults.reported = true;
    }

    try {
      UpdateMatchReportEvent event = isHome != null
          ? new UpdateMatchReportEvent(_tournament, _matchup, isHome)
          : new UpdateMatchReportEvent.admin(_tournament, _matchup);

      ToastUtils.show(fToast, "Uploading Match Report!");

      LoadingIndicatorDialog().show(context);
      bool updateSuccess = await _tournyBloc.updateMatchEvent(event);
      LoadingIndicatorDialog().dismiss();

      if (updateSuccess) {
        ToastUtils.showSuccess(fToast, "Uploaded Match Report!");
        setState(() {});

        // Tournament? refreshedTournament =
        //     await _tournyBloc.getRefreshedTournamentData(_tournament.info.id);

        // if (refreshedTournament != null) {
        //   _tournyBloc.add(SelectTournamentEvent(refreshedTournament));
        //   if (mounted) {
        //     setState(() {
        //       _tournament = refreshedTournament;
        //     });
        //   }
        // } else {
        //   ToastUtils.showFailed(fToast,
        //       "Automatic tournament refresh failed. Please refresh the page.");
        // }
      } else {
        ToastUtils.showFailed(fToast,
            "Uploading Match Failed. Please reload the page and try again.");
      }
    } catch (_) {
      ToastUtils.showFailed(fToast,
          "Uploading Match Failed. Please reload the page and try again.");
    }

    // setState(() {
    //   _state = UploadState.CanEdit;
    // });
  }

  Widget? _itemUploadIcon() {
    if (_state == UploadState.NotAuthorized ||
        _state == UploadState.NotYetSet) {
      return Icon(
        Icons.question_mark,
        color: Colors.transparent,
        size: uploadIconSize,
      );
    } else {
      return Icon(
        Icons.cloud_upload_rounded,
        color: Colors.white,
        size: uploadIconSize,
      );
    }
  }

  Widget? _itemStatusIcon() {
    switch (_state) {
      case UploadState.CanConfirm:
        return Icon(
          Icons.question_mark,
          color: Colors.orange,
          size: uploadIconSize,
        );
      case UploadState.CanEdit:
        return Icon(
          Icons.done,
          color: Colors.orange,
          size: uploadIconSize,
        );
      case UploadState.UploadedConfirmed:
        return Icon(
          Icons.done,
          color: Colors.green,
          size: uploadIconSize,
        );
      case UploadState.Error:
        return Icon(Icons.report, color: Colors.red, size: uploadIconSize);
      case UploadState.NotAuthorized:
      case UploadState.Editing:
      case UploadState.NotYetSet:
        return null;
    }
  }

  bool _hideItemUploadBtn() {
    return _state == UploadState.NotAuthorized;
  }

  UploadState _getMatchUploadState(
      ReportedMatchResultWithStatus reportWithStatus,
      Authorization authorization) {
    if (authorization == Authorization.Unauthorized) {
      return UploadState.NotAuthorized;
    }

    switch (reportWithStatus.status) {
      case ReportedMatchStatus.NoReportsYet:
        return UploadState.Editing;
      case ReportedMatchStatus.BothReportedAgree:
        return UploadState.UploadedConfirmed;
      case ReportedMatchStatus.BothReportedConflict:
        return UploadState.Error;
      case ReportedMatchStatus.HomeReported:
        return authorization == Authorization.HomeCoach ||
                authorization == Authorization.HomeCaptain ||
                authorization == Authorization.Admin
            ? UploadState.CanEdit
            : UploadState.CanConfirm;
      case ReportedMatchStatus.AwayReported:
        return authorization == Authorization.AwayCoach ||
                authorization == Authorization.AwayCaptain ||
                authorization == Authorization.Admin
            ? UploadState.CanEdit
            : UploadState.CanConfirm;
    }
  }
}
