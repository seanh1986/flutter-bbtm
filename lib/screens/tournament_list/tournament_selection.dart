import 'dart:async';
import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/screens/home_screen.dart';
import 'package:bbnaf/screens/login/login_screen.dart';
import 'package:bbnaf/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class TournamentSelectionPage extends StatefulWidget {
  final String? tournamentId;

  TournamentSelectionPage({Key? key, this.tournamentId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentSelectionPage();
  }
}

class _TournamentSelectionPage extends State<TournamentSelectionPage> {
  late TournamentListsBloc _tournyListBloc;
  late TournamentBloc _tournyBloc;

  // late StreamSubscription _tournyListSub;
  // late StreamSubscription _tournySub;

  // late TournamentListState _listState;
  late TournamentState _selectState;

  late FToast fToast;

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  String? tournamentId;

  @override
  void initState() {
    super.initState();

    tournamentId = widget.tournamentId;

    _tournyListBloc = BlocProvider.of<TournamentListsBloc>(context);
    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    // _tournySub = _tournyBloc.stream.listen((tournyState) {
    //   setState(() {
    //     _selectState = tournyState;
    //   });
    // });

    // _tournyListSub = _tournyListBloc.stream.listen((tournyListState) {
    //   setState(() {
    //     _listState = tournyListState;
    //   });
    // });

    // _listState = _tournyListBloc.state;
    _selectState = _tournyBloc.state;

    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    _tournyListBloc.close();
    _tournyBloc.close();

    // _tournySub.cancel();
    // _tournyListSub.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initTournamentStateListener();

    return BlocBuilder<TournamentListsBloc, TournamentListState>(
      bloc: _tournyListBloc,
      builder: (listContext, listState) {
        if (listState is TournamentListLoading) {
          // While loading, show splash
          return SplashScreen();
        } else if (listState is TournamentListLoaded) {
          // Tournament list loaded, show UI depending on use case
          if (_selectState is NewTournamentState) {
            return _onSelectedTournament(
                context, _selectState as NewTournamentState);
          } else {
            return _onTournamentListLoaded(context, listState);
          }
        } else {
          // If we failed to load tournament list, show error
          return Container(
            child: Text("Failed to load!"),
          );
        }
      },
    );

    // // Outermost Bloc is loading tournament list
    // return BlocBuilder<TournamentListsBloc, TournamentListState>(
    //   bloc: _tournyListBloc,
    //   builder: (listContext, listState) {
    //     // Inner Bloc is selecting tournament
    //     return BlocBuilder<TournamentBloc, TournamentState>(
    //         bloc: _tournySelectBloc,
    //         builder: (selectContext, selectState) {
    //           if (listState is TournamentListLoading) {
    //             // While loading, show splash
    //             return SplashScreen();
    //           } else if (listState is TournamentListLoaded) {
    //             // Tournament list loaded, show UI depending on use case
    //             if (selectState is NewTournamentState) {
    //               return _onSelectedTournament(context, selectState);
    //             } else {
    //               return _onTournamentListLoaded(context, listState);
    //             }
    //           } else {
    //             // If we failed to load tournament list, show error
    //             return Container(
    //               child: Text("Failed to load!"),
    //             );
    //           }
    //         });
    //   },
    // );
  }

  void _initTournamentStateListener() {
    BlocListener<TournamentBloc, TournamentState>(
        listener: ((context, tournyState) => {
              if (tournyState is NewTournamentState)
                {
                  setState(() {
                    _selectState = tournyState;
                  })
                }
            }));
  }

  /// Once tournament list is loaded, we either forward to the hardcoded
  /// selected tournament, if it can be found, or we launch the tournament list
  Widget _onTournamentListLoaded(
      BuildContext context, TournamentListLoaded listState) {
    if (tournamentId != null) {
      int tIdx = listState.tournaments.indexWhere((t) => t.id == tournamentId);

      if (tIdx >= 0) {
        TournamentInfo tournamentInfo = listState.tournaments[tIdx];
        _processTournamentSelection(tournamentInfo);

        return SplashScreen();
      }
    }

    return _showTournamentList(context, listState);
  }

  void _processTournamentSelection(TournamentInfo tournamentInfo) {
    _tournyBloc.add(LoadTournamentEvent(tournamentInfo));
  }

  /// When a tournment has been selected
  Widget _onSelectedTournament(BuildContext context, NewTournamentState state) {
    return BlocListener<AuthBloc, AuthState>(
        listener: ((context, authState) => {
              if (authState is LoggedInAuthState)
                {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()))
                }
            }),
        child: LoginPage(state.tournament.info));
  }

  Widget _showTournamentList(BuildContext context, TournamentListLoaded state) {
    return BlocListener<TournamentBloc, TournamentState>(
        listener: ((context, tournyState) => {
              if (tournyState is NewTournamentState)
                {
                  setState(() {
                    _selectState = tournyState;
                  })
                }
            }),
        child: Container(
          child: GroupedListView<dynamic, DateTime>(
            elements: state.tournaments,
            groupBy: (t) => DateFormat("yMMMM")
                .parse(DateFormat.yMMMM().format(t.dateTimeStart)),
            groupSeparatorBuilder: _buildGroupSeparator,
            itemBuilder: (context, t) => _itemTournament(t),
            itemComparator: (t1, t2) =>
                t1.dateTimeStart.compareTo(t2.dateTimeStart),
            order: GroupedListOrder.ASC,
            sort: true,
          ),
        ));

    // return Container(
    //   child: GroupedListView<dynamic, DateTime>(
    //     elements: state.tournaments,
    //     groupBy: (t) => DateFormat("yMMMM")
    //         .parse(DateFormat.yMMMM().format(t.dateTimeStart)),
    //     groupSeparatorBuilder: _buildGroupSeparator,
    //     itemBuilder: (context, t) => _itemTournament(t),
    //     itemComparator: (t1, t2) =>
    //         t1.dateTimeStart.compareTo(t2.dateTimeStart),
    //     order: GroupedListOrder.ASC,
    //     sort: true,
    //   ),
    // );
  }

  Widget _buildGroupSeparator(DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat.yMMMM().format(dateTime),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _itemTournament(TournamentInfo t) {
    String startDate = DateFormat.MMMMd().format(t.dateTimeStart);
    String endDate = DateFormat.MMMMd().format(t.dateTimeEnd);

    StringBuffer sb = new StringBuffer(startDate);
    if (startDate != endDate) {
      sb.write(" - ");
      sb.write(endDate);
    }

    String dateString = sb.toString();

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            onTap: () => {_processTournamentSelection(t)},
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Column(
                    children: [
                      Text(t.name, style: TextStyle(fontSize: titleFontSize)),
                      Text(t.location,
                          style: TextStyle(fontSize: subTitleFontSize)),
                      Text(dateString,
                          style: TextStyle(fontSize: subTitleFontSize))
                    ],
                  ),
                ))));
  }
}
