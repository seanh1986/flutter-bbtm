import 'package:bbnaf/models/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentListEvent extends Equatable {
  const TournamentListEvent();

  @override
  List<Object> get props => [];
}

class LoadTournamentLists extends TournamentListEvent {}

class TournamentListUpdated extends TournamentListEvent {
  final List<TournamentInfo> tournaments;

  const TournamentListUpdated(this.tournaments);

  @override
  List<Object> get props => [tournaments];
}
