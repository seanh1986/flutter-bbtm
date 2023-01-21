import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class MatchReportEvent extends Equatable {
  MatchReportEvent();

  @override
  List<Object> get props => [];
}

class AppStartMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'AppStartMatchReportEvent';
}

class UpdateMatchReportEvent extends MatchReportEvent {
  Tournament tournament;
  CoachMatchup matchup;
  bool isHome = true;
  bool isAdmin = false;

  UpdateMatchReportEvent(this.tournament, this.matchup, this.isHome);

  UpdateMatchReportEvent.admin(this.tournament, this.matchup) {
    this.isAdmin = true;
  }

  @override
  String toString() => 'UpdateMatchReportEvent';
}
