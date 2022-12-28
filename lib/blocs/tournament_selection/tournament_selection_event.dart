import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentSelectionEvent extends Equatable {
  const TournamentSelectionEvent();

  @override
  List<Object> get props => [];
}

class LoadingTournamentEvent extends TournamentSelectionEvent {
  final TournamentInfo tournamentInfo;

  const LoadingTournamentEvent(this.tournamentInfo);

  @override
  List<Object> get props => [tournamentInfo];
}

class SelectedTournamentEvent extends TournamentSelectionEvent {
  final TournamentInfo tournamentInfo;
  final Tournament tournament;

  const SelectedTournamentEvent(this.tournamentInfo, this.tournament);

  @override
  List<Object> get props => [tournamentInfo, tournament];
}

class DeselectedTournamentEvent extends TournamentSelectionEvent {}
