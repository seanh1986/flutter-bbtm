import 'dart:async';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

import 'match_report.dart';

class MatchReportBloc extends Bloc<MatchReportEvent, MatchReportState> {
  TournamentRepository _tounyRepo;

  MatchReportBloc({required TournamentRepository tRepo})
      : _tounyRepo = tRepo,
        super(AppLaunchMatchReportState());

  @override
  Stream<MatchReportState> mapEventToState(MatchReportEvent event) async* {
    if (event is UpdateMatchReportEvent) {
      yield* _mapToMatchReportState(event);
    }

    yield AppLaunchMatchReportState();
  }

  Stream<MatchReportState> _mapToMatchReportState(
      UpdateMatchReportEvent event) async* {
    _tounyRepo.updateCoachMatchReport(
        event.tournament, event.matchup, event.isHome);

    yield UpdatedMatchReportState(event.matchup);
  }
}
