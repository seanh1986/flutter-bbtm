import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object> get props => [];
}

/// No tournament selected
class TournamentStateUninitialized extends TournamentState {}

/// Loading in progress
class TournamentStateLoading extends TournamentState {
  final String tournamentId;

  const TournamentStateLoading(this.tournamentId);

  @override
  List<Object> get props => [tournamentId];

  @override
  String toString() {
    return 'TournamentStateLoading { tId: $tournamentId }';
  }
}

/// Tournament loaded or updated -> Refresh UI
class TournamentStateLoaded extends TournamentState {
  final Tournament tournament;

  const TournamentStateLoaded(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() {
    return 'TournamentState { tournament: $tournament }';
  }
}

/// Refreshing is in process
class TournamentStateRefreshing extends TournamentState {
  final String tournamentId;

  const TournamentStateRefreshing(this.tournamentId);

  @override
  List<Object> get props => [tournamentId];

  @override
  String toString() {
    return 'TournamentStateRefreshing { tId: $tournamentId }';
  }
}
