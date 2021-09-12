import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/utils/item_click_listener.dart';
import 'package:bbnaf/widgets/matchup_report_widget.dart';
import 'package:flutter/material.dart';

class MatchupCoachWidget extends StatefulWidget {
  final CoachMatchup matchup;
  final MatchupClickListener? listener;

  MatchupCoachWidget({Key? key, required this.matchup, this.listener})
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
  UploadedConfirmed,
  Error,
}

class _MatchupHeadlineWidget extends State<MatchupCoachWidget> {
  late CoachMatchup _matchup;
  MatchupClickListener? _listener;

  late UploadState _state;

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  final double uploadIconSize = 24.0;
  final double errUploadIconSize = 20.0;

  final double itemUploadSize = 50.0;

  @override
  void initState() {
    super.initState();
    _matchup = widget.matchup;
    _listener = widget.listener;

    // TODO: get state from Matchup repository
    _state = UploadState.Editing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: FractionalOffset.center, child: _coachMatchupWidget());
  }

  Widget _coachMatchupWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MatchupReportWidget(
                    participant: _matchup.home(),
                    isHome: true,
                    state: _state,
                  ))),
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
                            setState(() {
                              // Temporarily wrap around
                              int curIdx = _state.index;
                              int newIdx =
                                  (curIdx + 1) % UploadState.values.length;
                              _state = UploadState.values[newIdx];
                            }),
                          },
                        )),
              Text(' vs. ', style: TextStyle(fontSize: titleFontSize)),
            ],
          ),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MatchupReportWidget(
                      participant: _matchup.away(),
                      isHome: false,
                      state: _state))),
        ]);
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
