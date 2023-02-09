import 'dart:async';
import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/admin_screen.dart';
import 'package:bbnaf/screens/overview_screen.dart';
import 'package:bbnaf/screens/rankings_screen.dart';
import 'package:bbnaf/screens/tournament_list/tournament_selection.dart';
import 'package:bbnaf/utils/item_click_listener.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'matchups/matchups_coaches_screen.dart';
import 'matchups/matchups_squad_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _WidgetFamily {
  List<Widget> widgets;
  _WidgetFamily(this.widgets);
}

class _HomePageState extends State<HomePage> {
  int _parentIndex = 0;
  int _childIndex = 0;

  _CoachMatchupListClickListener? _coachMatchupListener;

  late TournamentBloc _tournyBloc;
  late AuthBloc _authBloc;

  late StreamSubscription _tournySub;
  late StreamSubscription _authSub;

  late FToast fToast;

  Tournament _tournament = Tournament.empty();
  AuthUser _authUser = AuthUser();

  List<SquadMatchup> _squadMatchups = [];

  List<_WidgetFamily> _children = [];

  @override
  void initState() {
    super.initState();

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);

    _tournySub = _tournyBloc.stream.listen((tournyState) {
      if (tournyState is NewTournamentState) {
        ToastUtils.showSuccess(fToast, "Tournament Data Loaded");
        setState(() {
          _tournament = tournyState.tournament;
        });
      } else {
        setState(() {
          _tournament = Tournament.empty();
        });
      }
    });

    _authSub = _authBloc.stream.listen((authState) {
      if (authState is LoggedInAuthState) {
        setState(() {
          _authUser = authState.authUser;
        });
      } else {
        ToastUtils.showSuccess(fToast, "Logged Out");
        setState(() {
          _authUser = AuthUser();
        });
      }
    });

    if (_tournyBloc.state is NewTournamentState) {
      _tournament = (_tournyBloc.state as NewTournamentState).tournament;
    } else {
      _tournament = Tournament.empty();
    }

    if (_authBloc.state is LoggedInAuthState) {
      _authUser = (_authBloc.state as LoggedInAuthState).authUser;
    } else {
      _authUser = AuthUser();
    }
  }

  @override
  void dispose() {
    _tournyBloc.close();
    _authBloc.close();

    _tournySub.cancel();
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fToast = FToast();
    fToast.init(context);

    bool shouldLogout = _tournyBloc.state is NoTournamentState &&
        _authBloc.state is NotLoggedInAuthState;

    if (shouldLogout) {
      // Try to go back
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TournamentSelectionPage()));
      });
    }

    return _generateUi();

    // return BlocBuilder<TournamentBloc, TournamentState>(
    //     bloc: _tournyBloc,
    //     builder: (tournyContext, tournyState) {
    //       return BlocBuilder<AuthBloc, AuthState>(
    //           bloc: _authBloc,
    //           builder: (authContext, authState) {
    //             bool shouldLogout = tournyState is NoTournamentState ||
    //                 authState is NotLoggedInAuthState;

    //             if (shouldLogout) {
    //               // Try to go back
    //               SchedulerBinding.instance.addPostFrameCallback((_) {
    //                 Navigator.pushReplacement(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (context) => TournamentSelectionPage()));
    //               });
    //             }

    //             if (authState is LoggedInAuthState) {
    //               _authUser = authState.authUser;
    //             } else {
    //               _authUser = AuthUser();
    //             }

    //             if (tournyState is NewTournamentState) {
    //               _tournament = tournyState.tournament;

    //               // SchedulerBinding.instance.addPostFrameCallback((_) {
    //               //   ToastUtils.showSuccess(fToast, "Tournament Data Loaded");
    //               // });
    //             }

    //             return _generateUi();
    //           });
    //     });
  }

  void _handleLogoutPressed() {
    print("Logout Pressed");
    ToastUtils.show(fToast, "Logging out");
    _authBloc.add(LoggedOutAuthEvent());
    _tournyBloc.add(NoTournamentEvent());
  }

  void _handleRefreshTournamentPressed() {
    print("Refresh Tournament Pressed");
    ToastUtils.show(fToast, "Refreshing Tournament Data");
    _tournyBloc.add(LoadTournamentEvent(_tournament.info));
  }

  Widget _generateUi() {
    _init();

    return WillPopScope(
        onWillPop: () async {
          _handleBackButton();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.white),
            //   onPressed: () => Navigator.of(context).pop(),
            // ),
            title: Text(_tournament.info.name),
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => _handleRefreshTournamentPressed()),
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => _handleLogoutPressed())
            ],
          ),
          body: _children[_parentIndex].widgets[_childIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _getBottomNavigationBarItems(),
            currentIndex: _parentIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            onTap: _onItemTapped,
          ),
        ));
  }

  void _init() {
    if (_tournament.squadRounds.isNotEmpty) {
      _squadMatchups = _tournament.squadRounds.last.matches;
    }

    _coachMatchupListener = new _CoachMatchupListClickListener(this);

    List<Widget> matchupWidgets = [];
    if (_tournament.useSquads) {
      matchupWidgets.add(SquadMatchupsPage(
        tournament: _tournament,
        matchups: _squadMatchups,
        coachMatchupListeners: _coachMatchupListener,
      ));
    }
    matchupWidgets.add(CoachMatchupsPage(
      tournament: _tournament,
      authUser: _authUser,
    ));

    _children = [
      new _WidgetFamily([
        OverviewScreen(
          tournament: _tournament,
          authUser: _authUser,
        )
      ]),
      new _WidgetFamily(matchupWidgets),
      new _WidgetFamily(
          [RankingsPage(tournament: _tournament, authUser: _authUser)]),
      new _WidgetFamily([
        AdminScreen(
          tournament: _tournament,
          authUser: _authUser,
        )
      ]),
    ];
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.sports_football), label: 'Matches'),
      BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Rankings'),
    ];

    if (_tournament.isUserAdmin(_authUser)) {
      items.add(
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Admin'));
    }

    return items;
  }

  void _handleBackButton() {
    if (_childIndex == 0) {
      if (_parentIndex == 0) {
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => TournamentSelectionPage()));
        // });
      } else {
        setState(() {
          _parentIndex = 0;
        });
      }
    } else {
      setState(() {
        _childIndex = 0;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _parentIndex = index;
      _childIndex = 0;
    });
  }

  void updateMatchupList(List<CoachMatchup> coachMatchups) {
    setState(() {
      _parentIndex = 1;
      _childIndex = 1;

      _WidgetFamily wFamily = _children[_parentIndex];

      if (wFamily.widgets.length > _childIndex) {
        Widget w = new CoachMatchupsPage(
          tournament: _tournament,
          authUser: _authUser,
        );
        wFamily.widgets[_childIndex] = w;
      }
    });
  }
}

class _CoachMatchupListClickListener implements CoachMatchupListClickListener {
  final _HomePageState _state;

  _CoachMatchupListClickListener(this._state);

  @override
  void onItemClicked(List<CoachMatchup> matchups) {
    _state.updateMatchupList(matchups);
  }
}
