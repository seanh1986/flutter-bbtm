import 'dart:collection';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/add_minus_widget/add_minus_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class MatchupReportWidget extends StatefulWidget {
  final TournamentInfo tounamentInfo;

  final IMatchupParticipant participant;
  final bool showHome;

  late final UploadState state;
  ReportedMatchResult? reportedMatch;

  late AddMinusWidget TdsWidget;
  late AddMinusWidget CasWidget;

  List<AddMinusWidget> bonusWidgets = [];

  final bool refreshState;

  final Color? titleColor;

  final bool isBonusPtsExpanded;

  final ValueChanged<bool>
      onBonusPtsToggle; // Callback function that will be called on toggle

  MatchupReportWidget(
      {Key? key,
      required this.tounamentInfo,
      required this.reportedMatch,
      required this.participant,
      required this.showHome,
      required this.state,
      required this.refreshState,
      required this.onBonusPtsToggle,
      required this.isBonusPtsExpanded,
      this.titleColor})
      : super(key: key) {
    bool editable = _editableState();
    bool showFab = !_hideFabs();
    Color? fillColor = _getFillColor();

    int tdInitVal = reportedMatch != null
        ? (showHome ? reportedMatch!.homeTds : reportedMatch!.awayTds)
        : 0;

    int casInitVal = reportedMatch != null
        ? (showHome ? reportedMatch!.homeCas : reportedMatch!.awayCas)
        : 0;

    TdsWidget = AddMinusWidget(
        item: AddMinusItem(
            name: "Tds",
            minValue: 0,
            value: tdInitVal,
            color: fillColor,
            editable: editable,
            showFab: showFab));

    CasWidget = AddMinusWidget(
        item: AddMinusItem(
            name: "Cas",
            minValue: 0,
            value: casInitVal,
            color: fillColor,
            editable: editable,
            showFab: showFab));

    int numBonus = tounamentInfo.scoringDetails.bonusPts.length;
    for (int i = 0; i < numBonus; i++) {
      BonusDetails infoBonusPts = tounamentInfo.scoringDetails.bonusPts[i];

      List<int> matchBonusPts =
          showHome ? reportedMatch!.homeBonusPts : reportedMatch!.awayBonusPts;

      int bonusInitVal =
          matchBonusPts.length == numBonus ? matchBonusPts[i] : 0;

      bonusWidgets.add(AddMinusWidget(
          item: AddMinusItem(
              name: infoBonusPts.name,
              minValue: 0,
              value: bonusInitVal,
              color: fillColor,
              editable: editable,
              showFab: showFab)));
    }
  }

  @override
  State<MatchupReportWidget> createState() {
    return _MatchupReportWidget();
  }

  int getTds() {
    return TdsWidget.item.value;
  }

  int getCas() {
    return CasWidget.item.value;
  }

  // Ensure correct order
  List<int> getBonusPts() {
    return bonusWidgets.map((b) => b.item.value).toList();
  }

  bool _editableState() {
    // return _state == UploadState.Editing || _state == UploadState.Error;
    return state != UploadState.NotAuthorized && state != UploadState.NotYetSet;
  }

  bool _hideFabs() {
    return state == UploadState.NotAuthorized || state == UploadState.NotYetSet;
  }

  Color? _getFillColor() {
    switch (state) {
      case UploadState.Error:
        return Colors.redAccent;
      case UploadState.UploadedConfirmed:
        return Colors.greenAccent;
      case UploadState.CanEdit:
        return Colors.orangeAccent;
      case UploadState.NotAuthorized:
      case UploadState.NotYetSet:
      case UploadState.Editing:
      case UploadState.CanConfirm:
      default:
        return Colors.white;
    }
  }
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  late IMatchupParticipant _participant;

  final double titleFontSize = kIsWeb ? 16.0 : 10.0;
  final double subTitleFontSize = kIsWeb ? 11.0 : 9.0;

  final double fabSize = kIsWeb ? 32.0 : 20.0;
  final double raceIconSize = kIsWeb ? 50.0 : 30.0;

  late Color? _titleColor;

  String _rosterFileName = "";
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();

    _refreshState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshState() {
    _participant = widget.participant;
    _titleColor = widget.titleColor;

    if (_participant is Coach) {
      Coach c = _participant as Coach;
      if (c.rosterFileName != _rosterFileName) {
        _rosterFileName = "";
      }
    } else {
      _rosterFileName = "";
    }

    isDownloaded = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refreshState) {
      _refreshState();
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _itemHeadline(_participant, widget.showHome),
          _itemEditMatchDetails(context, _participant),
        ]);
  }

  Widget _itemHeadline(IMatchupParticipant participant, bool isHome) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
        color: _titleColor,
        child: _itemHeader(participant));
  }

  void _handleRosterDownload() async {
    if (isDownloaded) {
      ToastUtils.showFailed(context, "Already Downloaded: " + _rosterFileName);
      return;
    }
    ToastUtils.show(context, "Downloading: " + _rosterFileName);

    context.read<AppBloc>().add(DownloadFile(_rosterFileName));
  }

  Widget _itemHeader(IMatchupParticipant participant) {
    Image? raceLogo;

    RawMaterialButton? roster;

    if (participant is Coach) {
      raceLogo = Image.asset(
        RaceUtils.getLogo(participant.race),
        fit: BoxFit.cover,
        height: raceIconSize,
      );

      if (_rosterFileName.isNotEmpty) {
        roster = RawMaterialButton(
            shape: CircleBorder(),
            fillColor: Colors.white,
            elevation: 0.0,
            child: Icon(
              Icons.assignment,
              color: Colors.black,
            ),
            onPressed: () => {_handleRosterDownload()});
      } else {
        try {
          context
              .read<AppBloc>()
              .getFileUrl(participant.rosterFileName)
              .then((value) => {
                    if (mounted)
                      {
                        setState(() {
                          _rosterFileName = participant.rosterFileName;
                        })
                      }
                  });

          // // LoadingIndicatorDialog().show(context);
          // _tournyBloc.getFileUrl(participant.rosterFileName).then((value) => {
          //       if (mounted)
          //         {
          //           setState(() {
          //             _rosterFileName = participant.rosterFileName;
          //           })
          //         }
          //     });
        } catch (e) {
          // Do nothing
        } finally {
          // LoadingIndicatorDialog().dismiss();
        }
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;

    // print("screenWidth: " + screenWidth.toString());

    Widget result;

    if (kIsWeb && screenWidth > 750) {
      // Ensure screen isn't too narrow
      result = ListTile(
        leading: raceLogo,
        title: Text(_participant.displayName(widget.tounamentInfo),
            style: TextStyle(fontSize: titleFontSize)),
        subtitle: Text(_participant.showRecord(),
            style: TextStyle(fontSize: subTitleFontSize)),
        trailing: roster,
        isThreeLine: false,
        // tileColor: _titleColor,
        tileColor: Colors.transparent,
      );
    } else {
      List<Widget> iconWidgets = [];

      if (raceLogo != null) {
        iconWidgets.add(raceLogo);
      }

      if (roster != null) {
        iconWidgets.add(roster);
      }

      result = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: iconWidgets),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_participant.displayName(widget.tounamentInfo),
                  style: TextStyle(fontSize: titleFontSize)),
              Text(_participant.showRecord(),
                  style: TextStyle(fontSize: subTitleFontSize)),
            ],
          ),
        ],
      );
    }

    return result;
  }

  Widget _itemEditMatchDetails(
      BuildContext context, IMatchupParticipant participant) {
    List<Widget> widgets = [
      SizedBox(height: 10),
      widget.TdsWidget,
      SizedBox(height: 10),
      widget.CasWidget,
      SizedBox(height: 10)
    ];

    widgets.addAll(_getBonusPtsWidgets());

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 6.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: widgets,
        ));
  }

  List<Widget> _getBonusPtsWidgets() {
    if (widget.bonusWidgets.isEmpty) {
      return [];
    }

    if (widget.isBonusPtsExpanded) {
      return _getBonusPtsWidgetsExpanded();
    } else {
      return _getBonusPtsWidgetsCompresssed();
    }
  }

  List<Widget> _getBonusPtsWidgetsCompresssed() {
    return [_getBonusPtsWidgetHeader()];
  }

  List<Widget> _getBonusPtsWidgetsExpanded() {
    List<Widget> bonusWidgets = [_getBonusPtsWidgetHeader()];

    if (widget.bonusWidgets.isNotEmpty) {
      widget.bonusWidgets.forEach((bonusWidget) {
        bonusWidgets.add(bonusWidget);
        bonusWidgets.add(SizedBox(height: 10));
      });
    }

    return bonusWidgets;
  }

  Widget _getBonusPtsWidgetHeader() {
    return GestureDetector(
      onTap: () {
        widget.onBonusPtsToggle.call(!widget.isBonusPtsExpanded);
      },
      child: Row(
        children: [
          Icon(
            widget.isBonusPtsExpanded
                ? Icons.expand_less
                : Icons.expand_more, // Chevron up or down
            size: 24.0,
          ),
          const SizedBox(
              width: 8.0), // Add some spacing between the chevron and the text
          Center(child: Text('Bonus Points', style: TextStyle(fontSize: 12.0))),
        ],
      ),
    );
  }
}
