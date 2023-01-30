import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:equatable/equatable.dart';

abstract class MatchReportState extends Equatable {
  const MatchReportState();

  @override
  List<Object> get props => [];
}

class AppLaunchMatchReportState extends MatchReportState {}

class UpdatedMatchReportState extends MatchReportState {
  final CoachMatchup matchup;

  UpdatedMatchReportState(this.matchup);

  @override
  List<Object> get props => [matchup];

  @override
  String toString() => 'UpdatedMatchReportState { matchup: $matchup }';
}

class FailedToUpdateMatchReportState extends MatchReportState {
  final CoachMatchup matchup;

  FailedToUpdateMatchReportState(this.matchup);

  @override
  List<Object> get props => [matchup];

  @override
  String toString() => 'FailedToUpdateMatchReportState { matchup: $matchup }';
}
