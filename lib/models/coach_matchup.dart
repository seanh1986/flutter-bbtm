import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class CoachMatchup extends IMatchup {
  late final int _roundNum;
  late int _tableNum;

  late final String homeNafName;
  int homeTds = 0;
  int homeCas = 0;

  late final String awayNafName;
  int awayTds = 0;
  int awayCas = 0;

  CoachMatchup(
      this._roundNum, this._tableNum, this.homeNafName, this.awayNafName);

  @override
  OrgType type() {
    return OrgType.Coach;
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
  String homeName() {
    return homeNafName;
  }

  @override
  String awayName() {
    return awayNafName;
  }

  @override
  IMatchupParticipant home(Tournament t) {
    return t.getCoach(homeNafName)!;
  }

  @override
  IMatchupParticipant away(Tournament t) {
    return t.getCoach(awayNafName)!;
  }

  bool hasPlayer(String nafName) {
    return homeNafName == nafName || awayNafName == nafName;
  }

  CoachMatchup.fromJson(Map<String, Object?> json) {
    final tRound = json['round'] as int?;
    this._roundNum = tRound != null ? tRound : 0;

    final tTable = json['table'] as int?;
    this._tableNum = tTable != null ? tTable : -1;

    final tResult = json['result'] as String?;
    this.result = IMatchup.parseResult(tResult != null ? tResult : "");

    final tHomeNafName = json['home_nafname'] as String?;
    this.homeNafName = tHomeNafName != null ? tHomeNafName : "";

    final tHomeTd = json['home_td'] as int?;
    this.homeTds = tHomeTd != null ? tHomeTd : 0;

    final tHomeCas = json['home_cas'] as int?;
    this.homeCas = tHomeCas != null ? tHomeCas : 0;

    final tAwayNafName = json['away_nafname'] as String?;
    this.awayNafName = tAwayNafName != null ? tAwayNafName : "";

    final tAwayTd = json['away_td'] as int?;
    this.awayTds = tAwayTd != null ? tAwayTd : 0;

    final tAwayCas = json['away_cas'] as int?;
    this.awayCas = tAwayCas != null ? tAwayCas : 0;
  }

  Map toJson() => {
        'round': _roundNum,
        'table': _tableNum,
        'result': IMatchup.getResultName(result),
        'home_nafname': homeNafName,
        'home_td': homeTds,
        'home_cas': homeCas,
        'away_nafname': awayNafName,
        'away_td': awayTds,
        'away_cas': awayCas,
      };
}
