import 'package:amorical_cup/models/squad_matchup.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';
import 'package:flutter/material.dart';

class MatchupSquadWidget extends StatefulWidget {
  final SquadMatchup matchup;
  final MatchupClickListener? listener;

  MatchupSquadWidget({Key? key, required this.matchup, this.listener})
      : super(key: key);

  @override
  State<MatchupSquadWidget> createState() {
    return _MatchupSquadWidget();
  }
}

class _MatchupSquadWidget extends State<MatchupSquadWidget> {
  late SquadMatchup _matchup;
  MatchupClickListener? _listener;
  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _matchup = widget.matchup;
    _listener = widget.listener;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: FractionalOffset.center, child: _squadMatchupWidget());
  }

  Widget _squadMatchupWidget() {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            onTap: () => {_listener!.onItemClicked(_matchup)},
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Column(
                          children: [
                            Text(_matchup.home().name(),
                                style: TextStyle(fontSize: titleFontSize)),
                            Text(_matchup.home().showRecord(),
                                style: TextStyle(fontSize: subTitleFontSize)),
                          ],
                        ),
                      )),
                      Text(
                        ' vs. ',
                        style: TextStyle(fontSize: titleFontSize),
                      ),
                      Expanded(
                          child: Container(
                        child: Column(
                          children: [
                            Text(_matchup.away().name(),
                                style: TextStyle(fontSize: titleFontSize)),
                            Text(_matchup.away().showRecord(),
                                style: TextStyle(fontSize: subTitleFontSize)),
                          ],
                        ),
                      )),
                    ]))));
  }
}
