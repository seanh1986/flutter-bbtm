import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

enum ReportedMatchStatus {
  NoReportsYet,
  HomeReported,
  AwayReported,
  BothReportedConflict,
  BothReportedAgree,
}

class ReportedMatchResultWithStatus extends ReportedMatchResult {
  ReportedMatchStatus status = ReportedMatchStatus.NoReportsYet;
  ReportedMatchResultWithStatus();
  ReportedMatchResultWithStatus.from(
      ReportedMatchStatus s, ReportedMatchResult r)
      : super.from(r) {
    this.status = s;
  }
}

class CoachMatchup extends IMatchup {
  late final int _roundNum;
  late int _tableNum;

  late final String homeNafName;
  ReportedMatchResult homeReportedResults = ReportedMatchResult();

  late final String awayNafName;
  ReportedMatchResult awayReportedResults = ReportedMatchResult();

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

  ReportedMatchResultWithStatus getReportedMatchStatus() {
    bool homeReported = homeReportedResults.reported;
    bool awayReported = awayReportedResults.reported;

    if (!homeReported && !awayReported) {
      return ReportedMatchResultWithStatus();
    } else if (homeReported && awayReported) {
      bool sameHomeTds =
          homeReportedResults.homeTds == awayReportedResults.homeTds;
      bool sameAwayTds =
          homeReportedResults.awayTds == awayReportedResults.awayTds;
      bool sameHomeCas =
          homeReportedResults.homeCas == awayReportedResults.homeCas;
      bool sameAwayCas =
          homeReportedResults.awayCas == awayReportedResults.awayCas;

      if (sameHomeTds && sameAwayTds && sameHomeCas && sameAwayCas) {
        return ReportedMatchResultWithStatus.from(
            ReportedMatchStatus.BothReportedAgree, homeReportedResults);
      } else {
        return ReportedMatchResultWithStatus.from(
            ReportedMatchStatus.BothReportedConflict, homeReportedResults);
      }
    } else if (homeReported) {
      return ReportedMatchResultWithStatus.from(
          ReportedMatchStatus.HomeReported, homeReportedResults);
    } else if (awayReported) {
      return ReportedMatchResultWithStatus.from(
          ReportedMatchStatus.AwayReported, awayReportedResults);
    } else {
      return ReportedMatchResultWithStatus();
    }
  }

  bool hasPlayer(String nafName) {
    return homeNafName == nafName || awayNafName == nafName;
  }

  CoachMatchup.fromJson(Map<String, dynamic> json) {
    final tRound = json['round'] as int?;
    this._roundNum = tRound != null ? tRound : 0;

    final tTable = json['table'] as int?;
    this._tableNum = tTable != null ? tTable : -1;

    final tResult = json['result'] as String?;
    this.result = IMatchup.parseResult(tResult != null ? tResult : "");

    final tHomeNafName = json['home_nafname'] as String?;
    this.homeNafName = tHomeNafName != null ? tHomeNafName : "";

    final tAwayNafName = json['away_nafname'] as String?;
    this.awayNafName = tAwayNafName != null ? tAwayNafName : "";

    final tHomeReportedResults =
        json['home_reported_results'] as Map<String, dynamic>?;
    if (tHomeReportedResults != null) {
      homeReportedResults = ReportedMatchResult.fromJson(tHomeReportedResults);
    }

    final tAwayReportedResults =
        json['away_reported_results'] as Map<String, dynamic>?;
    if (tAwayReportedResults != null) {
      awayReportedResults = ReportedMatchResult.fromJson(tAwayReportedResults);
    }
  }

  Map<String, dynamic> toJson() => {
        'round': _roundNum,
        'table': _tableNum,
        'result': IMatchup.getResultName(result),
        'home_nafname': homeNafName,
        'away_nafname': awayNafName,
        'home_reported_results': homeReportedResults.toJson(),
        'away_reported_results': awayReportedResults.toJson(),
      };
}
