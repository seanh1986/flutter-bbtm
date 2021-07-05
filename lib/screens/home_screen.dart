import 'package:amorical_cup/data/coach_matchup.dart';
import 'package:amorical_cup/data/i_matchup.dart';
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

  _CoachMatchupListClickListener _coachMatchupListener;

  Tournament _tournament;

  List<IMatchup> _matchups;

  List<_WidgetFamily> _children;

  @override
  void initState() {
    if (_tournament == null) {
      _tournament = Tournament.getExampleTournament();
      _matchups = SquadMatchup.getExampleSquadMatchups(_tournament);
    }

    _coachMatchupListener = new _CoachMatchupListClickListener(this);

    _children = [
      new _WidgetFamily([PlaceholderWidget(Colors.white)]),
      new _WidgetFamily([RankingCoachPage(tournament: _tournament)]),
      new _WidgetFamily([RankingSquadsPage(tournament: _tournament)]),
      new _WidgetFamily([
        SquadMatchupsPage(
          matchups: _matchups,
          coachMatchupListeners: _coachMatchupListener,
        ),
        CoachMatchupsPage(matchups: null)
      ])
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amorical Cup'),
      ),
      body: _children[_parentIndex].widgets[_childIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Rankings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _parentIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
    );
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

      if (wFamily != null && wFamily.widgets.length > _childIndex) {
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
    if (_state != null) {
      _state.updateMatchupList(matchups);
    }
  }
}
