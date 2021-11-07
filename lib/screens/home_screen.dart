import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/squad_matchup.dart';
import 'package:bbnaf/models/tournament.dart';
import 'package:bbnaf/screens/overview_screen.dart';
import 'package:bbnaf/screens/rankings_screen.dart';
import 'package:bbnaf/screens/tournament_list_screen.dart';
import 'package:bbnaf/utils/item_click_listener.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/widgets/placeholder_widget.dart';
import 'package:flutter/scheduler.dart';

import 'matchups/matchups_coaches_screen.dart';
import 'matchups/matchups_squad_screen.dart';

class HomePage extends StatefulWidget {
  final Tournament tournament;
  final String? nafName;

  HomePage({Key? key, required this.tournament, this.nafName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _WidgetFamily {
  List<Widget> widgets;
  _WidgetFamily(this.widgets);
}

class _HomePageState extends State<HomePage> {
  int _parentIndex = 0;
  int _childIndex = 0;

  _CoachMatchupListClickListener? _coachMatchupListener;

  late Tournament _tournament;
  late String? _nafName;

  List<SquadMatchup> _squadMatchups = [];

  List<CoachMatchup> _selectedCoachMatchups = [];

  List<_WidgetFamily> _children = [];

  @override
  void initState() {
    _tournament = widget.tournament;
    _nafName = widget.nafName;
    _squadMatchups = _tournament.curSquadRound!.squadMatchups;

    _coachMatchupListener = new _CoachMatchupListClickListener(this);

    List<Widget> matchupWidgets = [];
    if (_tournament.useSquads) {
      matchupWidgets.add(SquadMatchupsPage(
        matchups: _squadMatchups,
        coachMatchupListeners: _coachMatchupListener,
      ));
    }
    matchupWidgets.add(CoachMatchupsPage(matchups: _selectedCoachMatchups));

    _children = [
      new _WidgetFamily([
        OverviewScreen(
          tournament: _tournament,
          nafName: _nafName,
        )
      ]),
      new _WidgetFamily(matchupWidgets),
      new _WidgetFamily([RankingsPage(tournament: _tournament)]),
      new _WidgetFamily([PlaceholderWidget(Colors.black)]),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _handleBackButton();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.white),
            //   onPressed: () => Navigator.of(context).pop(),
            // ),
            title: Text(_tournament.info.name),
          ),
          body: _children[_parentIndex].widgets[_childIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.sports_football), label: 'Matches'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.poll), label: 'Rankings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
            currentIndex: _parentIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            onTap: _onItemTapped,
          ),
        ));
  }

  void _handleBackButton() {
    if (_childIndex == 0) {
      if (_parentIndex == 0) {
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TournamentListPage()));
        });
      } else {
        setState(() {
          _parentIndex = 0;
        });
      }
    } else {
      setState(() {
        _childIndex = 0;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _parentIndex = index;
      _childIndex = 0;
    });
  }

  void updateMatchupList(List<CoachMatchup> coachMatchups) {
    setState(() {
      _parentIndex = 1;
      _childIndex = 1;

      _WidgetFamily wFamily = _children[_parentIndex];

      if (wFamily.widgets.length > _childIndex) {
        Widget w = new CoachMatchupsPage(matchups: coachMatchups);
        wFamily.widgets[_childIndex] = w;
      }
    });
  }
}

class _CoachMatchupListClickListener implements CoachMatchupListClickListener {
  final _HomePageState _state;

  _CoachMatchupListClickListener(this._state);

  @override
  void onItemClicked(List<CoachMatchup> matchups) {
    _state.updateMatchupList(matchups);
  }
}
