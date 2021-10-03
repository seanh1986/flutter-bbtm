import 'package:bbnaf/models/tournament.dart';
import 'package:bbnaf/models/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();

  Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo);
}
