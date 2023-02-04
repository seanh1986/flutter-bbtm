import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/screens/home_screen.dart';
import 'package:bbnaf/screens/login/login_screen.dart';
import 'package:bbnaf/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class TournamentSelectionPage extends StatefulWidget {
  String? tournamentId;

  TournamentSelectionPage({Key? key, this.tournamentId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentSelectionPage();
  }
}

class _TournamentSelectionPage extends State<TournamentSelectionPage> {
  late AuthBloc _authBloc;
  late TournamentListsBloc _tournyListBloc;
  late TournamentBloc _tournySelectBloc;

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _tournyListBloc = BlocProvider.of<TournamentListsBloc>(context);
    _tournySelectBloc = BlocProvider.of<TournamentBloc>(context);
  }

  @override
  void dispose() {
    _tournyListBloc.close();
    _tournySelectBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Outermost Bloc is loading tournament list
    return BlocBuilder<TournamentListsBloc, TournamentListState>(
      bloc: _tournyListBloc,
      builder: (listContext, listState) {
        // Inner Bloc is selecting tournament
        return BlocBuilder<TournamentBloc, TournamentState>(
            bloc: _tournySelectBloc,
            builder: (selectContext, selectState) {
              if (listState is TournamentListLoading) {
                // While loading, show splash
                return SplashScreen();
              } else if (listState is TournamentListLoaded) {
                // Tournament list loaded, show UI depending on use case
                if (selectState is NewTournamentState) {
                  return _onSelectedTournament(context, selectState);
                } else {
                  return _onTournamentListLoaded(context, listState);
                }
              } else {
                // If we failed to load tournament list, show error
                return Container(
                  child: Text("Failed to load!"),
                );
              }
            });
      },
    );
  }

  /// Once tournament list is loaded, we either forward to the hardcoded
  /// selected tournament, if it can be found, or we launch the tournament list
  Widget _onTournamentListLoaded(
      BuildContext context, TournamentListLoaded listState) {
    if (widget.tournamentId != null) {
      int tIdx =
          listState.tournaments.indexWhere((t) => t.id == widget.tournamentId);

      if (tIdx >= 0) {
        TournamentInfo tournamentInfo = listState.tournaments[tIdx];
        _processTournamentSelection(tournamentInfo);

        return SplashScreen(); // _onTournamentSelected(context, tournamentInfo);
      }
    }

    return _showTournamentList(context, listState);
  }

  void _processTournamentSelection(TournamentInfo tournamentInfo) {
    _tournySelectBloc.add(LoadTournamentEvent(tournamentInfo));
  }

  // /// Once a tournament has been selected
  // Widget _onTournamentSelected(
  //     BuildContext context, TournamentInfo tournamentInfo) {
  //   LoadingTournamentEvent loadingTournamentEvent =
  //       new LoadingTournamentEvent(tournamentInfo);

  //   _tournySelectBloc.add(loadingTournamentEvent);

  //   return BlocBuilder<TournamentSelectionBloc, TournamentSelectionState>(
  //       bloc: _tournySelectBloc,
  //       builder: (content, state) {
  //         if (state is SelectedTournamentState) {
  //           return _onSelectedTournament(context, state);
  //         } else {
  //           return SplashScreen();
  //         }

  //         // if (state is SelectedTournamentState) {
  //         //   return HomePage(
  //         //     tournament: state.tournament,
  //         //     authUser: _authUser,
  //         //   );
  //         // } else {
  //         //   return _showTournamentList(context);
  //         // }
  //       });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return BlocBuilder<TournamentSelectionBloc, TournamentSelectionState>(
  //       bloc: _tournySelectBloc,
  //       builder: (content, state) {
  //         if (state is SelectedTournamentState) {
  //           return _selectedTournament(context, state);
  //         } else {
  //           return _showTournamentList(context);
  //         }

  //         // if (state is SelectedTournamentState) {
  //         //   return HomePage(
  //         //     tournament: state.tournament,
  //         //     authUser: _authUser,
  //         //   );
  //         // } else {
  //         //   return _showTournamentList(context);
  //         // }
  //       });
  // }

  /// When a tournment has been selected
  Widget _onSelectedTournament(BuildContext context, NewTournamentState state) {
    return BlocListener<AuthBloc, AuthState>(
      listener: ((context, authState) => {
            if (authState is LoggedInAuthState)
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              tournament: state.tournament,
                              authUser: authState.authUser,
                            )))
              }
          }),
      child: LoginPage(state.tournament.info),
    );

    // return BlocBuilder<AuthBloc, AuthState>(
    //     bloc: _authBloc,
    //     builder: (content, authState) {
    //       if (authState is LoggedInAuthState) {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => HomePage(
    //                       tournament: tournamentState.tournament,
    //                       authUser: authState.authUser,
    //                     )));
    //       }

    // if (authState is OrganizerAuthState ||
    //     authState is CaptainAuthState ||
    //     authState is ParticipantAuthState ||
    //     authState is GuestAuthState) {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => HomePage(
    //                 tournament: tournamentState.tournament,
    //                 authUser: _authUser,
    //               )));
    // }

    // return LoginPage();

    // if (state is SelectedTournamentState) {
    //   return HomePage(
    //     tournament: state.tournament,
    //     authUser: _authUser,
    //   );
    // } else {
    //   return _showTournamentList(context);
    // }
    // });
  }

  Widget _showTournamentList(BuildContext context, TournamentListLoaded state) {
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
                  _processTournamentSelection(t)
                  // _onTournamentSelected(context, t)
                  // _tournySelectBloc.add(LoadingTournamentEvent(t))
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
