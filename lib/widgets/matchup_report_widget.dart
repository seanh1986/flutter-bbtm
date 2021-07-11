import 'dart:collection';

import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/data/races.dart';
import 'package:flutter/material.dart';

class MatchupReportWidget extends StatefulWidget {
  final IMatchupParticipant participant;

  MatchupReportWidget({Key? key, required this.participant}) : super(key: key);

  @override
  State<MatchupReportWidget> createState() {
    return _MatchupReportWidget();
  }
}

enum UploadState {
  NotAuthorized,
  Editing,
  UploadedAwaiting,
  UploadedConfirmed,
  Error,
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  late IMatchupParticipant _participant;

  final String _tdName = "Tds";
  final String _casName = "Cas";

  Map<String, int> counts = LinkedHashMap();

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  final double fabSize = 40.0;

  final double uploadIconSize = 24.0;
  final double errUploadIconSize = 20.0;

  late UploadState _state;

  @override
  void initState() {
    super.initState();
    _state = UploadState.Editing;
    _participant = widget.participant;
    counts.putIfAbsent(_tdName, () => 0);
    counts.putIfAbsent(_casName, () => 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _itemHeadline(_participant),
          _itemEditMatchDetails(_participant),
        ]);
  }

  Widget _itemHeadline(IMatchupParticipant participant) {
    Image logo = Image.asset('../../' + RaceUtils.getLogo(_participant.race()),
        fit: BoxFit.cover);

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        color: Theme.of(context).primaryColorLight,
        child: Container(
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 44,
                minHeight: 44,
                maxWidth: 64,
                maxHeight: 64,
              ),
              child: logo,
            ),
            title: Container(
              child: Column(
                children: [
                  Text(_participant.name(),
                      style: TextStyle(fontSize: titleFontSize)),
                  Text(_participant.showRecord(),
                      style: TextStyle(fontSize: subTitleFontSize)),
                ],
              ),
            ),
            trailing: _itemUploadStatus(),
            onTap: () => {
              // TODO: send to server?
              setState(() {
                // Temporarily wrap around
                int curIdx = _state.index;
                int newIdx = (curIdx + 1) % UploadState.values.length;
                _state = UploadState.values[newIdx];
              })
            },
          ),
        ));
  }

  Widget _itemEditMatchDetails(IMatchupParticipant participant) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            _itemCounter(_tdName),
            SizedBox(height: 10),
            _itemCounter(_casName),
            SizedBox(height: 10),
          ],
        ));
  }

  Widget _itemCounter(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(name, style: TextStyle(fontSize: titleFontSize)),
        Container(
            width: fabSize,
            height: fabSize,
            child: _hideFabs()
                ? null
                : RawMaterialButton(
                    shape: CircleBorder(),
                    fillColor: // set color to identify editable or not
                        _editableState()
                            ? Theme.of(context).primaryColorLight
                            : Colors.grey,
                    elevation: 0.0,
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    onPressed:
                        _editableState() // only click-able in editing mode
                            ? () {
                                if (counts.containsKey(name)) {
                                  setState(() {
                                    counts.update(name, (value) => value + 1);
                                  });
                                }
                              }
                            : null,
                  )),
        Text(counts[name].toString(),
            style: TextStyle(fontSize: titleFontSize)),
        Container(
            width: fabSize,
            height: fabSize,
            child: _hideFabs()
                ? null
                : RawMaterialButton(
                    shape: CircleBorder(),
                    fillColor:
                        _editableState() // set color to identify editable or not
                            ? Theme.of(context).primaryColorLight
                            : Colors.grey,
                    elevation: 0.0,
                    child: Icon(
                      Icons.remove,
                      color: Colors.black,
                    ),
                    onPressed:
                        _editableState() // only click-able in editing mode
                            ? () {
                                if (counts.containsKey(name) &&
                                    counts[name]! > 0) {
                                  setState(() {
                                    counts.update(name, (value) => value - 1);
                                  });
                                }
                              }
                            : null,
                  )),
      ],
    );
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

  bool _editableState() {
    return _state == UploadState.Editing || _state == UploadState.Error;
  }

  bool _hideFabs() {
    return _state == UploadState.NotAuthorized ||
        _state == UploadState.UploadedConfirmed;
  }
}
