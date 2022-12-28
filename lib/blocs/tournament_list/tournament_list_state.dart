import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentListState extends Equatable {
  const TournamentListState();

  @override
  List<Object> get props => [];
}

class TournamentListLoading extends TournamentListState {}

class TournamentListLoaded extends TournamentListState {
  final List<TournamentInfo> tournaments;

  const TournamentListLoaded([this.tournaments = const []]);

  @override
  List<Object> get props => [tournaments];

  @override
  String toString() {
    return 'TournamentListLoaded { tournamentInfos: $tournaments }';
  }
}

class TournamentListNotLoaded extends TournamentListState {}
