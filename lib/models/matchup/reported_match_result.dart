class ReportedMatchResult {
  bool reported = false;

  int homeTds = 0;
  int awayTds = 0;

  int homeCas = 0;
  int awayCas = 0;

  List<int> bonusPts = [];

  // What they ranked their opponent, from 1 to 5
  int bestSportOppRank = 3;

  ReportedMatchResult();
  ReportedMatchResult.from(ReportedMatchResult r) {
    this.reported = r.reported;
    this.homeTds = r.homeTds;
    this.homeCas = r.homeCas;
    this.awayTds = r.awayTds;
    this.awayCas = r.awayCas;
    this.bestSportOppRank = r.bestSportOppRank;
  }

  ReportedMatchResult.fromJson(Map<String, dynamic> json) {
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

    final tBonusPts = json['bonus_pts'] as List<dynamic>?;
    if (tBonusPts != null) {
      bonusPts.clear();
      tBonusPts.forEach((element) {
        bonusPts.add(element);
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
        'bonus_pts': bonusPts,
        'opp_best_sport_rank': bestSportOppRank,
      };
}
