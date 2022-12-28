import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentSelectionState extends Equatable {
  const TournamentSelectionState();

  @override
  List<Object> get props => [];
}

class NoSelectedTournamentState extends TournamentSelectionState {}

class SelectedTournamentState extends TournamentSelectionState {
  final TournamentInfo tournamentInfo;
  final Tournament tournament;

  const SelectedTournamentState(this.tournamentInfo, this.tournament);

  @override
  List<Object> get props => [tournamentInfo, tournament];

  @override
  String toString() {
    return 'SelectedTournamentState { tournamentInfo: $tournamentInfo, tournament: $tournament }';
  }
}
