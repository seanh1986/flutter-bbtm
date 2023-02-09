import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/widgets/matchup_coach_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CoachMatchupsPage extends StatefulWidget {
  final Tournament tournament;
  final AuthUser authUser;

  CoachMatchupsPage(
      {Key? key, required this.tournament, required this.authUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CoachMatchupsPage();
  }
}

class _CoachMatchupsPage extends State<CoachMatchupsPage> {
  late Tournament _tournament;
  late AuthUser _authUser;
  List<CoachMatchup> _matchups = [];

  FToast? fToast;

  late TournamentBloc _tournyBloc;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast!.init(context);

    _tournament = widget.tournament;
    _authUser = widget.authUser;

    if (_tournament.coachRounds.isNotEmpty) {
      _matchups = List.from(_tournament.coachRounds.last.matches);
    }

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  // TODO: Add CurCoach widget at top if non-null
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
        bloc: _tournyBloc,
        builder: (selectContext, selectState) {
          if (selectState is NewTournamentState) {
            _tournament = selectState.tournament;

            if (_tournament.coachRounds.isNotEmpty) {
              _matchups = List.from(_tournament.coachRounds.last.matches);
            }
          }

          if (_matchups.isEmpty) {
            return _noMatchUpsYet();
          }

          List<Widget> matchupWidgets = [
            SizedBox(height: 10),
            _getRoundTitle(),
            SizedBox(height: 10)
          ];

          _matchups.forEach((m) => matchupWidgets.add(MatchupCoachWidget(
                tournament: _tournament,
                authUser: _authUser,
                matchup: m,
              )));

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
                  children: matchupWidgets,
                )),
          );
        });
  }

  Widget _getRoundTitle() {
    return Wrap(alignment: WrapAlignment.center, children: [
      Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Round #" + _tournament.curRoundNumber().toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ]),
      ))
    ]);
  }
}

Widget _noMatchUpsYet() {
  return Container(
      margin: EdgeInsets.fromLTRB(20, 2, 20, 2), // EdgeInsets.all(20),
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Container(
            padding: EdgeInsets.all(2),
            child: Text(
              'Matchups not available yet',
              style: TextStyle(fontSize: 20),
            )),
      ));
}
