import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/home_screen.dart';
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
  Past_Tournaments,
  Recent_or_Upcoming_Tournaments,
  Future_Tournaments,
  // Create_Tournament,
}

class _TournamentSelectionPage extends State<TournamentSelectionPage> {
  User? _user;
  List<TournamentInfo>? _tournamentList;

  // late TournamentListsBloc _tournyListBloc;
  // late TournamentBloc _tournyBloc;
  // late AuthBloc _authBloc;

  // late StreamSubscription _tournyListSub;
  // late StreamSubscription _tournySelectSub;
  // late StreamSubscription _authSub;

  // late TournamentListState _tournyListState;

  // late TournamentListState _tournyListState;
  // late TournamentState _tournyState;
  // late AuthState _authState;

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

    // _tournyListState = TournamentListLoading();
    // _tournyState = TournamentStateUninitialized();
    // _authState = AuthStateUninitializd();

    // _tournyListState = BlocProvider.of<TournamentListsBloc>(context).state;
    // _tournyState = BlocProvider.of<TournamentBloc>(context).state;
    // _authState = BlocProvider.of<AuthBloc>(context).state;

    // _tournyListBloc = BlocProvider.of<TournamentListsBloc>(context);
    // _tournyBloc = BlocProvider.of<TournamentBloc>(context);
    // _authBloc = BlocProvider.of<AuthBloc>(context);

