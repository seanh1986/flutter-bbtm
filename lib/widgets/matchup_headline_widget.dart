import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';
import 'package:amorical_cup/widgets/matchup_report_widget.dart';
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
        alignment: FractionalOffset.center, child: _getWidgetByOrgType());
  }

  Widget _getWidgetByOrgType() {
    switch (_matchup.type()) {
      case OrgType.Coach:
        return _coachMatchupWidget();
      case OrgType.Squad:
      default:
        return _squadMatchupWidget();
    }
  }

  Widget _squadMatchupWidget() {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            onTap: () => {
                  if (_listener != null) {_listener.onItemClicked(_matchup)}
                },
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

  Widget _coachMatchupWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MatchupReportWidget(participant: _matchup.home()))),
          Text(' vs. ', style: TextStyle(fontSize: titleFontSize)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MatchupReportWidget(participant: _matchup.away()))),
        ]);
  }
}
