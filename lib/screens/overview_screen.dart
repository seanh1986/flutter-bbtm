import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

class OverviewScreen extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;

  OverviewScreen({Key? key, required this.tournament, required this.authUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OverviewScreenState();
  }
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Tournament _tournament;
  late AuthUser _authUser;

  @override
  void initState() {
    _tournament = widget.tournament;
    _authUser = widget.authUser;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      _welcomeUserAndDisplayCurrentRound(),
    ];

    Widget? weatherTable = _customWeatherTable(_tournament.info);
    if (weatherTable != null) {
      widgets.add(weatherTable);
    }

    Widget? kickOffTable = _customKickOffTable(_tournament.info);
    if (kickOffTable != null) {
      widgets.add(kickOffTable);
    }

    Widget? specialRules = _customSpecialRules(_tournament.info);
    if (specialRules != null) {
      widgets.add(specialRules);
    }

    widgets.add(_scoringDetails(_tournament.info));

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              './assets/images/background/background_football_field.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: widgets,
        ),
      ),
    );
  }

  Widget _welcomeUserAndDisplayCurrentRound() {
    String userName;
    if (_authUser.nafName != null) {
      userName = _authUser.nafName.toString();
    } else if (_authUser.user?.displayName != null) {
      userName = _authUser.user!.displayName!.toString();
    } else {
      userName = "Guest";
    }

    String roundNumber = _tournament.curRoundNumber.toString();

    return _generateCardWidget([
      Text(
        "Welcome " + userName + "!",
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
    if (t.detailsWeather.isEmpty) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Weather Table",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      Text(""),
      Html(data: t.detailsWeather),
    ]);
  }

  Widget? _customKickOffTable(TournamentInfo t) {
    if (t.detailsKickOff.isEmpty) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Kick-Off Table",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      Text(""),
      Html(data: t.detailsKickOff),
    ]);
  }

  Widget? _customSpecialRules(TournamentInfo t) {
    if (t.detailsSpecialRules.isEmpty) {
      return null;
    }

    return _generateCardWidget([
      Text(
        "Special Rules",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      Text(""),
      Html(data: t.detailsSpecialRules),
    ]);
  }

  Widget _scoringDetails(TournamentInfo t) {
    String countAsCasualtyTitle = "Casualties included";

    List<String> casualtyTypes = [];

    if (t.scoringDetails.casualtyDetails.spp) {
      casualtyTypes.add("SPP");
    }
    if (t.scoringDetails.casualtyDetails.foul) {
      casualtyTypes.add("fouls");
    }
    if (t.scoringDetails.casualtyDetails.surf) {
      casualtyTypes.add("surfs");
    }
    if (t.scoringDetails.casualtyDetails.dodge) {
      casualtyTypes.add("failed dodges");
    }

    String countAsCasualtyDetails = casualtyTypes.join(", ");

    return _generateCardWidget([
      Text(
        "Scoring Details",
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
      ),
      Text(""),
      Row(
        children: [
          Text(
            "W/T/L",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Text(": "),
          Text(t.scoringDetails.winPts.toString() +
              "/" +
              t.scoringDetails.tiePts.toString() +
              "/" +
              t.scoringDetails.lossPts.toString())
        ],
      ),
      Text(""),
      Row(
        children: [
          Text(
            countAsCasualtyTitle,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Text(": "),
          Text(countAsCasualtyDetails)
        ],
      )
    ]);
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
