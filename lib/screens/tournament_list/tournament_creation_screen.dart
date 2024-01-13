import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../admin/edit_tourny_info_widget.dart';

class TournamentCreationPage extends StatefulWidget {
  final AuthUser authUser;

  TournamentCreationPage({Key? key, required this.authUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentCreationPage();
  }
}

class _TournamentCreationPage extends State<TournamentCreationPage> {
  late Tournament _tournament;
  late TournamentBloc _tournyBloc;

  @override
  void initState() {
    _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    _tournament = Tournament.empty();

    _tournament.info.id = Uuid().v1();

    String email = widget.authUser.getEmail();
    String nafName = widget.authUser.getNafName();

    _tournament.info.organizers.add(OrganizerInfo(email, nafName, true));

    super.initState();
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return AdminScreen(tournament: _tournament, authUser: widget.authUser);
    return Material(
        child: EditTournamentInfoWidget(
            tournament: _tournament, tournyBloc: _tournyBloc));
  }
}
