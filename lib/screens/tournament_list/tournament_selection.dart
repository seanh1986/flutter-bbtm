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

enum DateType {
  Past_Tournaments,
  Recent_or_Upcoming_Tournaments,
  Future_Tournaments,
}

class _TournamentSelectionPage extends State<TournamentSelectionPage> {
  late TournamentListsBloc _tournyListBloc;
  late TournamentBloc _tournyBloc;
  late AuthBloc _authBloc;

  late StreamSubscription _tournyListSub;
  late StreamSubscription _tournySelectSub;
  late StreamSubscription _authSub;

  late TournamentListState _tournyListState;
  late AuthState _authState;

  late FToast fToast;

  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  String? tournamentId;

  DateType dateType = DateType.Recent_or_Upcoming_Tournaments;

  List<TournamentInfo> _pastTournaments = [];
  List<TournamentInfo> _recentAndUpcomingTournaments = [];
  List<TournamentInfo> _futureTournaments = [];

  @override
  void initState() {
    super.initState();

    tournamentId = widget.tournamentId;

    _tournyListBloc = BlocProvider.of<TournamentListsBloc>(context);
    _tournyBloc = BlocProvider.of<TournamentBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);

    fToast = FToast();
    fToast.init(context);
  }

  void _refreshState() {
    _tournyListState = _tournyListBloc.state;
    _authState = _authBloc.state;

    _tournyListSub = _tournyListBloc.stream.listen((tournyListState) {
      setState(() {
        _tournyListState = tournyListState;
      });
    });

    _tournySelectSub = _tournyBloc.stream.listen((tournyState) {
      if (tournyState is NewTournamentState) {
        if (_authState is AuthStateLoggedIn) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginPage(tournyState.tournament.info)));
        }
      }
    });

    _authSub = _authBloc.stream.listen((authState) {
      setState(() {
        _authState = authState;
      });
    });
  }

  @override
  void dispose() {
    _tournyListBloc.close();
    _tournyBloc.close();
    _authBloc.close();

    _tournyListSub.cancel();
    _tournySelectSub.cancel();
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _refreshState();

    if (_tournyListState is TournamentListLoading) {
      // While loading, show splash
      return SplashScreen();
    } else if (_tournyListState is TournamentListLoaded) {
      return _onTournamentListLoaded(
          context, _tournyListState as TournamentListLoaded);
    } else {
      // If we failed to load tournament list, show error
      return Container(
        child: Text("Failed to load!"),
      );
    }
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

  Widget _showTournamentList(BuildContext context, TournamentListLoaded state) {
    return _generateView(state);
  }

  Widget _generateView(TournamentListLoaded state) {
    _updatePastFutureRecentUpcomingTournaments(state);

    Widget subScreenWidget = _getSubScreen();

    return Column(children: <Widget>[
      _toggleButtonsList(context),
      SizedBox(height: 20),
      Expanded(child: subScreenWidget),
    ]);
  }

  Widget _toggleButtonsList(BuildContext context) {
    List<Widget> toggleWidgets = [];

    DateType.values.forEach((element) {
      toggleWidgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(color: Colors.white),
        ),
        child: Text(element.name.replaceAll("_", " ")),
        onPressed: () {
          setState(() {
            dateType = element;
          });
        },
      ));

      toggleWidgets.add(SizedBox(width: 10));
    });

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: toggleWidgets));
  }

  void _updatePastFutureRecentUpcomingTournaments(TournamentListLoaded state) {
    DateTime now = DateTime.now();

    _pastTournaments.clear();
    _futureTournaments.clear();
    _recentAndUpcomingTournaments.clear();

    state.tournaments.forEach((t) {
      if (t.dateTimeStart.isBefore(now.subtract(Duration(days: 7)))) {
        _pastTournaments.add(t);
      } else if (t.dateTimeStart.isAfter(now.add(Duration(days: 300)))) {
        _futureTournaments.add(t);
      } else {
        _recentAndUpcomingTournaments.add(t);
      }
    });
  }

  Widget _getSubScreen() {
    switch (dateType) {
      case DateType.Past_Tournaments:
        return _createTournamentListView(_pastTournaments);
      case DateType.Future_Tournaments:
        return _createTournamentListView(_futureTournaments);
      case DateType.Recent_or_Upcoming_Tournaments:
      default:
        return _createTournamentListView(_recentAndUpcomingTournaments);
    }
  }

  Widget _createTournamentListView(List<TournamentInfo> tournaments) {
    return Container(
      child: GroupedListView<dynamic, DateTime>(
        elements: tournaments,
        groupBy: (t) => DateFormat("yMMMM")
            .parse(DateFormat.yMMMM().format(t.dateTimeStart)),
        groupSeparatorBuilder: _buildGroupSeparator,
        itemBuilder: (context, t) => _itemTournament(t),
        itemComparator: (t1, t2) =>
            t1.dateTimeStart.compareTo(t2.dateTimeStart),
        order: GroupedListOrder.ASC,
        sort: true,
      ),
    );
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
