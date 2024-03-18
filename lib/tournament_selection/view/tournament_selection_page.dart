import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class TournamentSelectionPage extends StatefulWidget {
  final String? tournamentId;

  static const String tag = "TournamentSelectionPage";

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
  Create_Tournament,
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

  Widget _showTournamentList(
      BuildContext context, List<TournamentInfo> tournamentList) {
    _updatePastFutureRecentUpcomingTournaments(tournamentList);

    Widget subScreenWidget = _getSubScreen(context);

    return Column(children: <Widget>[
      SizedBox(height: 20),
      _toggleButtonsList(context),
      SizedBox(height: 20),
      Expanded(child: subScreenWidget),
    ]);
  }

  Widget _toggleButtonsList(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> toggleWidgets = [
      IconButton(
        color: theme.appBarTheme.iconTheme!.color,
        onPressed: () {
          context.read<AppBloc>().add(AppLogoutRequested());
        },
        icon: Icon(Icons.arrow_back_rounded),
      ),
      SizedBox(width: 20),
    ];

    DateType.values.forEach((element) {
      bool clickable = dateType != element;

      toggleWidgets.add(ElevatedButton(
        style: theme.elevatedButtonTheme.style,
        child: Text(element.name.replaceAll("_", " ")),
        onPressed: clickable
            ? () {
                if (element == DateType.Create_Tournament) {
                  context.read<AppBloc>().add(AppCreateTournament());
                } else {
                  setState(() {
                    dateType = element;
                  });
                }
              }
            : null,
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
        return _createTournamentListView(context, _pastTournaments, false);
      case DateType.Future_Tournaments:
        return _createTournamentListView(context, _futureTournaments, true);
      case DateType.Recent_or_Upcoming_Tournaments:
      default:
        return _createTournamentListView(
            context, _recentAndUpcomingTournaments, true);
    }
  }

  Widget _createTournamentListView(
      BuildContext context, List<TournamentInfo> tournaments, bool ascending) {
    return Container(
      child: GroupedListView<dynamic, DateTime>(
        elements: tournaments,
        groupBy: (t) => DateFormat("yMMMM")
            .parse(DateFormat.yMMMM().format(t.dateTimeStart)),
        groupSeparatorBuilder: _buildGroupSeparator,
        itemBuilder: (context, t) => _itemTournament(context, t),
        itemComparator: (t1, t2) =>
            t1.dateTimeStart.compareTo(t2.dateTimeStart),
        order: ascending ? GroupedListOrder.ASC : GroupedListOrder.DESC,
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

  // Widget _createNewTournament() {
  //   // AuthUser? authUser;
  //   // if (_authState is AuthStateLoggedIn) {
  //   //   authUser = (_authState as AuthStateLoggedIn).authUser;
  //   // }

  //   // if (authUser != null && authUser.user != null) {
  //   //   return Expanded(child: TournamentCreationPage());
  //   // } else {
  //   //   return LoginOrganizerPage();
  //   // }
  //   return Expanded(child: TournamentCreationPage());
  // }
}
