import 'package:bbnaf/models/tournament/tournament_info.dart';

class ReportedMatchResult {
  bool reported = false;

  int homeTds = 0;
  int awayTds = 0;

  int homeCas = 0;
  int awayCas = 0;

  List<int> homeBonusPts = [];
  List<int> awayBonusPts = [];

  // What they ranked their opponent, from 1 to 5
  int bestSportOppRank = 3;

  ReportedMatchResult();
  ReportedMatchResult.from(ReportedMatchResult r) {
    this.reported = r.reported;
    this.homeTds = r.homeTds;
    this.homeCas = r.homeCas;
    this.awayTds = r.awayTds;
    this.awayCas = r.awayCas;
    this.homeBonusPts = r.homeBonusPts;
    this.awayBonusPts = r.awayBonusPts;
    this.bestSportOppRank = r.bestSportOppRank;
  }

  ReportedMatchResult.fromJson(Map<String, dynamic> json, TournamentInfo info) {
    final tReported = json['reported'] as bool?;
    this.reported = tReported != null ? tReported : false;

    final tHomeTd = json['home_td'] as int?;
    this.homeTds = tHomeTd != null ? tHomeTd : 0;

    final tHomeCas = json['home_cas'] as int?;
    this.homeCas = tHomeCas != null ? tHomeCas : 0;

    final tAwayTd = json['away_td'] as int?;
    this.awayTds = tAwayTd != null ? tAwayTd : 0;

    final tAwayCas = json['away_cas'] as int?;
    this.awayCas = tAwayCas != null ? tAwayCas : 0;

    int numBonuses = info.scoringDetails.bonusPts.length;

    final tHomeBonusPts = json['home_bonus_pts'] as List<dynamic>?;
    if (tHomeBonusPts != null && numBonuses == tHomeBonusPts.length) {
      tHomeBonusPts.forEach((element) {
        homeBonusPts.add(element as int);
      });
    } else {
      info.scoringDetails.bonusPts.forEach((element) {
        homeBonusPts.add(0);
      });
    }

    final tAwayBonusPts = json['away_bonus_pts'] as List<dynamic>?;
    if (tAwayBonusPts != null && numBonuses == tAwayBonusPts.length) {
      tAwayBonusPts.forEach((element) {
        awayBonusPts.add(element as int);
      });
    } else {
      info.scoringDetails.bonusPts.forEach((element) {
        awayBonusPts.add(0);
      });
    }

    final tOppBestSport = json['opp_best_sport_rank'] as int?;
    this.bestSportOppRank = tOppBestSport != null ? tOppBestSport : 3;
  }

  Map<String, dynamic> toJson() => {
        'reported': reported,
        'home_td': homeTds,
        'home_cas': homeCas,
        'away_td': awayTds,
        'away_cas': awayCas,
        'home_bonus_pts': homeBonusPts,
        'away_bonus_pts': awayBonusPts,
        'opp_best_sport_rank': bestSportOppRank,
      };
}
