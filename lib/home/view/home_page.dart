import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/home/view/overview_screen.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  static const String tag = "HomePage";

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

  late FToast fToast;
  late Tournament _tournament;
  late User _user;

  List<_WidgetFamily> _children = [];

  @override
  void initState() {
    super.initState();

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
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    print("HomePage: User: " +
        _user.getNafName() +
        ", Tournament: " +
        _tournament.info.name);

    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          setState(() {});
        },
        child: _generateUi(context, appState));
  }

  void _handleLogoutPressed() {
    print("Logout Pressed");
    // ToastUtils.show(fToast, "Logging out");
    context.read<AppBloc>().add(const AppLogoutRequested());
  }

  void _handleRefreshTournamentPressed() {
    print("Refresh Tournament Pressed");
    ToastUtils.show(fToast, "Refreshing Tournament Data");
    context.read<AppBloc>().add(AppTournamentRequested(_tournament.info.id));
  }

  Widget _generateUi(BuildContext context, AppState appState) {
    final theme = Theme.of(context);

    _children = [
      new _WidgetFamily([OverviewScreen()]),
      new _WidgetFamily([MatchupsPage()]),
      new _WidgetFamily([RankingsPage()]),
      new _WidgetFamily([AdminScreen()]),
    ];

    return PopScope(
        onPopInvoked: (bool didPop) {
          _handleBackButton();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.iconTheme.color,
              ),
              onPressed: () => _handleBackButton(),
            ),
            title: Text(_tournament.info.name),
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh),
                  color: theme.iconTheme.color,
                  onPressed: () => _handleRefreshTournamentPressed()),
              SizedBox(width: 20),
              IconButton(
                  icon: Icon(Icons.logout),
                  color: theme.iconTheme.color,
                  onPressed: () => _handleLogoutPressed()),
              SizedBox(width: 10),
            ],
          ),
          body: _children[_parentIndex].widgets[_childIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _getBottomNavigationBarItems(),
            currentIndex: _parentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor:
                theme.bottomNavigationBarTheme.unselectedItemColor,
          ),
        ));
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.sports_football), label: 'Matches'),
      BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Rankings'),
    ];

    if (_tournament.isUserAdmin(_user)) {
      items.add(
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Admin'));
    }

    return items;
  }

  void _handleBackButton() {
    if (_childIndex == 0) {
      if (_parentIndex == 0) {
        // context.read<AppBloc>().add(AppRequestNavToTournamentList());
        context.read<AppBloc>().add(ScreenChange(TournamentSelectionPage.tag));
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
}
