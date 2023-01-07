import 'dart:async';
import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

import 'match_report.dart';

class MatchReportBloc extends Bloc<MatchReportEvent, MatchReportState> {
  AuthRepository _authRepo;
  TournamentRepository _tounyRepo;

  MatchReportBloc(
      {required AuthRepository aRepo, required TournamentRepository tRepo})
      : _authRepo = aRepo,
        _tounyRepo = tRepo,
        super(NotAuthorizedMatchReportState());

  @override
  Stream<MatchReportState> mapEventToState(MatchReportEvent event) async* {
    // if(event is )
    yield NotAuthorizedMatchReportState();
  }

  // Stream<LoginState> _mapLoginWithNafNameToState({
  //   required String nafName,
  // }) async* {
  //   yield LoadingLoginState();
  //   try {
  //     _authRepository.signIn(nafName);
  //     yield SuccessLoginState();
  //   } catch (_) {
  //     yield FailedLoginState();
  //   }
  // }
}
