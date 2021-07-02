import 'package:amorical_cup/data/squad_matchup.dart';
import 'package:amorical_cup/data/tournament.dart';
import 'package:amorical_cup/screens/matchups_screen.dart';
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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Tournament _tournament;

  List<Widget> _children;

  @override
  void initState() {
    _tournament = Tournament.getExampleTournament();
    _children = [
      PlaceholderWidget(Colors.white),
      RankingCoachPage(tournament: _tournament),
      RankingSquadsPage(tournament: _tournament),
      MatchupsPage(
          squadMatchups: SquadMatchup.getExampleSquadMatchups(_tournament))
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amorical Cup'),
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Rankings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
