import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object> get props => [];
}

/// No tournament selected
class NoTournamentEvent extends TournamentEvent {}

/// Trigger load of tournament
class LoadTournamentEvent extends TournamentEvent {
  final TournamentInfo info;

  const LoadTournamentEvent(this.info);

  @override
  List<Object> get props => [info];

  @override
  String toString() => 'LoadTournamentEvent';
}

class UpdateMatchReportEvent extends TournamentEvent {
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
  List<Object> get props => [tournament, matchup, isHome, isAdmin];

  @override
  String toString() => 'UpdateMatchReportEvent';
}

/// Update tournament info or data (also hanles selection/update)
class UpdateTournamentEvent extends TournamentEvent {
  final Tournament tournament;

  const UpdateTournamentEvent(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() => 'UpdateTournamentEvent';
}

/// Select tournament & refresh UI
class SelectTournamentEvent extends TournamentEvent {
  final Tournament tournament;

  const SelectTournamentEvent(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() => 'SelectTournamentEvent';
}
