import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

class Coach extends IMatchupParticipant {
  late String nafName; // Key

  late String squadName;

  late String coachName;

  late String teamName;

  late int nafNumber;

  late Race _race;

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

  List<double> _tieBreakers = <double>[];

  List<String> _opponents = <String>[];

  List<CoachMatchup> matches = [];

  Coach(
    this.nafName,
    this.squadName,
    this.coachName,
    this._race,
    this.teamName,
    this.nafNumber,
  ) {
    active = nafName.isNotEmpty;
  }

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
  Race race() {
    return _race;
  }

  @override
  double points() {
    return _points;
  }

  // Approximate
  double pointsWithTieBreakersBuiltIn() {
    // Shift by mStep after each tiebreaker
    int mStep = 100;
    int m = 1;

    double ptsWithT = 0.0;

    // Reverse order for tiebreakers
    for (int i = _tieBreakers.length - 1; i >= 0; i--) {
      double tbPts = _tieBreakers[i];
      ptsWithT += tbPts * m;
      m *= mStep;
    }

    m *= 10; // Extra Buffer
    ptsWithT += _points * m;

    // StringBuffer sb = new StringBuffer();
    // sb.write(name() + ": " + points().toString() + " -> [");
    // tiebreakers().forEach((tb) {
    //   sb.write(tb.toString() + ",");
    // });
    // sb.write("] -> ");
    // sb.write(ptsWithT.toDouble());
    // print(sb.toString());

    return ptsWithT;
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

  void setRace(Race r) {
    this._race = r;
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

        // Based on opponent's vote
        bestSportPoints += m.homeReportedResults.bestSportOppRank;

        _opponents.add(m.homeNafName);
      }
    });

    _points = _wins * t.scoringDetails.winPts +
        _ties * t.scoringDetails.tiePts +
        _losses * t.scoringDetails.lossPts;
  }

  void updateOppScoreAndTieBreakers(Tournament t) {
    oppPoints = 0.0;
    _opponents.forEach((opp) {
      Coach? oppCoach = t.getCoach(opp);
      if (oppCoach != null) {
        oppPoints += oppCoach.points();
      }
    });

    t.tieBreakers.forEach((tb) {
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
        case TieBreaker.TdDiff:
          _tieBreakers.add((tds - oppTds).toDouble());
          break;
        case TieBreaker.CasDiff:
          _tieBreakers.add((cas - oppCas).toDouble());
          break;
      }
    });
  }

  Coach.fromJson(int id, Map<String, Object?> json) {
    final tNafName = json['naf_name'] as String?;
    this.nafName = tNafName != null ? tNafName : "";

    final tCoachName = json['coach_name'] as String?;
    this.coachName = tCoachName != null ? tCoachName : "";

    final tTeamName = json['team_name'] as String?;
    this.teamName = tTeamName != null ? tTeamName : "";

    final tSquadName = json['squad_name'] as String?;
    this.squadName = tSquadName != null ? tSquadName : "";

    final tRace = json['race'] as String?;
    this._race = tRace != null ? RaceUtils.getRace(tRace) : Race.Unknown;

    final tNafNumber = json['naf_number'] as int?;
    this.nafNumber = tNafNumber != null ? tNafNumber : -1;

    final tActive = json['active'] as bool?;
    this.active = tActive != null && tActive;

    final tRoster = json['roster'] as String?;
    this.rosterFileName = tRoster != null ? tRoster : "";
  }

  Map<String, dynamic> toJson() => {
        'naf_name': nafName,
        'coach_name': coachName,
        'team_name': teamName,
        'squad_name': squadName,
        'race': RaceUtils.getName(_race),
        'naf_number': nafNumber,
        'active': active,
        'roster': rosterFileName,
      };
}
