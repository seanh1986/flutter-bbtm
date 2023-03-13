import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/download_files_widget.dart';
import 'package:bbnaf/screens/admin/round_management_widget.dart';
import 'package:bbnaf/screens/admin/edit_participants_widget.dart';
import 'package:bbnaf/screens/admin/edit_tourny_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminScreen extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;

  AdminScreen({Key? key, required this.tournament, required this.authUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AdminScreenState();
  }
}

enum AdminSubScreens {
  EDIT_INFO,
  EDIT_PARTICIPANTS,
  ROUND_MANAGEMENT,
  DOWNLOAD_FILES,
}

class _AdminScreenState extends State<AdminScreen> {
  late Tournament _tournament;
  late TournamentBloc _tournyBloc;

  AdminSubScreens subScreen = AdminSubScreens.EDIT_INFO;

  @override
  void initState() {
    _tournament = widget.tournament;
    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    super.initState();
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [
      _toggleButtonsList(context),
      SizedBox(height: 20),
    ];

    Widget? subScreenWidget = _getSubScreen();

    if (subScreenWidget != null) {
      _widgets.add(subScreenWidget);
    }

    return Column(children: _widgets);
  }

  Widget _toggleButtonsList(BuildContext context) {
    List<Widget> toggleWidgets = [];

    AdminSubScreens.values.forEach((element) {
      toggleWidgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(color: Colors.white),
        ),
        child: Text(element.name.replaceAll("_", " ")),
        onPressed: () {
          setState(() {
            subScreen = element;
          });
        },
      ));

      toggleWidgets.add(SizedBox(width: 10));
    });

    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal, children: toggleWidgets));
  }

  Widget? _getSubScreen() {
    switch (subScreen) {
      case AdminSubScreens.EDIT_INFO:
        return EditTournamentInfoWidget(
            tournament: _tournament, tournyBloc: _tournyBloc);
      case AdminSubScreens.EDIT_PARTICIPANTS:
        return EditParticipantsWidget(
            tournament: _tournament, tournyBloc: _tournyBloc);
      case AdminSubScreens.ROUND_MANAGEMENT:
        return RoundManagementWidget(
            tournament: _tournament, tournyBloc: _tournyBloc);
      case AdminSubScreens.DOWNLOAD_FILES:
        return DownloadFilesWidget(
            tournament: _tournament, tournyBloc: _tournyBloc);
      default:
        return null;
    }
  }
}
