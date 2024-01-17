import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/screens/login/login_screen.dart';
import 'package:bbnaf/screens/login/login_screen_organizer.dart';
import 'package:bbnaf/screens/splash_screen.dart';
import 'package:bbnaf/tournament_selection/view/tournament_creation_page.dart';
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
  Recent_or_Upcoming_Tournaments,
  Past_Tournaments,
  Future_Tournaments,
}

class _TournamentSelectionPage extends State<TournamentSelectionPage> {
  // late AppState appState;

  late FToast fToast;

  String? tournamentId;

  DateType dateType = DateType.Recent_or_Upcoming_Tournaments;

  List<TournamentInfo> _pastTournaments = [];
  List<TournamentInfo> _recentAndUpcomingTournaments = [];
  List<TournamentInfo> _futureTournaments = [];

  @override
  void initState() {
    super.initState();

    tournamentId = widget.tournamentId;

    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);

    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          setState(() {});
        },
        child: _updateUi(context, appState));
  }

  Widget _updateUi(BuildContext context, AppState appState) {
    List<TournamentInfo> tournamentList =
        appState.tournamentState.tournamentList;
    if (tournamentList.isEmpty) {
      return SplashScreen();
    }

    if (tournamentId != null && tournamentId!.isNotEmpty) {
      int tIdx = tournamentList.indexWhere((t) => t.id == tournamentId);

      if (tIdx >= 0) {
        // Verify that input tournamentId is valid
        context.read<AppBloc>().add(AppTournamentRequested(tournamentId!));
        return SplashScreen();
      }
    }

    return _showTournamentList(context, tournamentList);
  }

  /// Once tournament list is loaded, we either forward to the hardcoded
  /// selected tournament, if it can be found, or we launch the tournament list
  // Widget _onTournamentListLoaded(
  //     BuildContext context, TournamentListLoaded listState) {
  //   if (tournamentId != null) {
  //     int tIdx = listState.tournaments.indexWhere((t) => t.id == tournamentId);

  //     if (tIdx >= 0) {
  //       TournamentInfo tournamentInfo = listState.tournaments[tIdx];
  //       _processTournamentSelection(context, tournamentInfo);

  //       return SplashScreen();
  //     }
  //   }

  //   // if (dateType == DateType.Create_Tournament) {
  //   //   return _createNewTournament();
  //   // }

  //   // if (_authState is AuthStateLoggedIn) {
  //   //   if (dateType == DateType.Create_Tournament) {
  //   //     Navigator.push(context,
  //   //         MaterialPageRoute(builder: (context) => _createNewTournament()));
  //   //   } else {
  //   //     Navigator.push(
  //   //         context, MaterialPageRoute(builder: (context) => HomePage()));
  //   //   }
  //   // } else {
  //   //   Navigator.push(
  //   //       context,
  //   //       MaterialPageRoute(
  //   //           builder: (context) => LoginPage(tournyState.tournament.info)));
  //   // }

  //   return _showTournamentList(context, listState.tournaments);
  // }

  /// Once a tournament has been selected
  // Widget _onTournamentSelected(
  //     BuildContext context, TournamentStateLoaded state) {
  //   return Material(child: HomePage());
  //   // if (_authState is AuthStateLoggedIn) {
  //   //   return Material(child: HomePage());
  //   // } else {
  //   //   return Material(child: LoginPage(state.tournament.info));
  //   // }
  // }

  // void _processTournamentSelection(
  //     BuildContext context, TournamentInfo tournamentInfo) {
  //   // BlocProvider.of<TournamentBloc>(context)
  //   //     .add(TournamentEventFetchData(tournamentInfo.id));
  //   // _tournyBloc.add(TournamentEventFetchData(tournamentInfo.id));
  // }

  Widget _showTournamentList(
      BuildContext context, List<TournamentInfo> tournamentList) {
    _updatePastFutureRecentUpcomingTournaments(tournamentList);

    Widget subScreenWidget = _getSubScreen(context);

    return Column(children: <Widget>[
      _toggleButtonsList(context),
      SizedBox(height: 20),
      Expanded(child: subScreenWidget),
    ]);
  }

  Widget _toggleButtonsList(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> toggleWidgets = [];

    DateType.values.forEach((element) {
      toggleWidgets.add(ElevatedButton(
        style: theme.elevatedButtonTheme.style,
        child: Text(element.name.replaceAll("_", " ")),
        onPressed: () {
          setState(() {
            dateType = element;
          });
        },
      ));

      toggleWidgets.add(SizedBox(width: 10));
    });

    // Create tournament
    toggleWidgets.add(SizedBox(width: 10));
    toggleWidgets.add(ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text("Create Tournament"),
      onPressed: () {
        // _processCreateTournament();
      },
    ));

    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: toggleWidgets));
  }

  void _updatePastFutureRecentUpcomingTournaments(
      List<TournamentInfo> tournamentList) {
    DateTime now = DateTime.now();

    _pastTournaments.clear();
    _futureTournaments.clear();
    _recentAndUpcomingTournaments.clear();

    tournamentList.forEach((t) {
      if (t.dateTimeStart.isBefore(now.subtract(Duration(days: 7)))) {
        _pastTournaments.add(t);
      } else if (t.dateTimeStart.isAfter(now.add(Duration(days: 300)))) {
        _futureTournaments.add(t);
      } else {
        _recentAndUpcomingTournaments.add(t);
      }
    });
  }

  Widget _getSubScreen(BuildContext context) {
    switch (dateType) {
      case DateType.Past_Tournaments:
        return _createTournamentListView(context, _pastTournaments);
      case DateType.Future_Tournaments:
        return _createTournamentListView(context, _futureTournaments);
      case DateType.Recent_or_Upcoming_Tournaments:
      default:
        return _createTournamentListView(
            context, _recentAndUpcomingTournaments);
    }
  }

  Widget _createTournamentListView(
      BuildContext context, List<TournamentInfo> tournaments) {
    return Container(
      child: GroupedListView<dynamic, DateTime>(
        elements: tournaments,
        groupBy: (t) => DateFormat("yMMMM")
            .parse(DateFormat.yMMMM().format(t.dateTimeStart)),
        groupSeparatorBuilder: _buildGroupSeparator,
        itemBuilder: (context, t) => _itemTournament(context, t),
        itemComparator: (t1, t2) =>
            t1.dateTimeStart.compareTo(t2.dateTimeStart),
        order: GroupedListOrder.ASC,
        sort: true,
      ),
    );
  }

  Widget _buildGroupSeparator(DateTime dateTime) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat.yMMMM().format(dateTime),
        textAlign: TextAlign.center,
        style: theme.listTileTheme
            .titleTextStyle, // TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _itemTournament(BuildContext context, TournamentInfo t) {
    final theme = Theme.of(context);

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
          onTap: () =>
              {context.read<AppBloc>().add(AppTournamentRequested(t.id))},
          title: Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                child: Column(
                  children: [
                    Text(t.name, style: theme.textTheme.titleLarge),
                    Text(t.location, style: theme.textTheme.titleMedium),
                    Text(dateString, style: theme.textTheme.titleMedium)
                  ],
                ),
              )),
          style: theme.listTileTheme.style,
        ));
  }

  Widget _createNewTournament() {
    // AuthUser? authUser;
    // if (_authState is AuthStateLoggedIn) {
    //   authUser = (_authState as AuthStateLoggedIn).authUser;
    // }

    // if (authUser != null && authUser.user != null) {
    //   return Expanded(child: TournamentCreationPage());
    // } else {
    //   return LoginOrganizerPage();
    // }
    return Expanded(child: TournamentCreationPage());
  }
}
