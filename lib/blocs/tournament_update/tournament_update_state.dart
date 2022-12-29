import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentUpdateState extends Equatable {
  const TournamentUpdateState();

  @override
  List<Object> get props => [];
}

class NoTournamentState extends TournamentUpdateState {
  const NoTournamentState();

  @override
  List<Object> get props => [];

  @override
  String toString() {
    return 'NoTournamentState { }';
  }
}

class NewRoundState extends TournamentUpdateState {
  final Tournament tournament;

  const NewRoundState(this.tournament);

  @override
  List<Object> get props => [tournament];

  @override
  String toString() {
    return 'NewRoundState { tournament: $tournament }';
  }
}
