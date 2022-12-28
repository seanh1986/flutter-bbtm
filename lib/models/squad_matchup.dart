import 'dart:collection';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/i_matchup.dart';

class SquadMatchup extends IMatchup {
  late final int _roundNum;
  late final int _tableNum;

  late final Squad homeSquad;
  late final Squad awaySquad;

  List<CoachMatchup> coachMatchups = [];

  SquadMatchup(this._roundNum, this._tableNum, this.homeSquad, this.awaySquad);

  @override
  OrgType type() {
    return OrgType.Squad;
  }

  @override
  int roundNum() {
    return _roundNum;
  }

  @override
  int tableNum() {
    return _tableNum;
  }

  @override
  IMatchupParticipant home() {
    return homeSquad;
  }

  @override
  IMatchupParticipant away() {
    return awaySquad;
  }

  bool hasSquad(String squadName) {
    return homeSquad.name() == squadName || awaySquad.name() == squadName;
  }
}
