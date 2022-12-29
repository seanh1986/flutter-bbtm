import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class SquadMatchup extends IMatchup {
  late final int _roundNum;
  late int _tableNum;

  late final String homeSquadName;
  late final String awaySquadName;

  List<CoachMatchup> coachMatchups = [];

  SquadMatchup(
      this._roundNum, this._tableNum, this.homeSquadName, this.awaySquadName);

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

  void updateTableNum(int tableNum) {
    _tableNum = tableNum;
  }

  @override
  String homeName() {
    return homeSquadName;
  }

  @override
  String awayName() {
    return awaySquadName;
  }

  @override
  IMatchupParticipant home(Tournament t) {
    return t.getSquad(homeSquadName)!;
  }

  @override
  IMatchupParticipant away(Tournament t) {
    return t.getSquad(awaySquadName)!;
  }

  bool hasSquad(String squadName) {
    return homeSquadName == squadName || awaySquadName == squadName;
  }

  SquadMatchup.fromJson(Map<String, Object?> json) {
    final tRound = json['round'] as int?;
    this._roundNum = tRound != null ? tRound : 0;

    final tTable = json['table'] as int?;
    this._tableNum = tTable != null ? tTable : -1;

    final tResult = json['result'] as String?;
    this.result = IMatchup.parseResult(tResult != null ? tResult : "");

    final tHomeName = json['home_name'] as String?;
    this.homeSquadName = tHomeName != null ? tHomeName : "";

    final tAwayName = json['away_name'] as String?;
    this.awaySquadName = tAwayName != null ? tAwayName : "";

    // TODO: Coach Matchups! (maybe use index only?)
  }

  Map toJson() => {
        'round': _roundNum,
        'table': _tableNum,
        'result': IMatchup.getResultName(result),
        'home_name': homeSquadName,
        'away_name': awaySquadName,
      };
}
