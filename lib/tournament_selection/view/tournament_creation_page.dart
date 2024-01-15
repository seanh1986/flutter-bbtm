import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/repos/auth/auth_user.dart';
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
  // late TournamentBloc _tournyBloc;

  late final User user;
  late final String id;

  @override
  void initState() {
    // _tournyBloc = BlocProvider.of<TournamentBloc>(context);

    // _tournament = Tournament.empty();

    // _tournament.info.id = Uuid().v1();
    id = Uuid().v1();

    // String email = widget.authUser.getEmail();
    // String nafName = widget.authUser.getNafName();

    // _tournament.info.organizers.add(OrganizerInfo(email, nafName, true));

    super.initState();
  }

  @override
  void dispose() {
    // _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user =
        context.select((AppBloc bloc) => bloc.state.authenticationState.user);

    String email = user.getEmail();
    String nafName = user.getNafName();

    _tournament = Tournament.empty();
    _tournament.info.id = id;
    _tournament.info.organizers.add(OrganizerInfo(email, nafName, true));

    // return AdminScreen(tournament: _tournament, authUser: widget.authUser);
    // return Material(
    //     child: EditTournamentInfoWidget(
    //         tournament: _tournament, tournyBloc: _tournyBloc));
    return Text("TODO: Create Tournament. Id: " +
        id +
        ". Orga: " +
        email +
        " | " +
        nafName);
  }
}
