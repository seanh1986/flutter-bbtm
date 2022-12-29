import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

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

  @override
  void initState() {
    _tournament = widget.tournament;
    _authUser = widget.authUser;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_editTournament(), _advanceRound(context)],
          )),
    );
  }

  Widget _editTournament() {
    return Container(
        height: 50,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Edit Tournament (To be refactored)'),
          onPressed: () {
            // TODO: Handle edit
          },
        ));
  }

  Widget _advanceRound(BuildContext context) {
    return Container(
        height: 50,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Advance to Round: ' +
              (_tournament.curRoundNumber + 1).toString()),
          onPressed: () {
            SwissPairings swiss = SwissPairings(_tournament);
            RoundPairingError pairingError = swiss.pairNextRound();

            String msg;
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
              setState(() {
                _tournament = _tournament;
              });
            }
          },
        ));
  }
}
