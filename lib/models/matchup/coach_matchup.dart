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
  static const String Bye = "bye";

  int tableNum = -1;

  late final String homeNafName;
  ReportedMatchResult homeReportedResults = ReportedMatchResult();

  late final String awayNafName;
  ReportedMatchResult awayReportedResults = ReportedMatchResult();

  CoachMatchup(this.homeNafName, this.awayNafName);

  @override
  OrgType type() {
    return OrgType.Coach;
  }

  // @override
  // int tableNum() {
  //   return _tableNum;
  // }

  // void setTableNum(int t) {
  //   tableNum = t;
  // }

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

  MatchResult getResult() {
    if (homeReportedResults.reported && awayReportedResults.reported) {
      if (homeReportedResults.homeTds == awayReportedResults.homeTds &&
          homeReportedResults.awayTds == awayReportedResults.awayTds &&
          homeReportedResults.homeCas == awayReportedResults.homeCas &&
          homeReportedResults.awayCas == awayReportedResults.awayCas) {
        return _getMatchResult(homeReportedResults);
      } else {
        return MatchResult.Conflict;
      }
    } else if (homeReportedResults.reported) {
      return _getMatchResult(homeReportedResults);
    } else if (awayReportedResults.reported) {
      return _getMatchResult(awayReportedResults);
    } else {
      return MatchResult.NoResult;
    }
  }

  MatchResult _getMatchResult(ReportedMatchResult r) {
    if (r.homeTds > r.awayTds) {
      return MatchResult.HomeWon;
    } else if (r.homeTds < r.awayTds) {
      return MatchResult.AwayWon;
    } else {
      return MatchResult.Draw;
    }
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

  bool isHome(String? nafName) {
    return nafName != null &&
        homeNafName.toLowerCase() == nafName.toLowerCase();
  }

  bool isAway(String? nafName) {
    return nafName != null &&
        awayNafName.toLowerCase() == nafName.toLowerCase();
  }

  bool hasPlayer(String nafName) {
    return isHome(nafName) || isAway(nafName);
  }

  CoachMatchup.fromJson(Map<String, dynamic> json) {
    final tTable = json['table'] as int?;
    this.tableNum = tTable != null ? tTable : -1;

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
        'table': tableNum,
        'home_nafname': homeNafName,
        'away_nafname': awayNafName,
        'home_reported_results': homeReportedResults.toJson(),
        'away_reported_results': awayReportedResults.toJson(),
      };
}
