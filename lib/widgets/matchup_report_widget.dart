import 'dart:collection';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/widgets/matchup_coach_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MatchupReportWidget extends StatefulWidget {
  final IMatchupParticipant participant;
  final bool showHome;

  late final UploadState state;
  late final ReportedMatchResult? reportedMatch;

  // Allows passing primitives by reference
  final Map<String, int> counts = LinkedHashMap();

  final String _tdName = "Tds";
  final String _casName = "Cas";

  MatchupReportWidget({
    Key? key,
    required this.reportedMatch,
    required this.participant,
    required this.showHome,
    required this.state,
  }) : super(key: key) {
    if (reportedMatch != null) {
      counts.putIfAbsent(_tdName,
          () => showHome ? reportedMatch!.homeTds : reportedMatch!.awayTds);
      counts.putIfAbsent(_casName,
          () => showHome ? reportedMatch!.homeCas : reportedMatch!.awayCas);
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
}

class _MatchupReportWidget extends State<MatchupReportWidget> {
  late IMatchupParticipant _participant;
  late UploadState _state;

  late Map<String, int> counts;

  final double titleFontSize = kIsWeb ? 16.0 : 10.0;
  final double subTitleFontSize = kIsWeb ? 11.0 : 9.0;

  final double fabSize = kIsWeb ? 25.0 : 15.0;
  final double raceIconSize = kIsWeb ? 50.0 : 30.0;

  @override
  void initState() {
    super.initState();
    counts = widget.counts;
  }

  @override
  Widget build(BuildContext context) {
    // Refresh state
    refreshState();

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
        child: _itemHeader(participant)
        // kIsWeb
        //     ? _itemHeaderWeb(participant)
        //     : _itemHeaderMobile(participant)
        );
  }

  Widget _itemHeader(IMatchupParticipant participant) {
    Image raceLogo = Image.asset(
      RaceUtils.getLogo(_participant.race()),
      fit: BoxFit.cover,
      height: raceIconSize,
      // scale: kIsWeb ? 1.0 : 0.75,
    );

    RawMaterialButton? roster = null;

    if (participant is Coach) {
      // && participant) {
      roster = RawMaterialButton(
        shape: CircleBorder(),
        fillColor: Colors.white,
        elevation: 0.0,
        child: Icon(
          Icons.assignment,
          color: Colors.black,
        ),
        onPressed: () => {
          // TODO...
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;

    print("screenWidth: " + screenWidth.toString());

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
      List<Widget> iconWidgets = [raceLogo];
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

//   Widget _itemHeaderWeb(IMatchupParticipant participant) {
//     Image raceLogo = Image.asset(
//       RaceUtils.getLogo(_participant.race()),
//       fit: BoxFit.cover,
//       scale: kIsWeb ? 0.75 : 0.50,
//     );

// // // TODO: show or hide depending on roster
// //     RawMaterialButton roster = RawMaterialButton(
// //       shape: CircleBorder(),
// //       fillColor: Colors.white,
// //       elevation: 0.0,
// //       child: Icon(
// //         Icons.assignment,
// //         color: Colors.black,
// //       ),
// //       onPressed: () => {},
// //     );

//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//       leading: raceLogo,
//       title:
//           Text(_participant.name(), style: TextStyle(fontSize: titleFontSize)),
//       subtitle: Text(_participant.showRecord(),
//           style: TextStyle(fontSize: subTitleFontSize)),
//       trailing: null,
//     );
//   }

//   Widget _itemHeaderMobile(IMatchupParticipant participant) {
//     Image logo =
//         Image.asset(RaceUtils.getLogo(_participant.race()), fit: BoxFit.cover);

//     return Column(
//       children: [
//         Container(
//             margin: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 3.0),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minWidth: 10,
//                 minHeight: 10,
//                 maxWidth: 50,
//                 maxHeight: 50,
//               ),
//               child: logo,
//             )),
//         Container(
//           width: double.infinity,
//           margin: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 6.0),
//           child: Column(
//             children: [
//               Text(_participant.name(),
//                   style: TextStyle(fontSize: titleFontSize)),
//               Text(_participant.showRecord(),
//                   style: TextStyle(fontSize: subTitleFontSize)),
//             ],
//           ),
//         ),
//       ],
//       mainAxisAlignment: MainAxisAlignment.center,
//     );
//   }

  Widget _itemEditMatchDetails(IMatchupParticipant participant) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
        child: Wrap(
          children: [
            SizedBox(height: 10),
            _itemCounter(widget._tdName),
            SizedBox(height: 10),
            _itemCounter(widget._casName),
            SizedBox(height: 10),
          ],
        ));
  }

  Widget _itemCounter(String name) {
    int? num = counts[name];
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
            fillColor: // set color to identify editable or not
                _editableState()
                    ? Theme.of(context).primaryColorLight
                    : Colors.grey,
            elevation: 0.0,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: _editableState() // only click-able in editing mode
                ? () {
                    if (counts.containsKey(name)) {
                      setState(() {
                        counts.update(name, (value) => value + 1);
                      });
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
            fillColor: _editableState() // set color to identify editable or not
                ? Theme.of(context).primaryColorLight
                : Colors.grey,
            elevation: 0.0,
            child: Icon(
              Icons.remove,
              color: Colors.black,
            ),
            onPressed: _editableState() // only click-able in editing mode
                ? () {
                    if (counts.containsKey(name) && counts[name]! > 0) {
                      setState(() {
                        counts.update(name, (value) => value - 1);
                      });
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

    // children: <Widget>[
    //   Text(numStr, style: TextStyle(fontSize: titleFontSize)),
    // Container(
    //     width: fabSize,
    //     height: fabSize,
    //     child: _hideFabs()
    //         ? null
    //         : RawMaterialButton(
    //             shape: CircleBorder(),
    //             fillColor: // set color to identify editable or not
    //                 _editableState()
    //                     ? Theme.of(context).primaryColorLight
    //                     : Colors.grey,
    //             elevation: 0.0,
    //             child: Icon(
    //               Icons.add,
    //               color: Colors.black,
    //             ),
    //             onPressed:
    //                 _editableState() // only click-able in editing mode
    //                     ? () {
    //                         if (counts.containsKey(name)) {
    //                           setState(() {
    //                             counts.update(name, (value) => value + 1);
    //                           });
    //                         }
    //                       }
    //                     : null,
    //           )),
    //   Text(name, style: TextStyle(fontSize: titleFontSize)),
    //   Container(
    //       width: fabSize,
    //       height: fabSize,
    //       child: _hideFabs()
    //           ? null
    //           : RawMaterialButton(
    //               shape: CircleBorder(),
    //               fillColor:
    //                   _editableState() // set color to identify editable or not
    //                       ? Theme.of(context).primaryColorLight
    //                       : Colors.grey,
    //               elevation: 0.0,
    //               child: Icon(
    //                 Icons.remove,
    //                 color: Colors.black,
    //               ),
    //               onPressed:
    //                   _editableState() // only click-able in editing mode
    //                       ? () {
    //                           if (counts.containsKey(name) &&
    //                               counts[name]! > 0) {
    //                             setState(() {
    //                               counts.update(name, (value) => value - 1);
    //                             });
    //                           }
    //                         }
    //                       : null,
    //             )),
    // ],
    // );
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
    // widget.homeTds = 0;
    // widget.cas = 0;
  }
}
