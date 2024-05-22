import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/widgets/toggle_widget/models/toggle_widget_item.dart';
import 'package:bbnaf/widgets/toggle_widget/view/toggle_widget.dart';
import 'package:flutter/material.dart';

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
    List<ToggleWidgetItem> items = [];

    adminSubScreens.forEach((element) {
      WidgetBuilder? widgetBuilder = _getSubScreenBuilder(element);
      if (widgetBuilder != null) {
        items.add(
            ToggleWidgetItem(element.name.replaceAll("_", " "), widgetBuilder));
      }
    });

    return ToggleWidget(items: items);
  }

  WidgetBuilder? _getSubScreenBuilder(AdminSubScreens subScreen) {
    switch (subScreen) {
      case AdminSubScreens.EDIT_INFO:
        return (context) => EditTournamentInfoWidget(createTournament: false);
      case AdminSubScreens.EDIT_SQUADS:
        return null; // TODO...
      case AdminSubScreens.EDIT_PARTICIPANTS:
        return (context) => EditParticipantsWidget();
      case AdminSubScreens.ROUND_MANAGEMENT:
        return (context) => RoundManagementWidget();
      case AdminSubScreens.DOWNLOAD_FILES:
        return (context) => DownloadFilesWidget();
      default:
        return null;
    }
  }
}
