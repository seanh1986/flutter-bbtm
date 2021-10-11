import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/models/tournament.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OverviewScreen extends StatefulWidget {
  final Tournament tournament;
  final String? nafName;

  OverviewScreen({Key? key, required this.tournament, required this.nafName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OverviewScreenState();
  }
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Tournament _tournament;
  late String? _nafName;
  late AuthBloc _authBloc;

  @override
  void initState() {
    _tournament = widget.tournament;
    _nafName = widget.nafName;

    super.initState();

    _authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(7),
        child: Stack(children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Stack(
              children: <Widget>[_welcomeUser()],
            ),
          )
        ]),
      ),
    );
  }

  Widget _welcomeUser() {
    return Container(
      child: Text(
        "Welcome " + (_nafName != null ? _nafName.toString() : "Guest") + "!",
      ),
    );
  }
}
