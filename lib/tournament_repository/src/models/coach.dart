import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';

class Coach extends IMatchupParticipant {
  late String nafName; // Key

  late String squadName = "";

  late String coachName = "";

  late String teamName = "";

  late int nafNumber;

  late Race race;

  late bool active;

  String rosterFileName = "";

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0;

  int tds = 0;
  int cas = 0;

  int oppTds = 0;
  int oppCas = 0;

  double oppPoints = 0.0;

  int bestSportPoints = 0;

  List<double> bonusPts = <double>[];

  List<double> _tieBreakers = <double>[];

  List<String> _opponents = <String>[];

  List<CoachMatchup> matches = [];

  List<int> ranksPerRound = [];

  bool isCustomStunty = false;

  Coach(String nafName, String squadName, this.coachName, this.race,
      this.teamName, this.nafNumber, this.active,
      {this.isCustomStunty = false}) {
    this.nafName = nafName.trim();
    this.squadName = squadName.trim();
  }

  Coach.from(Coach c)
      : this(c.nafName, c.squadName, c.coachName, c.race, c.teamName,
            c.nafNumber, c.active,
            isCustomStunty: c.isCustomStunty);

  @override
  OrgType type() {
    return OrgType.Coach;
  }

  @override
  String name() {
    return nafName;
  }

  @override
  String parentName() {
    return squadName;
  }

  @override
  double points() {
    return _points;
  }

  @override
  int wins() {
    return _wins;
  }

  @override
  int ties() {
    return _ties;
  }

  @override
  int losses() {
    return _losses;
  }

  @override
  List<double> tiebreakers() {
    return _tieBreakers;
  }

  @override
  List<String> opponents() {
    return _opponents;
  }

  @override
  bool isActive(Tournament t) {
    return active;
  }

// Used for matchups & rankings UI
  @override
  String displayName(TournamentInfo info) {
    switch (info.coachDisplayName) {
      case CoachDisplayName.CoachName:
        return coachName;
      case CoachDisplayName.NafName_Then_CoachName:
        return nafName + " (" + coachName + ")";
      case CoachDisplayName.CoachName_Then_NafName:
        return coachName + " (" + nafName + ")";
      case CoachDisplayName.NafName:
      default:
        return nafName;
    }
  }

  // Search is lower case
  @override
  bool matchSearch(String search) {
    return nafName.toLowerCase().contains(search) ||
        coachName.toLowerCase().contains(search) ||
        raceName().toLowerCase().contains(search) ||
        squadName.toLowerCase().contains(search) ||
        teamName.toLowerCase().contains(search);
  }

  // Returns "" if not valid
  String raceName() {
    return RaceUtils.getName(race);
  }

  bool isStunty() {
    return RaceUtils.isStunty(race) || isCustomStunty;
  }

  void overwriteRecord(TournamentInfo t) {
    _wins = 0;
    _ties = 0;
    _losses = 0;
    _points = 0;
    tds = 0;
    cas = 0;
    oppTds = 0;
    oppCas = 0;
    bestSportPoints = 0;
    _opponents.clear();

    bonusPts.clear();
    t.scoringDetails.bonusPts.forEach((element) {
      bonusPts.add(0);
    });

    matches.forEach((m) {
      ReportedMatchResultWithStatus matchStats = m.getReportedMatchStatus();
      MatchResult matchResult = m.getResult();

      if (m.isHome(nafName)) {
        switch (matchResult) {
          case MatchResult.HomeWon:
            _wins++;
            break;
          case MatchResult.AwayWon:
            _losses++;
            break;
          case MatchResult.Draw:
            _ties++;
            break;
          default:
            break;
        }

        tds += matchStats.homeTds;
        cas += matchStats.homeCas;
        oppTds += matchStats.awayTds;
        oppCas += matchStats.awayCas;

        for (int i = 0; i < matchStats.homeBonusPts.length; i++) {
          bonusPts[i] += matchStats.homeBonusPts[i];
        }

        // Based on opponent's vote
        bestSportPoints += m.awayReportedResults.bestSportOppRank;

        _opponents.add(m.awayNafName);
      } else if (m.isAway(nafName)) {
        switch (matchResult) {
          case MatchResult.HomeWon:
            _losses++;
            break;
          case MatchResult.AwayWon:
            _wins++;
            break;
          case MatchResult.Draw:
            _ties++;
            break;
          default:
            break;
        }

        tds += matchStats.awayTds;
        cas += matchStats.awayCas;
        oppTds += matchStats.homeTds;
        oppCas += matchStats.homeCas;

        for (int i = 0; i < matchStats.awayBonusPts.length; i++) {
          bonusPts[i] += matchStats.awayBonusPts[i];
        }

        // Based on opponent's vote
        bestSportPoints += m.homeReportedResults.bestSportOppRank;

        _opponents.add(m.homeNafName);
      }
    });

    _points = _wins * t.scoringDetails.winPts +
        _ties * t.scoringDetails.tiePts +
        _losses * t.scoringDetails.lossPts;

    // Add bonus points to total points
    List<BonusDetails> bonusDetails = t.scoringDetails.bonusPts;

    for (int i = 0; i < bonusPts.length; i++) {
      double weight = i < bonusDetails.length ? bonusDetails[i].weight : 0.0;
      _points += bonusPts[i] * weight;
    }
  }

