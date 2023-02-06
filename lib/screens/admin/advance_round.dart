import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class AdvanceRoundWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  AdvanceRoundWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<AdvanceRoundWidget> createState() {
    return _AdvanceRoundWidget();
  }
}

class _AdvanceRoundWidget extends State<AdvanceRoundWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Tournament Management"),
      subtitle: Text("Advance round or edit previous rounds"),
      children: [_advanceRound(context)],
    );

    return _advanceRound(context);
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
              (widget.tournament.curRoundNumber + 1).toString()),
          onPressed: () {
            widget.tournament.processRound();

            String msg;
            SwissPairings swiss = SwissPairings(widget.tournament);
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
              widget.tournyBloc.add(UpdateTournamentEvent(widget.tournament));
            }
          },
        ));
  }
}
