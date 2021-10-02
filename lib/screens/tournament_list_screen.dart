import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/models/tournament_info.dart';
import 'package:bbnaf/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class TournamentListPage extends StatefulWidget {
  TournamentListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentListPage();
  }
}

class _TournamentListPage extends State<TournamentListPage> {
  late TournamentListsBloc _bloc;

  // List<Tournament> _tournaments = [];

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<TournamentListsBloc>(context);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentListsBloc, TournamentListState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is TournamentListLoading) {
          return SplashScreen();
        } else if (state is TournamentListLoaded) {
          return Container(
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("background/background_football_field.jpg"),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            child: GroupedListView(
              elements: state.tournaments,
              groupBy: (TournamentInfo t) => _groupBy(t),
              groupSeparatorBuilder: _buildGroupSeparator,
              itemBuilder: (BuildContext context, TournamentInfo t) =>
                  _itemTournament(
                t,
              ),
              order: GroupedListOrder.ASC,
            ),
          );
        } else {
          return Container(
            child: Text("Failed to load!"),
          );
        }
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: AssetImage("background/background_football_field.jpg"),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //     child: GroupedListView(
  //       elements: _tournaments,
  //       groupBy: (Tournament t) => _groupBy(t),
  //       groupSeparatorBuilder: _buildGroupSeparator,
  //       itemBuilder: (BuildContext context, Tournament t) => _itemTournament(
  //         t,
  //       ),
  //       order: GroupedListOrder.ASC,
  //     ),
  //   );
  // }

  String _groupBy(TournamentInfo t) {
    return DateFormat.yMMMEd().format(t.dateTimeStart);
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

  Widget _itemTournament(TournamentInfo t) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            onTap: () => {
                  // // Open Main page
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => HomePage(tournament: t)))
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
