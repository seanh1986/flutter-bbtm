import 'package:bbnaf/blocs/match_report/match_report.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/utils/item_click_listener.dart';
import 'package:bbnaf/widgets/matchup_report_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchupCoachWidget extends StatefulWidget {
  Tournament tournament;
  final AuthUser authUser;
  final CoachMatchup matchup;
  final MatchupClickListener? listener;

  MatchupCoachWidget(
      {Key? key,
      required this.tournament,
      required this.authUser,
      required this.matchup,
      this.listener})
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
  MatchupClickListener? _listener;

  late MatchReportBloc _matchReportBloc;

  late ReportedMatchResultWithStatus _reportWithStatus;
  UploadState _state = UploadState.NotYetSet;

  final double titleFontSize = kIsWeb ? 20.0 : 12.0;
  final double subTitleFontSize = kIsWeb ? 14.0 : 10.0;

  final double uploadIconSize = kIsWeb ? 24.0 : 12.0;
  final double errUploadIconSize = kIsWeb ? 20.0 : 10.0;

  final double itemUploadSize = kIsWeb ? 50.0 : 30.0;

  late MatchupReportWidget homeReportWidget;
  late MatchupReportWidget awayReportWidget;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _authUser = widget.authUser;
    _matchup = widget.matchup;
    _listener = widget.listener;

    _matchReportBloc = BlocProvider.of<MatchReportBloc>(context);

    _reportWithStatus = _matchup.getReportedMatchStatus();

    Authorization authorization =
        _tournament.getMatchAuthorization(_matchup, _authUser);

    if (_state == UploadState.NotYetSet) {
      _state = _getMatchUploadState(_reportWithStatus, authorization);
    }

    print("Matchup: " +
        _matchup.homeNafName +
        " vs. " +
        _matchup.awayNafName +
        " -> " +
        _state.toString());
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

  @override
  Widget build(BuildContext context) {
    homeReportWidget = MatchupReportWidget(
        reportedMatch: _reportWithStatus,
        participant: _matchup.home(_tournament),
        showHome: true,
        state: _state);

    awayReportWidget = MatchupReportWidget(
        reportedMatch: _reportWithStatus,
        participant: _matchup.away(_tournament),
        showHome: false,
        state: _state);

    return BlocBuilder<MatchReportBloc, MatchReportState>(
        bloc: _matchReportBloc,
        builder: (selectContext, selectState) {
          return Container(
              alignment: FractionalOffset.center, child: _coachMatchupWidget());
        });
  }

  Widget _coachMatchupWidget() {
    List<Widget> tableVsDetails = [];

    if (!_hideItemUploadBtn()) {
      tableVsDetails.add(Container(
          child: Wrap(
        children: [
          RawMaterialButton(
            shape: CircleBorder(),
            fillColor: Theme.of(context).primaryColorLight,
            elevation: 0.0,
            child: _itemUploadStatus(),
            onPressed: () => {_handleUploadOrEditPressEvent()},
          )
        ],
      )));
    }

    tableVsDetails
        .add(Text(' vs. ', style: TextStyle(fontSize: subTitleFontSize)));
    tableVsDetails.add(Text('T#' + _matchup.tableNum().toString(),
        style: TextStyle(fontSize: subTitleFontSize)));

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 10.0),
                  child: homeReportWidget)),
          Card(
            child: Padding(
                padding: EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tableVsDetails)),
          ),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 10.0),
                  child: awayReportWidget)),
        ]);
  }

  void _handleUploadOrEditPressEvent() {
    switch (_state) {
      case UploadState.Editing:
      case UploadState.CanConfirm:
        _uploadToServer();
        break;
      case UploadState.CanEdit:
      case UploadState.Error:
        setState(() {
          _state = UploadState.Editing;
        });
        break;
      case UploadState.UploadedConfirmed:
      // case UploadState.UploadedAwaiting:
      case UploadState.NotAuthorized:
      default:
        return;
    }
  }

  void _uploadToServer() {
    bool? isHome; // fall back (e.g. for admin)
    if (_matchup.homeNafName == _authUser.nafName) {
      isHome = true;
      _matchup.homeReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.homeReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.homeReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.homeReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.homeReportedResults.reported = true;
    } else if (_matchup.awayNafName == _authUser.nafName) {
      isHome = false;
      _matchup.awayReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.awayReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.awayReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.awayReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.awayReportedResults.reported = true;
    }
    // TODO: check if squad captain
    // else if () {

    // }
    else {
      _matchup.homeReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.homeReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.homeReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.homeReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.homeReportedResults.reported = true;

      _matchup.awayReportedResults.homeTds = homeReportWidget.getTds();
      _matchup.awayReportedResults.homeCas = homeReportWidget.getCas();
      _matchup.awayReportedResults.awayTds = awayReportWidget.getTds();
      _matchup.awayReportedResults.awayCas = awayReportWidget.getCas();
      _matchup.awayReportedResults.reported = true;
    }

    if (isHome != null) {
      _matchReportBloc
          .add(new UpdateMatchReportEvent(_tournament, _matchup, isHome));
    } else {
      _matchReportBloc
          .add(new UpdateMatchReportEvent.admin(_tournament, _matchup));
    }

    setState(() {
      _state = UploadState.CanEdit;
    });
  }

  Widget? _itemUploadStatus() {
    switch (_state) {
      case UploadState.NotAuthorized:
        return null;
      case UploadState.Editing:
        return Icon(
          Icons.cloud_upload_rounded,
          color: Colors.white,
          size: uploadIconSize,
        );
      // case UploadState.UploadedAwaiting:
      //   return Icon(
      //     Icons.query_builder,
      //     color: Colors.orange,
      //     size: uploadIconSize,
      //   );
      case UploadState.CanEdit:
        return Icon(
          Icons.create_outlined,
          color: Colors.orange,
          size: uploadIconSize,
        );
      case UploadState.CanConfirm:
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
      case UploadState.NotYetSet:
        double shift = 0.5 * uploadIconSize;

        return Container(
            width: uploadIconSize + shift,
            height: uploadIconSize + shift,
            child: Stack(children: [
              Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white,
                size: uploadIconSize,
              ),
              Positioned(
                  left: shift,
                  top: shift,
                  child: Icon(Icons.report,
                      color: Colors.red, size: errUploadIconSize))
            ]));
    }
  }

  bool _hideItemUploadBtn() {
    return _state == UploadState.NotAuthorized;
  }
}
