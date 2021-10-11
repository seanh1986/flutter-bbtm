import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/blocs/tournament_selection/tournament_selection.dart';
import 'package:bbnaf/models/tournament_info.dart';
import 'package:bbnaf/screens/home_screen.dart';
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
  late AuthBloc _authBloc;
  late TournamentListsBloc _tournyListBloc;
  late TournamentSelectionBloc _tournySelectBloc;

  // List<Tournament> _tournaments = [];

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _tournyListBloc = BlocProvider.of<TournamentListsBloc>(context);
    _tournySelectBloc = BlocProvider.of<TournamentSelectionBloc>(context);
  }

  @override
  void dispose() {
    _tournyListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        bloc: _authBloc,
        builder: (content, authState) {
          String? nafName;

          if (authState is AuthUserState) {
            nafName = authState.nafName;
          }

          return BlocBuilder<TournamentSelectionBloc, TournamentSelectionState>(
              bloc: _tournySelectBloc,
              builder: (content, state) {
                if (state is SelectedTournamentState) {
                  return HomePage(
                    tournament: state.tournament,
                    nafName: nafName,
                  );
                } else {
                  return _showTournamentList(context);
                }
              });
        });
  }

  Widget _showTournamentList(BuildContext context) {
    return BlocBuilder<TournamentListsBloc, TournamentListState>(
      bloc: _tournyListBloc,
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
            onTap: () => {_tournySelectBloc.add(LoadingTournamentEvent(t))},
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
