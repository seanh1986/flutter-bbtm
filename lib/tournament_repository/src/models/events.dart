import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';

/// Download tournament backup file
class DownloadTournamentBackup {
  final Tournament tournament;

  const DownloadTournamentBackup(this.tournament);

  @override
  String toString() => 'DownloadTournamentBackup';
}

/// Download file
// class DownloadFile {
//   final String fileName;

//   const DownloadFile(this.fileName);

//   @override
//   String toString() => 'DownloadFile';
// }

/// Upload match reports
class UpdateMatchReportEvent {
  final Tournament tournament;
  final CoachMatchup matchup;
  late final bool isHome;
  late final bool isAdmin;
  late final int roundIdx;

  UpdateMatchReportEvent(this.tournament, this.matchup, this.isHome) {
    this.isAdmin = false;
    roundIdx = tournament.curRoundIdx();
  }

  UpdateMatchReportEvent.admin(this.tournament, this.matchup, this.roundIdx) {
    this.isHome = false;
    this.isAdmin = true;
  }

  @override
  String toString() => 'UpdateMatchReportEvent';
}

/// Rename coach
class UpdateCoachEvent {
  final String? oldNafName;
  final Coach newCoach;

  UpdateCoachEvent(this.oldNafName, this.newCoach);
}
