import 'dart:collection';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/screens/matchups/matchup_coach_widget.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class MatchupReportWidget extends StatefulWidget {
  final TournamentInfo tounamentInfo;

  final IMatchupParticipant participant;
  final bool showHome;

  late final UploadState state;
  late ReportedMatchResult? reportedMatch;

  // Allows passing primitives by reference
  Map<String, int> counts = LinkedHashMap();

  final String _tdName = "Tds";
  final String _casName = "Cas";

  final bool refreshState;

  MatchupReportWidget(
      {Key? key,
      required this.tounamentInfo,
      required this.reportedMatch,
      required this.participant,
      required this.showHome,
      required this.state,
      required this.refreshState})
      : super(key: key) {
    if (reportedMatch != null) {
      counts.putIfAbsent(_tdName,
          () => showHome ? reportedMatch!.homeTds : reportedMatch!.awayTds);
      counts.putIfAbsent(_casName,
          () => showHome ? reportedMatch!.homeCas : reportedMatch!.awayCas);

      int numBonus = tounamentInfo.scoringDetails.bonusPts.length;
      for (int i = 0; i < numBonus; i++) {
        BonusDetails infoBonusPts = tounamentInfo.scoringDetails.bonusPts[i];

        List<int> matchBonusPts = showHome
            ? reportedMatch!.homeBonusPts
            : reportedMatch!.awayBonusPts;

        int cnt = matchBonusPts.length == numBonus ? matchBonusPts[i] : 0;

        counts.putIfAbsent(infoBonusPts.name, () => cnt);
      }
    }
  }

  @override
  State<MatchupReportWidget> createState() {
    return _MatchupReportWidget();
  }

  int getTds() {
    int? tds = counts[_tdName];
    return tds != null ? tds : 0;
  }

  int getCas() {
    int? cas = counts[_casName];
    return cas != null ? cas : 0;
  }

  // Ensure correct order
  List<int> getBonusPts() {
    List<int> bonusPts = [];

    tounamentInfo.scoringDetails.bonusPts.forEach((bonusDetails) {
      int? bonus = counts[bonusDetails.name];
      bonusPts.add(bonus != null ? bonus : 0);
    });

    return bonusPts;
  }
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  late IMatchupParticipant _participant;
  late UploadState _state;

  final double titleFontSize = kIsWeb ? 16.0 : 10.0;
  final double subTitleFontSize = kIsWeb ? 11.0 : 9.0;

  final double fabSize = kIsWeb ? 25.0 : 15.0;
  final double raceIconSize = kIsWeb ? 50.0 : 30.0;

  late TournamentBloc _tournyBloc;

  late FToast fToast;

  String _rosterFileName = "";
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _refreshState();
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  void _refreshState() {
    _participant = widget.participant;
    _state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    if (widget.refreshState) {
      _refreshState();
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _itemHeadline(_participant, widget.showHome),
          _itemEditMatchDetails(_participant),
        ]);
  }

  Widget _itemHeadline(IMatchupParticipant participant, bool isHome) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
        color: isHome
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        child: _itemHeader(participant));
  }

  void _handleRosterDownload() async {
    fToast.init(context);
    if (isDownloaded) {
      ToastUtils.showFailed(fToast, "Already Downloaded: " + _rosterFileName);
      return;
    }
    ToastUtils.show(fToast, "Downloading: " + _rosterFileName);

    // LoadingIndicatorDialog().show(context);
    isDownloaded =
        await _tournyBloc.downloadFile(DownloadFile(_rosterFileName));
    // LoadingIndicatorDialog().dismiss();
  }

  Widget _itemHeader(IMatchupParticipant participant) {
    Image? raceLogo;

    RawMaterialButton? roster;

    if (participant is Coach) {
      raceLogo = Image.asset(
        RaceUtils.getLogo(participant.race),
        fit: BoxFit.cover,
        height: raceIconSize,
        // scale: kIsWeb ? 1.0 : 0.75,
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
          // LoadingIndicatorDialog().show(context);
          _tournyBloc.getFileUrl(participant.rosterFileName).then((value) => {
                if (mounted)
                  {
                    setState(() {
                      _rosterFileName = participant.rosterFileName;
                    })
                  }
              });
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
        title: Text(_participant.name(),
            style: TextStyle(fontSize: titleFontSize)),
        subtitle: Text(_participant.showRecord(),
            style: TextStyle(fontSize: subTitleFontSize)),
        trailing: roster,
        isThreeLine: false,
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
              Text(_participant.name(),
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

  Widget _itemEditMatchDetails(IMatchupParticipant participant) {
    List<Widget> widgets = [
      SizedBox(height: 10),
      _itemCounter(widget._tdName),
      SizedBox(height: 10),
      _itemCounter(widget._casName),
      SizedBox(height: 10)
    ];

    Widget? bonusPtsWidget = _getBonusPtsWidget(participant.name());
    if (bonusPtsWidget != null) {
      widgets.add(bonusPtsWidget);
      widgets.add(SizedBox(height: 10));
    }

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: widgets,
        ));
  }

  Widget? _getBonusPtsWidget(String nafName) {
    if (widget.tounamentInfo.scoringDetails.bonusPts.isEmpty) {
      return null;
    }

    VoidCallback callback = () {
      _showBonusDialog(nafName);
    };

    return ElevatedButton(
        onPressed: () {
          callback();
        },
        child: Text('Bonus Pts'));
  }

  Future<void> _showBonusDialog(String nafName) async {
    String title = "Bonus Points: " + nafName;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          List<Widget> widgets = [];

          VoidCallback callback = (() {
            setState(() {});
          });

          widget.tounamentInfo.scoringDetails.bonusPts.forEach((element) {
            widgets.add(_itemCounterCallback(element.name, () {
              callback();
            }));
            widgets.add(SizedBox(height: 10));
          });

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
            ],
          );
        });
      },
    );
  }

  Widget _itemCounter(String name) {
    return _itemCounterCallback(name, null);
  }

  Widget _itemCounterCallback(String name, VoidCallback? callback) {
    int? num = widget.counts[name];
    String numStr = num != null ? num.toString() : "?";

    bool showFabs = !_hideFabs();

    List<Widget> widgets = [
      Text(numStr, style: TextStyle(fontSize: titleFontSize))
    ];

    if (showFabs) {
      widgets.add(Container(
          child: Wrap(
        children: [
          RawMaterialButton(
            shape: CircleBorder(),
            fillColor: _getFillColor(),
            elevation: 0.0,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: _editableState() // only click-able in editing mode
                ? () {
                    if (widget.counts.containsKey(name)) {
                      if (mounted) {
                        setState(() {
                          widget.counts.update(name, (value) => value + 1);
                        });
                      }
                    }

                    if (callback != null) {
                      callback();
                    }
                  }
                : null,
          )
        ],
      )));
    }

    widgets.add(Text(name, style: TextStyle(fontSize: titleFontSize)));

    if (showFabs) {
      widgets.add(Container(
          child: Wrap(
        children: [
          RawMaterialButton(
            shape: CircleBorder(),
            fillColor: _getFillColor(),
            elevation: 0.0,
            child: Icon(
              Icons.remove,
              color: Colors.black,
            ),
            onPressed: _editableState() // only click-able in editing mode
                ? () {
                    if (widget.counts.containsKey(name) &&
                        widget.counts[name]! > 0) {
                      if (mounted) {
                        setState(() {
                          widget.counts.update(name, (value) => value - 1);
                        });
                      }
                    }

                    if (callback != null) {
                      callback();
                    }
                  }
                : null,
          )
        ],
      )));
    }

    // Wrap width, Match height ?
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: widgets)
      ]),
    );
  }

  bool _editableState() {
    // return _state == UploadState.Editing || _state == UploadState.Error;
    return _state != UploadState.NotAuthorized &&
        _state != UploadState.NotYetSet;
  }

  bool _hideFabs() {
    // return _state == UploadState.NotAuthorized ||
    //     _state == UploadState.UploadedConfirmed;
    return _state == UploadState.NotAuthorized ||
        _state == UploadState.NotYetSet;
  }

  Color? _getFillColor() {
    switch (_state) {
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
        return Theme.of(context).primaryColorLight;
    }
  }
}
