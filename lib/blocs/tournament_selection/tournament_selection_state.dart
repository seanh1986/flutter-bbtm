import 'package:bbnaf/models/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentSelectionState extends Equatable {
  const TournamentSelectionState();

  @override
  List<Object> get props => [];
}

class NoSelectedTournamentState extends TournamentSelectionState {}

class SelectedTournamentState extends TournamentSelectionState {
  final TournamentInfo tournamentInfo;

  const SelectedTournamentState(this.tournamentInfo);

  @override
  List<Object> get props => [tournamentInfo];

  @override
  String toString() {
    return 'SelectedTournamentState { tournamentInfo: $tournamentInfo }';
  }
}
