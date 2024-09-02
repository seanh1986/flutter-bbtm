import 'dart:convert';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OverviewScreenState();
  }
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Tournament _tournament;
  late User _user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    List<Widget> widgets = [
      _welcomeUserAndDisplayCurrentRound(),
    ];

    Widget? kickOffTable = _customKickOffTable(_tournament.info);
    if (kickOffTable != null) {
      widgets.add(kickOffTable);
    }

    Widget? weatherTable = _customWeatherTable(_tournament.info);
    if (weatherTable != null) {
      widgets.add(weatherTable);
    }

    Widget? specialRules = _customSpecialRules(_tournament.info);
    if (specialRules != null) {
      widgets.add(specialRules);
    }

    widgets.add(_getScoringPointsTiebreakerDetails(_tournament.info));

    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage(
      //         './assets/images/background/background_football_field.png'),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: widgets,
        ),
      ),
    );
  }

  Widget _welcomeUserAndDisplayCurrentRound() {
    String nafName = _user.getNafName();

    if (nafName.isEmpty) {
      nafName = "Guest";
    }

    String roundNumber = _tournament.curRoundNumber().toString();

    return _generateCardWidget([
      Text(
        "Welcome " + nafName + "!",
        style: TextStyle(fontSize: 30),
      ),
      Text(
        "",
        style: TextStyle(fontSize: 20),
      ),
      Text(
        "Round #" + roundNumber,
        style: TextStyle(fontSize: 20),
      ),
    ]);
  }

  Widget? _customWeatherTable(TournamentInfo t) {
    Widget? widget = _parseQuillOrHtml(t.detailsWeather);
    if (widget == null) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Weather Table",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      widget,
    ]);
  }

  Widget? _customKickOffTable(TournamentInfo t) {
    Widget? widget = _parseQuillOrHtml(t.detailsKickOff);
    if (widget == null) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Kick-Off Table",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      widget,
    ]);
  }

  Widget? _customSpecialRules(TournamentInfo t) {
    Widget? widget = _parseQuillOrHtml(t.detailsSpecialRules);
    if (widget == null) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Special Rules",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      widget,
    ]);
  }

  Widget? _parseQuillOrHtml(String input) {
    try {
      // Try parsing using quill
      QuillController controller = QuillController(
          document: Document(),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true);
      final json = jsonDecode(input);

      // Check for empty quill
      if (json.length <= 1) {
        final tJson = json[0] as dynamic;
        final tInsert = tJson["insert"] as dynamic;
        if (tInsert == "\n") {
          return null;
        }
      }

      controller.document = Document.fromJson(json);
      return QuillEditor.basic(controller: controller);
    } catch (_) {
      try {
        if (input.isEmpty) {
          return null;
        }

        return HtmlWidget(input);
      } catch (_) {}
    }

    return Text("");
  }

  Widget _getScoringPointsTiebreakerDetails(TournamentInfo t) {
    bool useSquads = t.squadDetails.type == SquadUsage.SQUADS;

    String individualScoringDetailsTitle =
        useSquads ? "Individual Scoring Details" : "Scoring Details";

    String individualTiebreakersTitle =
        useSquads ? "Individual Tiebreakers" : "Tiebreakers";

    List<Widget> views = [
      _getWinTieLossWidget(t.scoringDetails, individualScoringDetailsTitle),
      Text(""),
    ];

    Widget? bonusPts = _getBonusPts(t.scoringDetails);
    if (bonusPts != null) {
      views.add(bonusPts);
      views.add(Text(""));
    }

    views.add(_getIndividualTieBreakers(
        individualTiebreakersTitle, t.scoringDetails));

    List<Widget> squadDetailsWidgets = _generateSquadDetails(t.squadDetails);

    if (squadDetailsWidgets.isNotEmpty) {
      views.add(Text(""));
      views.addAll(squadDetailsWidgets);
    }

    views.addAll([
      Text(""),
      _getCasultyDetailsWidget(t.casualtyDetails),
    ]);

    return _generateCardWidget(views);
  }

  Widget _getWinTieLossWidget(ScoringDetails scoringDetails, String? label) {
    return _getUnderlinedEntry(
        label != null ? label : "W/T/L",
        scoringDetails.winPts.toString() +
            "/" +
            scoringDetails.tiePts.toString() +
            "/" +
            scoringDetails.lossPts.toString(),
        false);
  }

  Widget? _getBonusPts(ScoringDetails scoringDetails) {
    if (scoringDetails.bonusPts.isEmpty) {
      return null;
    }

    StringBuffer sb = StringBuffer();

    scoringDetails.bonusPts.forEach((a) {
      sb.writeln(a.name + ": " + a.weight.toString());
    });

    return _getUnderlinedEntry("Bonus Pts", sb.toString(), true);
  }

  Widget _getIndividualTieBreakers(
      String label, IndividualScoringDetails scoringDetails) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < scoringDetails.tieBreakers.length; i++) {
      String tieBreakerName =
          EnumToString.convertToString(scoringDetails.tieBreakers[i]);
      sb.write(tieBreakerName);
      if (i + 1 < scoringDetails.tieBreakers.length) {
        sb.write("\n");
      }
    }
    return _getUnderlinedEntry(label, sb.toString(), true);
  }

  Widget _getCasultyDetailsWidget(CasualtyDetails casualtyDetails) {
    String countAsCasualtyTitle = "Casualties included";

    List<String> casualtyTypes = [];

    if (casualtyDetails.spp) {
      casualtyTypes.add("SPP");
    }
    if (casualtyDetails.foul) {
      casualtyTypes.add("fouls");
    }
    if (casualtyDetails.surf) {
      casualtyTypes.add("surfs");
    }
    if (casualtyDetails.dodge) {
      casualtyTypes.add("failed dodges");
    }

    String countAsCasualtyDetails = casualtyTypes.join(", ");

    return Row(
      children: [
        Text(
          countAsCasualtyTitle,
          style: TextStyle(decoration: TextDecoration.underline),
        ),
        Text(": "),
        Text(countAsCasualtyDetails)
      ],
    );
  }

  List<Widget> _generateSquadDetails(SquadDetails squadDetails) {
    if (squadDetails.type == SquadUsage.NO_SQUADS ||
        squadDetails.type == SquadUsage.INDIVIDUAL_USE_SQUADS_FOR_INIT) {
      return [];
    }

    List<Widget> views = [
      _getSquadNumMembers(squadDetails),
      Text(""),
      _getSquadScoringType(squadDetails.scoringType),
    ];

    if (squadDetails.scoringType == SquadScoring.SQUAD_RESULT_W_T_L) {
      views.addAll([
        Text(""),
        _getWinTieLossWidget(squadDetails.scoringDetails, "Squad W/T/L")
      ]);
    }

    views.addAll([
      Text(""),
      _getSquadTieBreakers(squadDetails),
    ]);

    return views;
  }

  Widget _getSquadScoringType(SquadScoring scoring) {
    String scoringType = "";

    switch (scoring) {
      case SquadScoring.CUMULATIVE_PLAYER_SCORES:
        scoringType = "Cumulative Player Scores";
        break;
      case SquadScoring.SQUAD_RESULT_W_T_L:
        scoringType = "Squad Record";
        break;
    }

    return _getUnderlinedEntry("Squad Scoring Type", scoringType, false);
  }

  Widget _getSquadNumMembers(SquadDetails squadDetails) {
    if (squadDetails.requiredNumCoachesPerSquad ==
        squadDetails.maxNumCoachesPerSquad) {
      return _getUnderlinedEntry("Num Coaches / Squad",
          squadDetails.requiredNumCoachesPerSquad.toString(), false);
    } else {
      return Column(children: [
        _getUnderlinedEntry("Num Active Coaches / Squad",
            squadDetails.requiredNumCoachesPerSquad.toString(), false),
        Text(""),
        _getUnderlinedEntry("Max Coaches / Squad",
            squadDetails.maxNumCoachesPerSquad.toString(), false),
      ]);
    }
  }

  Widget _getSquadTieBreakers(SquadDetails squadDetails) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < squadDetails.squadTieBreakers.length; i++) {
      String tieBreakerName =
          EnumToString.convertToString(squadDetails.squadTieBreakers[i]);
      sb.write(tieBreakerName);
      if (i + 1 < squadDetails.squadTieBreakers.length) {
        sb.write("\n");
      }
    }
    return _getUnderlinedEntry("Squad Tiebreakers", sb.toString(), true);
  }

  Widget _getUnderlinedEntry(String label, String value, bool valueOnNewLine) {
    if (valueOnNewLine) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            label,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Text(": ")
        ]),
        Text(value)
      ]);
    } else {
      return Row(
        children: [
          Text(
            label,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Text(": "),
          Text(value)
        ],
      );
    }
  }

  Widget _generateCardWidget(List<Widget> children) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 2, 20, 2),
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.all(10),
          child: Container(
              padding: EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              )),
        ));
  }
}
