import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object> get props => [];
}

/// No tournament selected
class TournamentEventUninitialized extends TournamentEvent {}

/// Trigger load of tournament
class TournamentEventFetchData extends TournamentEvent {
  final String tournamentId;

  const TournamentEventFetchData(this.tournamentId);

  @override
  List<Object> get props => [tournamentId];

  @override
  String toString() => 'TournamentEventFetchData: tId: $tournamentId';
}

/// Select tournament & refresh UI
class TournamentEventSelectedTourny extends TournamentEvent {
  final Tournament tournament;

  const TournamentEventSelectedTourny(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() =>
      'TournamentEventSelectedTourny tId: ${tournament.info.id}';
}

/// Re-fetch tournament data & refresh UI
class TournamentEventRefreshData extends TournamentEvent {
  final String tournamentId;

  const TournamentEventRefreshData(this.tournamentId);

  @override
  List<Object> get props => [tournamentId];

  @override
  String toString() => 'TournamentEventRefreshData: tId: $tournamentId';
}

/// Download tournament backup file
class DownloadTournamentBackup {
  final Tournament tournament;

  const DownloadTournamentBackup(this.tournament);

  @override
  String toString() => 'DownloadTournamentBackup';
}

/// Download file
class DownloadFile {
  final String fileName;

  const DownloadFile(this.fileName);

  @override
  String toString() => 'DownloadFile';
}

/// Upload match reports
class UpdateMatchReportEvent {
  final Tournament tournament;
  final CoachMatchup matchup;
  late final bool isHome;
  late final bool isAdmin;

  UpdateMatchReportEvent(this.tournament, this.matchup, this.isHome) {
    this.isAdmin = false;
  }

  UpdateMatchReportEvent.admin(this.tournament, this.matchup) {
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
