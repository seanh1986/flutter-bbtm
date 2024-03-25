import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/widgets/add_minus_widget/add_minus_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchupSquadWidget extends StatefulWidget {
  final SquadMatchup matchup;
  final int roundIdx;
  final bool refreshState;

  MatchupSquadWidget(
      {Key? key,
      required this.matchup,
      required this.roundIdx,
      required this.refreshState})
      : super(key: key);

  @override
  State<MatchupSquadWidget> createState() {
    return _MatchupSquadWidget();
  }
}

class _MatchupSquadWidget extends State<MatchupSquadWidget> {
  late Tournament _tournament;
  late User _user;

  late SquadMatchup _matchup;
  final double titleFontSize = 20.0;
  final double subTitleFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _matchup = widget.matchup;
  }

  void _refreshState() {
    _matchup = widget.matchup;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;
    _user = appState.authenticationState.user;

    if (widget.refreshState) {
      _refreshState();
    }

    return Container(
        alignment: FractionalOffset.center, child: _squadMatchupWidget());
  }

  Widget _squadMatchupWidget() {
    List<Widget> homeWidgets = [
      Text(_matchup.homeSquadName, style: TextStyle(fontSize: titleFontSize)),
      Text(_matchup.home(_tournament).showRecord(),
          style: TextStyle(fontSize: subTitleFontSize)),
    ];

    Widget? homeBonusWidget = _getBonusPtsWidget(true);
    if (homeBonusWidget != null) {
      homeWidgets.add(homeBonusWidget);
    }

    List<Widget> awayWidgets = [
      Text(_matchup.awaySquadName, style: TextStyle(fontSize: titleFontSize)),
      Text(_matchup.away(_tournament).showRecord(),
          style: TextStyle(fontSize: subTitleFontSize)),
    ];

    Widget? awayBonusWidget = _getBonusPtsWidget(false);
    if (awayBonusWidget != null) {
      awayWidgets.add(awayBonusWidget);
    }

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
            title: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Card(
                          color: _getColor(_matchup, true),
                          child: Column(
                            children: homeWidgets,
                          ),
                        ),
                      )),
                      Text(
                        ' vs. ',
                        style: TextStyle(fontSize: titleFontSize),
                      ),
                      Expanded(
                          child: Container(
                        child: Card(
                          color: _getColor(_matchup, false),
                          child: Column(
                            children: awayWidgets,
                          ),
                        ),
                      )),
                    ]))));
  }

  Widget? _getBonusPtsWidget(bool home) {
    List<BonusDetails> bonuses =
        _tournament.info.squadDetails.scoringDetails.bonusPts;

    if (bonuses.isEmpty) {
      return null;
    }

    Authorization authorization =
        _tournament.getSquadMatchAuthorization(_matchup, _user);

    if (authorization == Authorization.Unauthorized) {
      return null;
    }

    return ElevatedButton(
        onPressed: () {
          _showBonusDialog(home);
        },
        child: Text('Bonus Pts'));
  }

  Future<void> _showBonusDialog(bool home) async {
    String squadName = home ? _matchup.homeSquadName : _matchup.awaySquadName;

    String title = "Bonus Points: " + squadName;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          List<Widget> widgets = [];

          List<BonusDetails> bonuses =
              _tournament.info.squadDetails.scoringDetails.bonusPts;

          Map<String, List<int>> allSquadBonuses =
              _tournament.coachRounds[widget.roundIdx].squadBonuses;
          List<int>? thisSquadBonuses = allSquadBonuses[squadName];
          if (thisSquadBonuses == null) {
            thisSquadBonuses = [];
            allSquadBonuses.putIfAbsent(squadName, () => thisSquadBonuses!);
          }

          List<AddMinusWidget> addMinusWidgets = [];

          for (int i = 0; i < bonuses.length; i++) {
            BonusDetails bonusDetails = bonuses[i];

            if (thisSquadBonuses.length <= i) {
              thisSquadBonuses.add(0);
            }

            int value = thisSquadBonuses[i];

            addMinusWidgets.add(AddMinusWidget(
                item: AddMinusItem(name: bonusDetails.name, value: value)));
          }

          widgets.addAll(addMinusWidgets);
          widgets.add(SizedBox(height: 10));

          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: widgets,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  for (int i = 0; i < bonuses.length; i++) {
                    thisSquadBonuses![i] = addMinusWidgets[i].item.value;
                  }
                  context.read<AppBloc>().add(UpdateSquadBonusPts(_tournament));
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          );
        });
      },
    );
  }

  Color? _getColor(SquadMatchup m, bool home) {
    if (!m.hasResult()) {
      return null;
    }

    MatchResult result = m.getResult();

    switch (result) {
      case MatchResult.HomeWon:
        return home ? Colors.green : Colors.red;
      case MatchResult.AwayWon:
        return home ? Colors.red : Colors.green;
      case MatchResult.Draw:
        return Colors.orange;
      case MatchResult.Conflict:
      case MatchResult.NoResult:
      default:
        return null;
    }
  }
}
