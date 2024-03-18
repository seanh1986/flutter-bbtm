import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/home/view/overview_screen.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:bbnaf/utils/serializable.dart';
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

class _HomePageState extends State<HomePage>
    implements Serializable, Deserializable {
  late int _widgetIdx;

  late FToast fToast;
  late Tournament _tournament;
  late User _user;

  List<Widget> _children = [];

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

    Map<String, dynamic> detailsJson = appState.screenState.screenDetailsJson;

    fromJson(detailsJson);

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
      OverviewScreen(),
      MatchupsPage(),
      RankingsPage(),
      AdminScreen(),
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
          body: _children[_widgetIdx],
          bottomNavigationBar: BottomNavigationBar(
            items: _getBottomNavigationBarItems(),
            currentIndex: _widgetIdx,
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
    if (_widgetIdx == 0) {
      context.read<AppBloc>().add(ScreenChange(TournamentSelectionPage.tag));
    } else {
      _widgetIdx = 0;
      context.read<AppBloc>().add(ScreenChange(
            HomePage.tag,
            screenDetailsJson: toJson(),
          ));
    }
  }

  void _onItemTapped(int index) {
    _widgetIdx = index;

    context.read<AppBloc>().add(ScreenChange(
          HomePage.tag,
          screenDetailsJson: toJson(),
        ));
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    final tWidgetIdx = json['widgetIdx'] as int?;
    _widgetIdx = tWidgetIdx != null ? tWidgetIdx : 0;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json;

    // Add child widget json (if necessary)
    Widget activeScreen = _children[_widgetIdx];
    if (activeScreen is Serializable) {
      json = (activeScreen as Serializable).toJson();
    } else {
      json = {};
    }

    // Add own json
    json.putIfAbsent("widgetIdx", () => _widgetIdx);

    return json;
  }
}
