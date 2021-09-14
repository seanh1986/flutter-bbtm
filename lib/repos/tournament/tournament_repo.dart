import 'package:bbnaf/models/tournament_info.dart';

abstract class TournamentRepository {
  Stream<List<TournamentInfo>> getTournamentInfos();
}
