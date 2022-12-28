import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentListEvent extends Equatable {
  const TournamentListEvent();

  @override
  List<Object> get props => [];
}

class RequestLoadTournamentListEvent extends TournamentListEvent {}

class UpdatedTournamentListEvent extends TournamentListEvent {
  final List<TournamentInfo> tournaments;

  const UpdatedTournamentListEvent(this.tournaments);

  @override
  List<Object> get props => [tournaments];
}
