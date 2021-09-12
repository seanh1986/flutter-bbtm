import 'dart:collection';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/widgets/matchup_coach_widget.dart';
import 'package:flutter/material.dart';

class MatchupReportWidget extends StatefulWidget {
  final IMatchupParticipant participant;
  final bool isHome;
  final UploadState state;

  MatchupReportWidget(
      {Key? key,
      required this.participant,
      required this.isHome,
      required this.state})
      : super(key: key);

  @override
  State<MatchupReportWidget> createState() {
    return _MatchupReportWidget();
  }
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  late IMatchupParticipant _participant;
  late UploadState _state;

  final String _tdName = "Tds";
  final String _casName = "Cas";

  Map<String, int> counts = LinkedHashMap();

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  final double fabSize = 40.0;

  @override
  void initState() {
    //refreshState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Refresh state
    refreshState();

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _itemHeadline(_participant, widget.isHome),
          _itemEditMatchDetails(_participant),
        ]);
  }

  Widget _itemHeadline(IMatchupParticipant participant, bool isHome) {
    Image logo = Image.asset('../../' + RaceUtils.getLogo(_participant.race()),
        fit: BoxFit.cover);

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        color: isHome
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
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
            trailing: null,
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

  bool _editableState() {
    return _state == UploadState.Editing || _state == UploadState.Error;
  }

  bool _hideFabs() {
    return _state == UploadState.NotAuthorized ||
        _state == UploadState.UploadedConfirmed;
  }

  void refreshState() {
    _participant = widget.participant;
    _state = widget.state;
    counts.putIfAbsent(_tdName, () => 0);
    counts.putIfAbsent(_casName, () => 0);
  }
}
