import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> getTournamentData(String tournamentId);

  Future<bool> updateTournamentData(Tournament tournament);

  Future<bool> updateCoachMatchReport(UpdateMatchReportEvent event);

  Future<String> getFileUrl(String filename);

  Future<bool> downloadFile(String filename);

  Future<bool> downloadBackupFile(Tournament tournament);

  Future<bool> downloadNafUploadFile(Tournament tournament);

  Future<Tournament?> getTournamentDataAsync(String tournamentId);
}
