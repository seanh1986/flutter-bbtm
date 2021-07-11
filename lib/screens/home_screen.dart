import 'package:amorical_cup/data/coach_matchup.dart';
import 'package:amorical_cup/data/squad_matchup.dart';
import 'package:amorical_cup/data/tournament.dart';
import 'package:amorical_cup/screens/matchups_coaches_screen.dart';
import 'package:amorical_cup/screens/matchups_squad_screen.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';
import 'package:flutter/material.dart';
import 'package:amorical_cup/widgets/placeholder_widget.dart';
import 'package:amorical_cup/screens/rankings_coach.dart';
import 'package:amorical_cup/screens/rankings_squads.dart';

class HomePage extends StatefulWidget {
  final Tournament tournament;

  HomePage({Key? key, required this.tournament}) : super(key: key);

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

  List<SquadMatchup> _squadMatchups = [];

  List<CoachMatchup> _selectedCoachMatchups = [];

  List<_WidgetFamily> _children = [];

  @override
  void initState() {
    _tournament = widget.tournament;
    _squadMatchups = SquadMatchup.getExampleSquadMatchups(_tournament);

    _coachMatchupListener = new _CoachMatchupListClickListener(this);

    _children = [
      new _WidgetFamily([PlaceholderWidget(Colors.white)]),
      new _WidgetFamily([RankingCoachPage(tournament: _tournament)]),
      new _WidgetFamily([RankingSquadsPage(tournament: _tournament)]),
      new _WidgetFamily([
        SquadMatchupsPage(
          matchups: _squadMatchups,
          coachMatchupListeners: _coachMatchupListener,
        ),
        CoachMatchupsPage(matchups: _selectedCoachMatchups)
      ])
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_childIndex == 0) {
            if (_parentIndex == 0) {
              return true;
            }
            setState(() {
              _parentIndex = 0;
            });
            return false;
          } else {
            setState(() {
              _childIndex = 0;
            });
            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(_tournament.name),
          ),
          body: _children[_parentIndex].widgets[_childIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.poll), label: 'Rankings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
            currentIndex: _parentIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            onTap: _onItemTapped,
          ),
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _parentIndex = index;
      _childIndex = 0;
    });
  }

  void updateMatchupList(List<CoachMatchup> coachMatchups) {
    setState(() {
      _parentIndex = 3;
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
