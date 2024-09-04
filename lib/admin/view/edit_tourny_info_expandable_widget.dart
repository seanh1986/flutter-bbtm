import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/admin/view/widgets/tourny_basic_info_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_home_page_info_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_individual_settings_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_orga_info_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_ranking_settings_widget.dart';
import 'package:bbnaf/admin/view/widgets/tourny_squad_settings_widget.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTournamentInfoExpandableWidget extends StatefulWidget {
  // Optional can supply tournament object for population (e.g., create tournament)
  final Tournament? tournament;
  final bool createTournament;

  EditTournamentInfoExpandableWidget(
      {Key? key, this.tournament, this.createTournament = false})
      : super(key: key);

  @override
  State<EditTournamentInfoExpandableWidget> createState() {
    return _EditTournamentInfoExpandableWidget();
  }
}

class ExpandListItem {
  String title;
  Widget widget;
  ExpandListItem(this.title, this.widget);
}

class _EditTournamentInfoExpandableWidget
    extends State<EditTournamentInfoExpandableWidget> {
  bool refreshFields = true;

  late Tournament _tournament;

  late TournyBasicInfoWidget _tournyBasicInfoWidget;
  late TournyOrganizerInfoWidget _tournyOrganizerInfoWidget;
  late TournyIndividualSettingsWidget _tournyIndividualSettingsWidget;
  late TournySquadSettingsWidget _tournySquadSettingsWidget;
  late TournyRankingSettingsWidget _tournyRankingSettingsWidget;
  late TournyHomePageInfoWidget _tournyHomePageInfoWidget;

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
    if (widget.tournament != null) {
      _tournament = widget.tournament!;
    } else {
      AppState appState = context.select((AppBloc bloc) => bloc.state);
      _tournament = appState.tournamentState.tournament;
    }

    _tournyBasicInfoWidget = TournyBasicInfoWidget(info: _tournament.info);

    _tournyOrganizerInfoWidget =
        TournyOrganizerInfoWidget(info: _tournament.info);

    _tournyIndividualSettingsWidget =
        TournyIndividualSettingsWidget(info: _tournament.info);

    _tournySquadSettingsWidget =
        TournySquadSettingsWidget(info: _tournament.info);

    _tournyRankingSettingsWidget =
        TournyRankingSettingsWidget(info: _tournament.info);

    _tournyHomePageInfoWidget =
        TournyHomePageInfoWidget(info: _tournament.info);

    List<Widget> widgets = [
      TitleBar(
        title: "Edit Tournament Info (Id: " + _tournament.info.id + ")",
        extraWidgets: [
          IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: _tournament.info.id));
                // copied successfully
              },
              icon: Icon(Icons.copy))
        ],
      ),
      SizedBox(height: 20),
      _updateOrDiscard(),
      Divider(),
      _createExpansionTile(
          ExpandListItem("Basic Information", _tournyBasicInfoWidget)),
      _createExpansionTile(
          ExpandListItem("Organizers", _tournyOrganizerInfoWidget)),
      _createExpansionTile(ExpandListItem(
          "Individual Scoring", _tournyIndividualSettingsWidget)),
      _createExpansionTile(
          ExpandListItem("Squad Settings", _tournySquadSettingsWidget)),
      _createExpansionTile(
          ExpandListItem("Ranking Settings", _tournyRankingSettingsWidget)),
      _createExpansionTile(
          ExpandListItem("Home Page Customization", _tournyHomePageInfoWidget)),
    ];

    return Column(
      children: widgets,
    );
  }

  ExpansionTile _createExpansionTile(ExpandListItem item) {
    return ExpansionTile(
      title: Text(item.title),
      // subtitle: Text('Leading expansion arrow icon'),
      controlAffinity: ListTileControlAffinity.leading,
      initiallyExpanded: false,
      children: <Widget>[item.widget],
    );
  }

  Widget _updateOrDiscard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              // refreshFields = true;
            });
          },
          child: const Text('Discard'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            VoidCallback callback = () async {
              TournamentInfo info = _tournament.info;

              _tournyBasicInfoWidget.updateTournamentInfo(info);
              _tournyOrganizerInfoWidget.updateTournamentInfo(info);
              _tournyIndividualSettingsWidget.updateTournamentInfo(info);
              _tournySquadSettingsWidget.updateTournamentInfo(info);
              _tournyRankingSettingsWidget.updateTournamentInfo(info);
              _tournyHomePageInfoWidget.updateTournamentInfo(info);

              // Handle create vs update tournament
              if (widget.createTournament) {
                ToastUtils.show(context, "Creating Tournament");
                context.read<AppBloc>().add(CreateTournament(context, info));
              } else {
                ToastUtils.show(context, "Updating Tournament Info");
                context
                    .read<AppBloc>()
                    .add(UpdateTournamentInfo(context, info));
              }
            };

            _showDialogToConfirmOverwrite(context, callback);
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  void _showDialogToConfirmOverwrite(
      BuildContext context, VoidCallback confirmedUpdateCallback) {
    StringBuffer sb = new StringBuffer();

    sb.writeln(
        "Warning this will overwrite existing tournament data. Please confirm!");
    sb.writeln("");
    sb.writeln("NumOrganizers: " +
        _tournyOrganizerInfoWidget.organizers.length.toString() +
        " (Primary: " +
        _tournyOrganizerInfoWidget.organizers
            .where((element) => element.primary)
            .length
            .toString() +
        ")");

    showOkCancelAlertDialog(
            context: context,
            title: "Update Tournament",
            message: sb.toString(),
            okLabel: "Update",
            cancelLabel: "Dismiss")
        .then((value) => {
              if (value == OkCancelResult.ok) {confirmedUpdateCallback()}
              // {_processUpdate(confirmedUpdateCallback)}
            });
  }
}