  void updateOppScoreAndTieBreakers(Tournament t) {
    oppPoints = 0.0;
    _tieBreakers.clear();

    _opponents.forEach((opp) {
      Coach? oppCoach = t.getCoach(opp);
      if (oppCoach != null) {
        oppPoints += oppCoach.points();
      }
    });

    t.info.scoringDetails.tieBreakers.forEach((tb) {
      switch (tb) {
        case TieBreaker.OppScore:
          _tieBreakers.add(oppPoints);
          break;
        case TieBreaker.Td:
          _tieBreakers.add(tds.toDouble());
          break;
        case TieBreaker.Cas:
          _tieBreakers.add(cas.toDouble());
          break;
        case TieBreaker.SumTdAndCas:
          _tieBreakers.add(tds.toDouble() + cas.toDouble());
          break;
        case TieBreaker.TdDiff:
          _tieBreakers.add(deltaTd().toDouble());
          break;
        case TieBreaker.CasDiff:
          _tieBreakers.add(deltaCas().toDouble());
          break;
        case TieBreaker.SumTdDiffAndCasDiff:
          _tieBreakers.add((deltaTd() + deltaCas()).toDouble());
          break;
        case TieBreaker.SquadScore:
          Squad? squad = t.useSquadRankings() ? t.getCoachSquad(nafName) : null;
          _tieBreakers.add(squad != null ? squad.points() : 0.0);
          break;
        case TieBreaker.NumWins:
          _tieBreakers.add(wins().toDouble());
          break;
        case TieBreaker.NumTies:
          _tieBreakers.add(ties().toDouble());
          break;
      }
    });
  }

  int deltaTd() {
    return tds - oppTds;
  }

  int deltaCas() {
    return cas - oppCas;
  }

  // It is fromRank - curRank because a positive delta means moving "up" the rankings (smaller numbers)
  int? getDeltaRankSinceRound(int roundNumber) {
    int? curRank = getCurrentRank();
    int? fromRank = getRankFrom(roundNumber);

    return curRank != null && fromRank != null ? fromRank - curRank : null;
  }

  int? getRankFrom(int roundNumber) {
    int roundIdx = roundNumber - 1;
    return (roundIdx > 0 && roundIdx < ranksPerRound.length)
        ? ranksPerRound[roundIdx]
        : null;
  }

  int? getCurrentRank() {
    return ranksPerRound.isNotEmpty ? ranksPerRound.last : null;
  }

  Coach.fromJson(int id, Map<String, Object?> json) {
    final tNafName = json['naf_name'] as String?;
    this.nafName = tNafName != null ? tNafName.trim() : "";

    final tCoachName = json['coach_name'] as String?;
    this.coachName = tCoachName != null ? tCoachName.trim() : "";

    final tTeamName = json['team_name'] as String?;
    this.teamName = tTeamName != null ? tTeamName.trim() : "";

    final tSquadName = json['squad_name'] as String?;
    this.squadName = tSquadName != null ? tSquadName.trim() : "";

    final tRace = json['race'] as String?;
    this.race = tRace != null ? RaceUtils.getRace(tRace) : Race.Unknown;

    final tNafNumber = json['naf_number'] as int?;
    this.nafNumber = tNafNumber != null ? tNafNumber : -1;

    final tActive = json['active'] as bool?;
    this.active = tActive != null && tActive;

    final tCustomStunty = json['is_custom_stunty'] as bool?;
    this.isCustomStunty = tCustomStunty != null && tCustomStunty;

    final tRoster = json['roster'] as String?;
    this.rosterFileName = tRoster != null ? tRoster.trim() : "";
  }

  Map<String, dynamic> toJson() => {
        'naf_name': nafName,
        'coach_name': coachName,
        'team_name': teamName,
        'squad_name': squadName,
        'race': RaceUtils.getName(race),
        'naf_number': nafNumber,
        'active': active,
        'is_custom_stunty': isCustomStunty,
        'roster': rosterFileName,
      };
}
