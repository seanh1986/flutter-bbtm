import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/tournament_repository.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchupCoachWidget extends StatefulWidget {
  final CoachMatchup matchup;
  final int roundIdx;
  final bool refreshState;

  MatchupCoachWidget(
      {Key? key,
      required this.matchup,
      required this.roundIdx,
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
  late User _user;
  Tournament? _tournament;
  CoachMatchup? _matchup;

  late ReportedMatchResultWithStatus _reportWithStatus;
  UploadState _state = UploadState.NotYetSet;

  final double titleFontSize = kIsWeb ? 20.0 : 12.0;
  final double subTitleFontSize = kIsWeb ? 14.0 : 10.0;

  final double uploadIconSize = kIsWeb ? 24.0 : 12.0;
  final double errUploadIconSize = kIsWeb ? 20.0 : 10.0;

  final double itemUploadSize = kIsWeb ? 50.0 : 30.0;

  final double vsTableNumWidth = kIsWeb ? 55.0 : 35.0;

  MatchupReportWidget? homeReportWidget;
  MatchupReportWidget? awayReportWidget;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshState() {
    _matchup = widget.matchup;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);

    // Check if round refreshed
    bool isNewRound = _tournament == null ||
        _tournament!.curRoundNumber() !=
            appState.tournamentState.tournament.curRoundNumber();

    // Update internal state
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    // Make sure we don't reset inputs if user has not yet submitted results
    String nafName = _user.getNafName();

    bool canEditHome =
        _matchup != null && _matchup!.canEditHome(_tournament!, nafName);

    bool canEditAway =
        _matchup != null && _matchup!.canEditAway(_tournament!, nafName);

    bool canEdit = canEditHome || canEditAway;

    bool reportedHomeResults = canEditHome &&
        homeReportWidget != null &&
        homeReportWidget!.reportedMatch!.reported;

    bool reportedAwayResults = canEditAway &&
        awayReportWidget != null &&
        awayReportWidget!.reportedMatch!.reported;

    bool reportedResults = reportedHomeResults || reportedAwayResults;

    bool isSameMatchup = _matchup != null &&
        _matchup!.isHome(widget.matchup.homeName()) &&
        _matchup!.isAway(widget.matchup.awayName());

    bool allowRefresh =
        !isSameMatchup || isNewRound || !canEdit || reportedResults;

    bool refreshState = widget.refreshState && allowRefresh;

    if (refreshState) {
      _refreshState();

      _reportWithStatus =
          _matchup!.getReportedMatchStatus(t: _tournament!, nafName: nafName);

      Authorization authorization =
          widget.roundIdx == _tournament!.curRoundIdx()
              ? _tournament!.getMatchAuthorization(_matchup!, _user)
              : Authorization.Unauthorized;

      _state = _getMatchUploadState(_reportWithStatus, authorization);

      if (_tournament!.isLocked()) {
        _state = UploadState.NotAuthorized;
      }

      print("Matchup: " +
          _matchup!.homeNafName +
          " vs. " +
          _matchup!.awayNafName +
          " -> " +
          _state.toString());

      Color? homeColor = _getColor(true);
      Color? awayColor = _getColor(false);

      homeReportWidget = MatchupReportWidget(
          tounamentInfo: _tournament!.info,
          reportedMatch: _reportWithStatus,
          participant: _matchup!.home(_tournament!),
          showHome: true,
          state: _state,
          refreshState: refreshState,
          titleColor: homeColor);

      awayReportWidget = MatchupReportWidget(
          tounamentInfo: _tournament!.info,
          reportedMatch: _reportWithStatus,
          participant: _matchup!.away(_tournament!),
          showHome: false,
          state: _state,
          refreshState: refreshState,
          titleColor: awayColor);
    }

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

// TODO: BestSport
    // Widget? bestSportWidget = _getBestSportWidget(context);

    // if (bestSportWidget != null) {
    //   matchAndSportWidgets.add(SizedBox(height: 5));
    //   matchAndSportWidgets.add(bestSportWidget);
    //   matchAndSportWidgets.add(SizedBox(height: 5));
    // }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: matchAndSportWidgets,
    );
  }

  Widget? _getBestSportWidget(BuildContext context) {
    if (_tournament!.isLocked()) {
      return null;
    }

    final theme = Theme.of(context);

    // bool enableEditing =
    //     _state == UploadState.Editing || _state == UploadState.Error;

    // bool enableEditing = true;

    Widget? bestSportWidget;

    ReportedMatchResult? result;
    Coach? opponent;
    // Color? color;
    Alignment alignment = Alignment.center;

    String nafName = _user.getNafName();

    if (_matchup!.isHome(nafName)) {
      result = _matchup!.homeReportedResults;
      opponent = _tournament!.getCoach(_matchup!.awayNafName);
      // color = Theme.of(context).colorScheme.primary;
      alignment = Alignment.centerLeft;
    } else if (_matchup!.isAway(nafName)) {
      result = _matchup!.awayReportedResults;
      opponent = _tournament!.getCoach(_matchup!.homeNafName);
      // color = Theme.of(context).colorScheme.secondary;
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
                style: theme.elevatedButtonTheme.style,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                  child: Text(
                    'Rate opponent\'s sportsmanship',
                    style: theme.textTheme.bodyMedium,
                    // TextStyle(color: Colors.black)
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
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        onPressed: () {
                          print("bestSportOppRank: " +
                              widget.result.bestSportOppRank.toString());

                          String nafName = _user.getNafName();

                          ReportedMatchResult? result;
                          bool? isHome;

                          if (_matchup!.isHome(nafName)) {
                            result = _matchup!.homeReportedResults;
                            isHome = true;
                          } else if (_matchup!.isAway(nafName)) {
                            result = _matchup!.awayReportedResults;
                            isHome = false;
                          } else if (_tournament!.isSquadCaptainFor(
                              nafName, _matchup!.homeNafName)) {
                            result = _matchup!.homeReportedResults;
                            isHome = true;
                          } else if (_tournament!.isSquadCaptainFor(
                              nafName, _matchup!.awayNafName)) {
                            result = _matchup!.awayReportedResults;
                            isHome = false;
                          }

                          if (result != null) {
                            result.bestSportOppRank =
                                widget.result.bestSportOppRank;

                            if (result.reported && isHome != null) {
                              context.read<AppBloc>().add(UpdateMatchEvent(
                                  context,
                                  UpdateMatchReportEvent(
                                      _tournament!, _matchup!, isHome)));
                              // _tournyBloc.updateMatchEvent(
                              // UpdateMatchReportEvent(
                              //     _tournament, _matchup, isHome));
                              // LoadingIndicatorDialog().dismiss();
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
    final theme = Theme.of(context);

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

    tableVsDetails.add(Text(' vs. ',
        style: theme
            .textTheme.labelSmall)); //TextStyle(fontSize: subTitleFontSize)));
    tableVsDetails.add(Text('T#' + _matchup!.tableNum.toString(),
        style: theme
            .textTheme.labelSmall)); // TextStyle(fontSize: subTitleFontSize)));

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
    sb.writeln("home: " + _matchup!.homeNafName);
    sb.writeln("away: " + _matchup!.awayNafName);

    ReportedMatchResult homeResult = _matchup!.homeReportedResults;
    ReportedMatchResult awayResult = _matchup!.awayReportedResults;

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

    List<BonusDetails> bonuses = _tournament!.info.scoringDetails.bonusPts;
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
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text(
            title,
            style: theme.textTheme
                .titleMedium, // TextStyle(fontWeight: FontWeight.bold),
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
    int homeTds = homeReportWidget!.getTds();
    int homeCas = homeReportWidget!.getCas();

    int awayTds = awayReportWidget!.getTds();
    int awayCas = awayReportWidget!.getCas();

    StringBuffer sb = StringBuffer();
    sb.writeln("Match Report");
    sb.writeln("");
    sb.writeln("home: " + _matchup!.homeNafName);
    sb.writeln("away: " + _matchup!.awayNafName);
    sb.writeln("");
    sb.writeln("homeTds: " + homeTds.toString());
    sb.writeln("awayTds: " + awayTds.toString());
    sb.writeln("");
    sb.writeln("homeCas: " + homeCas.toString());
    sb.writeln("awayCas: " + awayCas.toString());

    List<BonusDetails> bonuses = _tournament!.info.scoringDetails.bonusPts;
    if (bonuses.isNotEmpty) {
      List<int> homeBonuses = homeReportWidget!.getBonusPts();
      List<int> awayBonuses = awayReportWidget!.getBonusPts();

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
    String nafName = _user.getNafName();

    bool? isHome; // fall back (e.g. for admin)
    if (_matchup!.isHome(nafName) ||
        _tournament!.isSquadCaptainFor(nafName, _matchup!.homeNafName)) {
      isHome = true;
      _matchup!.homeReportedResults.homeTds = homeReportWidget!.getTds();
      _matchup!.homeReportedResults.homeCas = homeReportWidget!.getCas();
      _matchup!.homeReportedResults.homeBonusPts =
          homeReportWidget!.getBonusPts();

      _matchup!.homeReportedResults.awayTds = awayReportWidget!.getTds();
      _matchup!.homeReportedResults.awayCas = awayReportWidget!.getCas();
      _matchup!.homeReportedResults.awayBonusPts =
          awayReportWidget!.getBonusPts();

      _matchup!.homeReportedResults.reported = true;
    } else if (_matchup!.isAway(nafName) ||
        _tournament!.isSquadCaptainFor(nafName, _matchup!.awayNafName)) {
      isHome = false;
      _matchup!.awayReportedResults.homeTds = homeReportWidget!.getTds();
      _matchup!.awayReportedResults.homeCas = homeReportWidget!.getCas();
      _matchup!.awayReportedResults.homeBonusPts =
          homeReportWidget!.getBonusPts();

      _matchup!.awayReportedResults.awayTds = awayReportWidget!.getTds();
      _matchup!.awayReportedResults.awayCas = awayReportWidget!.getCas();
      _matchup!.awayReportedResults.awayBonusPts =
          awayReportWidget!.getBonusPts();

      _matchup!.awayReportedResults.reported = true;
    } else {
      _matchup!.homeReportedResults.homeTds = homeReportWidget!.getTds();
      _matchup!.homeReportedResults.homeCas = homeReportWidget!.getCas();
      _matchup!.homeReportedResults.homeBonusPts =
          homeReportWidget!.getBonusPts();

      _matchup!.homeReportedResults.awayTds = awayReportWidget!.getTds();
      _matchup!.homeReportedResults.awayCas = awayReportWidget!.getCas();
      _matchup!.homeReportedResults.awayBonusPts =
          awayReportWidget!.getBonusPts();

      _matchup!.homeReportedResults.reported = true;

      _matchup!.awayReportedResults.homeTds = homeReportWidget!.getTds();
      _matchup!.awayReportedResults.homeCas = homeReportWidget!.getCas();
      _matchup!.awayReportedResults.homeBonusPts =
          homeReportWidget!.getBonusPts();

      _matchup!.awayReportedResults.awayTds = awayReportWidget!.getTds();
      _matchup!.awayReportedResults.awayCas = awayReportWidget!.getCas();
      _matchup!.awayReportedResults.awayBonusPts =
          awayReportWidget!.getBonusPts();

      _matchup!.awayReportedResults.reported = true;
    }

    try {
      UpdateMatchReportEvent event = isHome != null
          ? new UpdateMatchReportEvent(_tournament!, _matchup!, isHome)
          : new UpdateMatchReportEvent.admin(
              _tournament!, _matchup!, _tournament!.curRoundIdx());

      // ToastUtils.show(context, "Uploading Match Report!");

      context.read<AppBloc>().add(UpdateMatchEvent(context, event));
    } catch (_) {
      ToastUtils.showFailed(context,
          "Uploading Match Failed. Please reload the page and try again.");
    }
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

  Color? _getColor(bool home) {
    ReportedMatchResult? result;

    ReportedMatchResult homeResult = _matchup!.homeReportedResults;
    ReportedMatchResult awayResult = _matchup!.awayReportedResults;

    if (homeResult.reported && awayResult.reported) {
      bool areSameOutcome = homeResult.homeTds == awayResult.homeTds &&
          homeResult.awayTds == awayResult.awayTds;

      if (areSameOutcome) {
        result = homeResult;
      }
    } else if (homeResult.reported) {
      result = homeResult;
    } else if (awayResult.reported) {
      result = awayResult;
    }

    if (result == null) {
      return null;
    } else if (result.homeTds > result.awayTds) {
      return home ? Colors.green : Colors.red;
    } else if (result.homeTds < result.awayTds) {
      return home ? Colors.red : Colors.green;
    } else {
      return Colors.orange;
    }
  }
}
