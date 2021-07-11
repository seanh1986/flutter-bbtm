import 'dart:collection';

import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/data/races.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';
import 'package:flutter/material.dart';

class MatchupReportWidget extends StatefulWidget {
  final IMatchupParticipant participant;

  MatchupReportWidget({Key key, @required this.participant}) : super(key: key);

  @override
  State<MatchupReportWidget> createState() {
    return _MatchupReportWidget();
  }
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  IMatchupParticipant _participant;

  final String _tdName = "Tds";
  final String _casName = "Cas";

  Map<String, int> counts = LinkedHashMap();

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  final double fabSize = 40.0;

  @override
  void initState() {
    super.initState();
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
            trailing: Icon(Icons.cloud_upload_rounded),
            onTap: () => {
              // TODO: send to server?
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
            child: new RawMaterialButton(
              shape: new CircleBorder(),
              fillColor: Colors.white,
              elevation: 0.0,
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  counts[name]++;
                });
              },
            )),
        Text(counts[name].toString(),
            style: TextStyle(fontSize: titleFontSize)),
        Container(
            width: fabSize,
            height: fabSize,
            child: new RawMaterialButton(
              shape: new CircleBorder(),
              fillColor: Colors.white,
              elevation: 0.0,
              child: Icon(
                Icons.remove,
                color: Colors.black,
              ),
              onPressed: () {
                if (counts[name] > 0) {
                  setState(() {
                    counts[name]--;
                  });
                }
              },
            )),
      ],
    );
  }
}
