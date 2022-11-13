import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/models/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Container(
      child: Padding(
          padding: EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_welcomeUser(), _curRoundInfo()],
          )),
    );
  }

  Widget _welcomeUser() {
    return Container(
        padding: EdgeInsets.all(7),
        margin: EdgeInsets.all(7),
        child: Card(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome " +
                  (_authUser.nafName != null
                      ? _authUser.nafName.toString()
                      : "Guest") +
                  "!",
              style: TextStyle(fontSize: 20),
            ),
          ],
        )));
  }

  Widget _curRoundInfo() {
    return Container(
        child: Card(
            child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Round #" + _tournament.curRoundNumber.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    )));
  }
}
