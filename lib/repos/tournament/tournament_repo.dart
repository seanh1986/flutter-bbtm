import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/screens/admin/edit_tournament_widget.dart';

abstract class TournamentRepository {
  // ------------------
  // Read only operations
  // ------------------

  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> getTournamentData(String tId);

  Future<Tournament?> getTournamentDataAsync(String tId);

  // ------------------
  // Update Operations
  // ------------------

  Future<bool> overwriteTournamentInfo(TournamentInfo info);

  Future<bool> overwriteCoaches(
      String tId, List<Coach> newCoaches, List<RenameNafName> renames);

  Future<bool> updateCoachMatchReport(UpdateMatchReportEvent event);

  Future<bool> updateCoachMatchReports(List<UpdateMatchReportEvent> event);

  Future<bool> recoverTournamentBackup(Tournament t);

  Future<bool> advanceRound(Tournament t);

  Future<bool> discardCurrentRound(Tournament t);

  // ------------------
  // File Downloads
  // ------------------

  Future<String> getFileUrl(String filename);

  Future<bool> downloadFile(String filename);

  Future<bool> downloadBackupFile(Tournament t);

  Future<bool> downloadNafUploadFile(Tournament t);

  Future<bool> downloadGlamFile(Tournament t);
}
