import 'package:amorical_cup/data/coach_matchup.dart';
import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/data/squad_matchup.dart';
import 'package:amorical_cup/data/tournament.dart';
import 'package:amorical_cup/screens/home_screen.dart';
import 'package:amorical_cup/services/TournamentRepository.dart';
import 'package:amorical_cup/widgets/matchup_coach_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:amorical_cup/utils/item_click_listener.dart';

class TournamentListPage extends StatefulWidget {
  TournamentListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentListPage();
  }
}

class _TournamentListPage extends State<TournamentListPage> {
  List<Tournament> _tournaments = [];

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    TournamentRepository.instance.getTournamentList().then((tournaments) {
      setState(() {
        _tournaments = tournaments;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _tournaments,
      groupBy: (Tournament t) => _groupBy(t),
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: (BuildContext context, Tournament t) => _itemTournament(
        t,
      ),
      order: GroupedListOrder.ASC,
    );
  }

  String _groupBy(Tournament t) {
    return t.dateTime;
  }

  Widget _buildGroupSeparator(String dateTime) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        dateTime,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _itemTournament(Tournament t) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            onTap: () => {
                  // Open Main page
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(tournament: t)))
                },
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Column(
                    children: [
                      Text(t.name, style: TextStyle(fontSize: titleFontSize)),
                      Text(t.location,
                          style: TextStyle(fontSize: subTitleFontSize)),
                    ],
                  ),
                ))));
  }
}
