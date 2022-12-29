import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> getTournamentData(TournamentInfo tournamentInfo);

  Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo);
}
