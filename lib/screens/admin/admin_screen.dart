import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/screens/admin/download_files_widget.dart';
import 'package:bbnaf/screens/admin/round_management_widget.dart';
import 'package:bbnaf/screens/admin/edit_participants_widget.dart';
import 'package:bbnaf/screens/admin/edit_tourny_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AdminScreenState();
  }
}

enum AdminSubScreens {
  EDIT_INFO,
  EDIT_SQUADS,
  EDIT_PARTICIPANTS,
  ROUND_MANAGEMENT,
  DOWNLOAD_FILES,
}

class _AdminScreenState extends State<AdminScreen> {
  List<AdminSubScreens> adminSubScreens = [
    AdminSubScreens.EDIT_INFO,
    AdminSubScreens.EDIT_PARTICIPANTS,
    AdminSubScreens.ROUND_MANAGEMENT,
    AdminSubScreens.DOWNLOAD_FILES,
  ];
  AdminSubScreens subScreen = AdminSubScreens.EDIT_INFO;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

    final theme = Theme.of(context);

    adminSubScreens.forEach((element) {
      toggleWidgets.add(ElevatedButton(
        style: theme.elevatedButtonTheme.style,
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
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: toggleWidgets));
  }

  Widget? _getSubScreen() {
    switch (subScreen) {
      case AdminSubScreens.EDIT_INFO:
        return EditTournamentInfoWidget();
      case AdminSubScreens.EDIT_SQUADS:
        return null; // TODO...
      case AdminSubScreens.EDIT_PARTICIPANTS:
        return EditParticipantsWidget();
      case AdminSubScreens.ROUND_MANAGEMENT:
        return RoundManagementWidget();
      case AdminSubScreens.DOWNLOAD_FILES:
        return DownloadFilesWidget();
      default:
        return null;
    }
  }
}
