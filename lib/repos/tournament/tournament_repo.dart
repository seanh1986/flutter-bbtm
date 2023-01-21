import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> getTournamentData(String tournamentId);

  Future<void> updateTournamentInfo(TournamentInfo tournamentInfo);

  Future<void> updateTournamentData(Tournament tournament);

  Future<void> updateCoachMatchReport(
      Tournament tournament, CoachMatchup matchup, bool isHome);

  // Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo);
}
