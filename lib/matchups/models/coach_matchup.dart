import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';

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

  late String homeNafName;
  ReportedMatchResult homeReportedResults = ReportedMatchResult();

  late String awayNafName;
  ReportedMatchResult awayReportedResults = ReportedMatchResult();

  CoachMatchup(this.homeNafName, this.awayNafName);
  CoachMatchup.from(CoachMatchup m)
      : tableNum = m.tableNum,
        homeNafName = m.homeNafName,
        homeReportedResults = ReportedMatchResult.from(m.homeReportedResults),
        awayNafName = m.awayNafName,
        awayReportedResults = ReportedMatchResult.from(m.awayReportedResults);

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

  @override
  bool matchSearch(String search) {
    return homeNafName.toLowerCase().contains(search) ||
        awayNafName.toLowerCase().contains(search);
  }

  MatchResult getResult() {
    if (homeReportedResults.reported && awayReportedResults.reported) {
      if (_areResultsSame()) {
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
      if (_areResultsSame()) {
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

  bool _areResultsSame() {
    bool sameHomeTds =
        homeReportedResults.homeTds == awayReportedResults.homeTds;
    bool sameAwayTds =
        homeReportedResults.awayTds == awayReportedResults.awayTds;
    bool sameHomeCas =
        homeReportedResults.homeCas == awayReportedResults.homeCas;
    bool sameAwayCas =
        homeReportedResults.awayCas == awayReportedResults.awayCas;

    bool sameHomeBonus = homeReportedResults.homeBonusPts.length ==
        awayReportedResults.homeBonusPts.length;
    if (sameHomeBonus) {
      for (int i = 0; i < homeReportedResults.homeBonusPts.length; i++) {
        sameHomeBonus &= homeReportedResults.homeBonusPts[i] ==
            awayReportedResults.homeBonusPts[i];
      }
    }

    bool sameAwayBonus = homeReportedResults.awayBonusPts.length ==
        awayReportedResults.awayBonusPts.length;
    if (sameAwayBonus) {
      for (int i = 0; i < homeReportedResults.awayBonusPts.length; i++) {
        sameAwayBonus &= homeReportedResults.awayBonusPts[i] ==
            awayReportedResults.awayBonusPts[i];
      }
    }

    bool allSame = sameHomeTds &&
        sameAwayTds &&
        sameHomeCas &&
        sameAwayCas &&
        sameHomeBonus &&
        sameAwayBonus;

    return allSame;
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

  CoachMatchup.fromJson(Map<String, dynamic> json, TournamentInfo info) {
    final tTable = json['table'] as int?;
    this.tableNum = tTable != null ? tTable : -1;

    final tHomeNafName = json['home_nafname'] as String?;
    this.homeNafName = tHomeNafName != null ? tHomeNafName.trim() : "";

    final tAwayNafName = json['away_nafname'] as String?;
    this.awayNafName = tAwayNafName != null ? tAwayNafName.trim() : "";

    final tHomeReportedResults =
        json['home_reported_results'] as Map<String, dynamic>?;
    if (tHomeReportedResults != null) {
      homeReportedResults =
          ReportedMatchResult.fromJson(tHomeReportedResults, info);
    }

    final tAwayReportedResults =
        json['away_reported_results'] as Map<String, dynamic>?;
    if (tAwayReportedResults != null) {
      awayReportedResults =
          ReportedMatchResult.fromJson(tAwayReportedResults, info);
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
