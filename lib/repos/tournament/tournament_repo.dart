import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> getTournamentData(String tournamentId);

  // Future<void> updateTournamentInfo(TournamentInfo tournamentInfo);

  Future<void> updateTournamentData(Tournament tournament);

  Future<void> updateCoachMatchReport(UpdateMatchReportEvent event);

  Future<String> getFileUrl(String filename);

  // Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo);
}
