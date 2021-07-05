import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/data/races.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';
import 'package:flutter/material.dart';

class MatchupHeadlineWidget extends StatefulWidget {
  final IMatchup matchup;
  final MatchupClickListener listener;

  MatchupHeadlineWidget({Key key, @required this.matchup, this.listener})
      : super(key: key);

  @override
  State<MatchupHeadlineWidget> createState() {
    return _MatchupHeadlineWidget();
  }
}

class _MatchupHeadlineWidget extends State<MatchupHeadlineWidget> {
  IMatchup _matchup;
  MatchupClickListener _listener;

  @override
  void initState() {
    _matchup = widget.matchup;
    _listener = widget.listener;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: FractionalOffset.center,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _itemMatchupParticipant(_matchup.home()))),
              Text(' vs '),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _itemMatchupParticipant(_matchup.away()))),
            ]));
  }

  Widget _itemMatchupParticipant(IMatchupParticipant participant) {
    Image logo = Image.asset('../../' + RaceUtils.getLogo(participant.race()),
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
            title: Text(participant.name()),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => {
              if (_listener != null) {_listener.onItemClicked(_matchup)}
            },
          ),
        ));
  }
}
