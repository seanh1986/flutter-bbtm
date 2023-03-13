import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class SquadMatchup extends IMatchup {
  late int _tableNum;

  late final String homeSquadName;
  late final String awaySquadName;

  List<CoachMatchup> coachMatchups = [];

  SquadMatchup(this._tableNum, this.homeSquadName, this.awaySquadName);

  @override
  OrgType type() {
    return OrgType.Squad;
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

  @override
  MatchResult getResult() {
    return MatchResult.NoResult;
  }

  bool hasSquad(String squadName) {
    return homeSquadName == squadName || awaySquadName == squadName;
  }

  SquadMatchup.fromJson(Map<String, dynamic> json) {
    final tTable = json['table'] as int?;
    this._tableNum = tTable != null ? tTable : -1;

    final tHomeName = json['home_name'] as String?;
    this.homeSquadName = tHomeName != null ? tHomeName : "";

    final tAwayName = json['away_name'] as String?;
    this.awaySquadName = tAwayName != null ? tAwayName : "";

    // TODO: Coach Matchups! (maybe use index only?)
  }

  Map<String, dynamic> toJson() => {
        'table': _tableNum,
        'home_name': homeSquadName,
        'away_name': awaySquadName,
      };
}
