import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class TournamentCreationPage extends StatefulWidget {
  // final AuthUser authUser;

  // TournamentCreationPage({Key? key, required this.authUser}) : super(key: key);
  // TournamentCreationPage({Key? key, AuthUser? authUser})
  //     : authUser = authUser ?? AuthUser.nafNameOnly("Guest"),
  //       super(key: key);

  TournamentCreationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TournamentCreationPage();
  }
}

class _TournamentCreationPage extends State<TournamentCreationPage> {
  late Tournament _tournament;
  late User _user;
  late final String id;

  @override
  void initState() {
    id = Uuid().v1();

    super.initState();
  }

  @override
  void dispose() {
    // _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _user =
        context.select((AppBloc bloc) => bloc.state.authenticationState.user);

    String email = _user.getEmail();
    String nafName = _user.getNafName();

    _tournament = Tournament.empty();
    _tournament.info.id = id;
    _tournament.info.organizers.add(OrganizerInfo(email, nafName, true));

    // return AdminScreen(tournament: _tournament, authUser: widget.authUser);
    return Material(
        child: EditTournamentInfoWidget(
      tournament: _tournament,
    ));
  }
}
