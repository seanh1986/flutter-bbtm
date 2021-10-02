import 'package:bbnaf/models/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentSelectionEvent extends Equatable {
  const TournamentSelectionEvent();

  @override
  List<Object> get props => [];
}

class SelectedTournamentEvent extends TournamentSelectionEvent {
  final TournamentInfo tournamentInfo;

  const SelectedTournamentEvent(this.tournamentInfo);

  @override
  List<Object> get props => [tournamentInfo];
}

class DeselectedTournamentEvent extends TournamentSelectionEvent {}
