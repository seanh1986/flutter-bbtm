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
}

/// Update tournament info or data (also hanles selection/update)
class UpdateTournamentEvent extends TournamentEvent {
  final Tournament tournament;

  const UpdateTournamentEvent(this.tournament);

  @override
  List<Object> get props => [tournament];
}

/// Select tournament & refresh UI
class SelectTournamentEvent extends TournamentEvent {
  final Tournament tournament;

  const SelectTournamentEvent(this.tournament);

  @override
  List<Object> get props => [tournament];
}