    fToast = FToast();
    fToast.init(context);
  }

  void _refreshState() {
    // _tournyListState = _tournyListBloc.state;
    // _authState = _authBloc.state;

    // _tournyListSub = _tournyListBloc.stream.listen((tournyListState) {
    //   setState(() {
    //     _tournyListState = tournyListState;
    //   });
    // });

    // _tournySelectSub = _tournyBloc.stream.listen((tournyState) {
    //   if (tournyState is TournamentStateLoaded) {
    //     if (_authState is AuthStateLoggedIn) {
    //       if (dateType == DateType.Create_Tournament) {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => _createNewTournament()));
    //       } else {
    //         Navigator.push(
    //             context, MaterialPageRoute(builder: (context) => HomePage()));
    //       }
    //     } else {
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) =>
    //                   LoginPage(tournyState.tournament.info)));
    //     }
    //   }
    // });

    // _authSub = _authBloc.stream.listen((authState) {
    //   setState(() {
    //     _authState = authState;
    //   });
    // });
  }

  @override
  void dispose() {
    // _tournyListBloc.close();
    // _tournyBloc.close();
    // _authBloc.close();

    // _tournyListSub.cancel();
    // _tournySelectSub.cancel();
    // _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _refreshState();

    if (_user == null) {
      _user =
          context.select((AppBloc bloc) => bloc.state.authenticationState.user);
    }
    if (_tournamentList == null) {
      _tournamentList = context
          .select((AppBloc bloc) => bloc.state.tournamentState.tournamentList);
    }

    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          setState(() {
            _user = state.authenticationState.user;
            _tournamentList = state.tournamentState.tournamentList;
          });
        },
        child: _updateUi(context, _tournamentList!));

    // user = context.select((AppBloc bloc) => bloc.state.user);

    // List<TournamentInfo> tournamentList =
    //     context.select((AppBloc bloc) => bloc.state.tournamentList);
    // if (tournamentList.isEmpty) {
    //   context.read<AppBloc>().add(AppTournamentListRequested(user));
    //   return SplashScreen();
    // }

    // return _showTournamentList(context, tournamentList);

    // return _updateUi(context);

    // return MultiBlocListener(
    //   listeners: [
    //     BlocListener<TournamentListsBloc, TournamentListState>(
    //       listener: (context, state) {
    //         setState(() {
    //           _tournyListState = state;
    //         });
    //       },
    //     ),
    //     BlocListener<TournamentBloc, TournamentState>(
    //       listener: (context, state) {
    //         setState(() {
    //           _tournyState = state;
    //         });
    //       },
    //     ),
    //     BlocListener<AuthBloc, AuthState>(
    //       listener: (context, state) {
    //         setState(() {
    //           _authState = state;
    //         });
    //       },
    //     ),
    //   ],
    //   child: _updateUi(context),
    // );

    // return BlocBuilder<TournamentListsBloc, TournamentListState>(
    //     builder: (context, state) {
    //   if (state is TournamentListLoading) {
    //     // While loading, show splash
    //     return SplashScreen();
    //   } else if (state is TournamentListLoaded) {
    //     return _onTournamentListLoaded(context, state);
    //   } else {
    //     // If we failed to load tournament list, show error
    //     return Container(
    //       child: Text("Failed to load!"),
    //     );
    //   }
    // });
  }

  Widget _updateUi(BuildContext context, List<TournamentInfo> tournamentList) {
    if (tournamentList.isEmpty) {
      // context.read<AppBloc>().add(AppTournamentListRequested(_user!));
      return SplashScreen();
    }

    return _showTournamentList(context, tournamentList);

    // // While loading, show splash
    // if (_tournyListState is TournamentListNotLoaded) {
    //   return SplashScreen();
    // } else if (_tournyListState is TournamentListLoading) {
    //   return SplashScreen();
    // } else if (_tournyListState is TournamentListLoaded) {
    //   if (_tournyState is TournamentStateLoaded) {
    //     // If tournament state is loaded --> Open it
    //     return _onTournamentSelected(
    //         context, _tournyState as TournamentStateLoaded);
    //   } else {
    //     // Otherwise, go to tournament list
    //     return _onTournamentListLoaded(
    //         context, _tournyListState as TournamentListLoaded);
    //   }
    // } else {
    //   // If we failed to load tournament list, show error
    //   return Container(
    //     child: Text("Failed to load!"),
    //   );
    // }

    //   // Tournament Loaded
    //   if (_tournyState is TournamentStateLoaded) {
    //     Tournament t = (_tournyState as TournamentStateLoaded).tournament;
    //     _processTournamentSelection(context, t.info);
    //   }

    //   if (_authState is AuthStateLoggedIn) {
    //         if (dateType == DateType.Create_Tournament) {
    //           Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => _createNewTournament()));
    //         } else {
    //           Navigator.push(
    //               context, MaterialPageRoute(builder: (context) => HomePage()));
    //         }
    //       } else {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) =>
    //                     LoginPage(tournyState.tournament.info)));
    //       }
    // }

    //    else if (_tournyState is TournamentListLoaded) {
    //     return _onTournamentListLoaded(
    //         context, _tournyState as TournamentListLoaded);
    //   } else {
    //     // If we failed to load tournament list, show error
    //     return Container(
    //       child: Text("Failed to load!"),
    //     );
    //   }
  }

  /// Once tournament list is loaded, we either forward to the hardcoded
  /// selected tournament, if it can be found, or we launch the tournament list
  Widget _onTournamentListLoaded(
      BuildContext context, TournamentListLoaded listState) {
    if (tournamentId != null) {
      int tIdx = listState.tournaments.indexWhere((t) => t.id == tournamentId);

      if (tIdx >= 0) {
        TournamentInfo tournamentInfo = listState.tournaments[tIdx];
        _processTournamentSelection(context, tournamentInfo);

        return SplashScreen();
      }
    }

    // if (dateType == DateType.Create_Tournament) {
    //   return _createNewTournament();
    // }

    // if (_authState is AuthStateLoggedIn) {
    //   if (dateType == DateType.Create_Tournament) {
    //     Navigator.push(context,
    //         MaterialPageRoute(builder: (context) => _createNewTournament()));
    //   } else {
    //     Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => HomePage()));
    //   }
    // } else {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => LoginPage(tournyState.tournament.info)));
    // }

    return _showTournamentList(context, listState.tournaments);
  }

  /// Once a tournament has been selected
  Widget _onTournamentSelected(
      BuildContext context, TournamentStateLoaded state) {
    return Material(child: HomePage());
    // if (_authState is AuthStateLoggedIn) {
    //   return Material(child: HomePage());
    // } else {
    //   return Material(child: LoginPage(state.tournament.info));
    // }
  }

  void _processTournamentSelection(
      BuildContext context, TournamentInfo tournamentInfo) {
    // BlocProvider.of<TournamentBloc>(context)
    //     .add(TournamentEventFetchData(tournamentInfo.id));
    // _tournyBloc.add(TournamentEventFetchData(tournamentInfo.id));
  }

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

    // // Create tournament
    // toggleWidgets.add(SizedBox(width: 10));
    // toggleWidgets.add(ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: Theme.of(context).primaryColor,
    //     textStyle: TextStyle(color: Colors.white),
    //   ),
    //   child: Text("Create Tournament"),
    //   onPressed: () {
    //     _processCreateTournament();
    //   },
    // ));

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
      // case DateType.Create_Tournament:
      //   return _createNewTournament();
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
        style: theme.textTheme
            .titleSmall, // TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            onTap: () => {_processTournamentSelection(context, t)},
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Column(
                    children: [
                      Text(t.name, style: theme.textTheme.titleMedium),
                      Text(t.location, style: theme.textTheme.titleSmall),
                      Text(dateString, style: theme.textTheme.titleSmall)
                    ],
                  ),
                ))));
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
