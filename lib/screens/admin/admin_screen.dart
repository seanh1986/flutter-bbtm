import 'package:bbnaf/blocs/tournament/tournament_bloc.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/edit_tournament_widget.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
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

class _AdminScreenState extends State<AdminScreen> {
  late Tournament _tournament;
  late AuthUser _authUser;
  late TournamentBloc _tournyBloc;

  @override
  void initState() {
    _tournament = widget.tournament;
    _authUser = widget.authUser;
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
    return BlocBuilder<TournamentBloc, TournamentState>(
        bloc: _tournyBloc,
        builder: (selectContext, selectState) {
          if (selectState is NewTournamentState) {
            _tournament = selectState.tournament;
          }
          return _generateView();
        });
  }

  Widget _generateView() {
    // List<Widget> widgets = [
    //   SizedBox(height: 10),
    //   _editTournament(),
    //   SizedBox(height: 10),
    //   _advanceRound(context)
    // ];

    return Column(
      children: [
        EditTournamentWidget(tournament: widget.tournament),
        ExpansionTile(
          title: Text("Tournament Management"),
          subtitle: Text("Advance round or edit previous rounds"),
          children: [_advanceRound(context)],
        )
      ],
    );

    // return ListView(
    //   children: widgets,
    // );
    // return Container(
    //   child: Padding(
    //       padding: EdgeInsets.all(7),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[_editTournament(), _advanceRound(context)],
    //       )),
    // );
  }

  Widget _editTournament() {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Edit Tournament'),
          onPressed: () {
            // TODO: Handle edit
            // EditTournamentWidget(tournament: _tournament);
          },
        ));
  }

  Widget _advanceRound(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Advance to Round: ' +
              (_tournament.curRoundNumber + 1).toString()),
          onPressed: () {
            _tournament.processRound();

            String msg;
            SwissPairings swiss = SwissPairings(_tournament);
            RoundPairingError pairingError = swiss.pairNextRound();

            switch (pairingError) {
              case RoundPairingError.NoError:
                msg = "Succesful";
                break;
              case RoundPairingError.MissingPreviousResults:
                msg = "Missing Previous Results";
                break;
              case RoundPairingError.UnableToFindValidMatches:
                msg = "Unable To Find Valid Matches";
                break;
              default:
                msg = "Unknown Error";
                break;
            }

            showOkAlertDialog(
                context: context, title: "Advance Round", message: msg);

            if (pairingError == RoundPairingError.NoError) {
              _tournyBloc.add(UpdateTournamentEvent(_tournament));
            }
          },
        ));
  }
}
