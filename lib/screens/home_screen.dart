import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/auth/auth_bloc.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/matchup/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/admin_screen.dart';
import 'package:bbnaf/screens/overview_screen.dart';
import 'package:bbnaf/screens/rankings_screen.dart';
import 'package:bbnaf/screens/tournament_list/tournament_selection.dart';
import 'package:bbnaf/utils/item_click_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'matchups/matchups_coaches_screen.dart';
import 'matchups/matchups_squad_screen.dart';

class HomePage extends StatefulWidget {
  // final Tournament tournament;
  // final AuthUser authUser;

  // HomePage({Key? key, required this.tournament, required this.authUser})
  //     : super(key: key);
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

  late TournamentBloc _tournySelectBloc;
  late AuthBloc _authBloc;

  Tournament _tournament = Tournament.fromJson(
      TournamentInfo.fromJson("0", Map<String, dynamic>()),
      Map<String, dynamic>());
  AuthUser _authUser = AuthUser();

  // late Coach? _curCoach;
  // late Squad? _curSquad;

  List<SquadMatchup> _squadMatchups = [];

  List<_WidgetFamily> _children = [];

  @override
  void initState() {
    _tournySelectBloc = BlocProvider.of<TournamentBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _tournySelectBloc.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
        bloc: _tournySelectBloc,
        builder: (tournyContext, tournyState) {
          return BlocBuilder<AuthBloc, AuthState>(
              bloc: _authBloc,
              builder: (authContext, authState) {
                if (authState is LoggedInAuthState) {
                  _authUser = authState.authUser;
                } else {
                  _authUser = AuthUser();
                }

                if (tournyState is NewTournamentState) {
                  _tournament = tournyState.tournament;
                }

                return _generateUi();
              });
        });
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
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.white),
            //   onPressed: () => Navigator.of(context).pop(),
            // ),
            title: Text(_tournament.info.name),
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
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TournamentSelectionPage()));
        });
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
