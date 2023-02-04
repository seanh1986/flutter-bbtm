import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object> get props => [];
}

/// No tournament selected
class NoTournamentState extends TournamentState {}

/// Tournament loaded or updated -> Refresh UI
class NewTournamentState extends TournamentState {
  final Tournament tournament;

  const NewTournamentState(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() {
    return 'TournamentState { tournament: $tournament }';
  }
}
