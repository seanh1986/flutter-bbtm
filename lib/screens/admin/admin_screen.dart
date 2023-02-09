import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/advance_round.dart';
import 'package:bbnaf/screens/admin/edit_tournament_widget.dart';
import 'package:flutter/material.dart';
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
  late TournamentBloc _tournyBloc;

  @override
  void initState() {
    _tournament = widget.tournament;
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
    return Column(
      children: [
        EditTournamentWidget(
          tournament: _tournament,
          tournyBloc: _tournyBloc,
        ),
        AdvanceRoundWidget(
          tournament: _tournament,
          tournyBloc: _tournyBloc,
        ),
      ],
    );
  }
}
