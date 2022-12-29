import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:equatable/equatable.dart';

abstract class TournamentUpdateEvent extends Equatable {
  const TournamentUpdateEvent();

  @override
  List<Object> get props => [];
}

class NewRoundEvent extends TournamentUpdateEvent {
  final Tournament tournament;

  const NewRoundEvent(this.tournament);

  @override
  List<Object> get props => [tournament];
}

class UpdateTournamentInfoEvent extends TournamentUpdateEvent {
  final TournamentInfo tournamentInfo;

  const UpdateTournamentInfoEvent(this.tournamentInfo);

  @override
  List<Object> get props => [tournamentInfo];
}

class UpdateTournamentParticipantEvent extends TournamentUpdateEvent {
  final Tournament tournament;

  const UpdateTournamentParticipantEvent(this.tournament);

  @override
  List<Object> get props => [tournament];
}
