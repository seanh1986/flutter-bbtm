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
  NotAuthorized,
  Editing,
  UploadedAwaiting,
  ConfirmOrEdit,
  UploadedConfirmed,
  Error,
}

class _MatchupHeadlineWidget extends State<MatchupCoachWidget> {
  late Tournament _tournament;
  late AuthUser _authUser;
  late CoachMatchup _matchup;
  MatchupClickListener? _listener;

  late MatchReportBloc _matchReportBloc;

  late UploadState _state;

  final double titleFontSize = kIsWeb ? 20.0 : 14.0;
  final double subTitleFontSize = kIsWeb ? 14.0 : 12.0;

  final double uploadIconSize = kIsWeb ? 24.0 : 15.0;
  final double errUploadIconSize = kIsWeb ? 20.0 : 12.0;

  final double itemUploadSize = kIsWeb ? 50.0 : 40.0;

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

    ReportedMatchResultWithStatus reportWithStatus =
        _matchup.getReportedMatchStatus();

    Authorization authorization =
        _tournament.getMatchAuthorization(_matchup, _authUser);

    _state = _getMatchUploadState(reportWithStatus, authorization);

    homeReportWidget = MatchupReportWidget(
        reportedMatch: reportWithStatus,
        participant: _matchup.home(_tournament),
        showHome: true,
        state: _state);

    awayReportWidget = MatchupReportWidget(
        reportedMatch: reportWithStatus,
        participant: _matchup.away(_tournament),
        showHome: false,
        state: _state);
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
                authorization == Authorization.HomeCaptain
            ? UploadState.UploadedAwaiting
            : UploadState.ConfirmOrEdit;
      case ReportedMatchStatus.AwayReported:
        return authorization == Authorization.AwayCoach ||
                authorization == Authorization.AwayCaptain
            ? UploadState.UploadedAwaiting
            : UploadState.ConfirmOrEdit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchReportBloc, MatchReportState>(
        bloc: _matchReportBloc,
        builder: (selectContext, selectState) {
          return Container(
              alignment: FractionalOffset.center, child: _coachMatchupWidget());
        });
  }

  Widget _coachMatchupWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 10.0),
                  child: homeReportWidget)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: itemUploadSize,
                  height: itemUploadSize,
                  child: _hideItemUploadBtn()
                      ? null
                      : RawMaterialButton(
                          shape: CircleBorder(),
                          fillColor: Theme.of(context).primaryColorLight,
                          elevation: 0.0,
                          child: _itemUploadStatus(),
                          onPressed: () => {
                            // TODO: send to server?
                            _uploadToServer()

                            // setState(() {
                            //   // Temporarily wrap around
                            //   int curIdx = _state.index;
                            //   int newIdx = (curIdx + 1) % UploadState.values.length;
                            //   _state = UploadState.values[newIdx];
                            // }),
                          },
                        )),
              Text(' vs. ', style: TextStyle(fontSize: titleFontSize)),
            ],
          ),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 10.0),
                  child: awayReportWidget)),
        ]);
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
      case UploadState.UploadedAwaiting:
        return Icon(
          Icons.pending_actions,
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
