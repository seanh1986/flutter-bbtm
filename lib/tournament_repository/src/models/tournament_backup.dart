import 'package:bbnaf/tournament_repository/src/models/tournament.dart';
import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';

class TournamentBackup {
  late Tournament tournament;
  TournamentBackup({required this.tournament});

  TournamentBackup.fromJson(Map<String, dynamic> json) {
    final tId = json['id'] as String?;
    if (tId == null) {
      throw new Exception("Failed to parse tournament backup. Id is null.");
    }

    final tInfo = json['info'] as Map<String, dynamic>?;
    if (tInfo == null) {
      throw new Exception("Failed to parse tournament backup. Info is null.");
    }

    TournamentInfo info = TournamentInfo.fromJson(tId, tInfo);

    final tData = json['data'] as Map<String, dynamic>?;
    if (tData == null) {
      throw new Exception("Failed to parse tournament backup. Data is null.");
    }

    this.tournament = Tournament.fromJson(info, tData);
  }

  Map<String, dynamic> toJson() => {
        'id': tournament.info.id,
        'info': tournament.info.toJson(),
        'data': tournament.toJson(),
      };
}
