import 'dart:collection';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:collection/collection.dart';

class Squad extends IMatchupParticipant {
  late final String _name; // Key

  List<String> _coaches = []; // nafNames

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0.0;

  double oppPoints = 0.0;

  List<double> _tieBreakers = <double>[];

  List<SquadOpponent> _opponents = <SquadOpponent>[];

  Squad(this._name, this._coaches);

  @override
  OrgType type() {
    return OrgType.Squad;
  }

  @override
  String name() {
    return _name;
  }

  @override
  String parentName() {
    return "";
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
    return _opponents.map((e) {
      return e.squads.isNotEmpty ? e.squads.first : "";
    }).toList();
  }

  @override
  bool isActive(Tournament t) {
    int numActiveCoaches = getNumActiveCoaches(t);

    int requiredNumCoachesPerSquad =
        t.info.squadDetails.requiredNumCoachesPerSquad;

    return numActiveCoaches == requiredNumCoachesPerSquad;
  }

  int getNumActiveCoaches(Tournament t) {
    return _coaches.where((nafName) {
      Coach? c = t.getCoach(nafName);
      return c != null && c.active;
    }).length;
  }

  bool hasCoach(String nafName) {
    String nafNameLc = nafName.toLowerCase();
    return _coaches
        .where((element) => element.toLowerCase() == nafNameLc)
        .isNotEmpty;
  }

  List<String> getCoaches() {
    return _coaches;
  }

  void overwriteRecord(Tournament t) {
    _wins = 0;
    _ties = 0;
    _losses = 0;
    _points = 0;
    _opponents.clear();

    int numExpectedMatches = t.info.squadDetails.requiredNumCoachesPerSquad;

    t.coachRounds.forEach((cr) {
      int numCoachWins = 0;
      int numCoachTies = 0;
      int numCoachLosses = 0;

      // In classic squad matchups this will be size 1
      HashSet<String> roundOppSquads = HashSet();

      cr.matches.forEach((m) {
        if (hasCoach(m.homeNafName)) {
          Squad? otherSquad = t.getCoachSquad(m.awayNafName);
          if (otherSquad != null) {
            roundOppSquads.add(otherSquad.name());
          }

          MatchResult matchResult = m.getResult();
          switch (matchResult) {
            case MatchResult.HomeWon:
              numCoachWins++;
              break;
            case MatchResult.AwayWon:
              numCoachLosses++;
              break;
            case MatchResult.Draw:
              numCoachTies++;
              break;
            default:
              break;
          }
        } else if (hasCoach(m.awayNafName)) {
          Squad? otherSquad = t.getCoachSquad(m.homeNafName);
          if (otherSquad != null) {
            roundOppSquads.add(otherSquad.name());
          }

          MatchResult matchResult = m.getResult();
          switch (matchResult) {
            case MatchResult.HomeWon:
              numCoachLosses++;
              break;
            case MatchResult.AwayWon:
              numCoachWins++;
              break;
            case MatchResult.Draw:
              numCoachTies++;
              break;
            default:
              break;
          }
        }
      });

      // Update opponents
      _opponents.add(SquadOpponent(roundOppSquads));

      int numMatchesPlayed = numCoachWins + numCoachTies + numCoachLosses;

      // Don't count uncompleted rounds
      if (numMatchesPlayed >= numExpectedMatches) {
        double roundWinRate = (numCoachWins + numCoachTies * 0.5) /
            (numCoachWins + numCoachTies + numCoachLosses);

        if (roundWinRate > 0.5) {
          _wins++;
        } else if (roundWinRate < 0.5) {
          _losses++;
        } else {
          _ties++;
        }
      }
    });

    _points = calcPoints(t);
  }

  double calcPoints(Tournament t) {
    switch (t.info.squadDetails.scoringType) {
      case SquadScoring.SQUAD_RESULT_W_T_L:
        return _calcPoints(t.info.squadDetails.scoringDetails);
      case SquadScoring.CUMULATIVE_PLAYER_SCORES:
      default:
        return _calcPointsCumulativePlayerScores(t);
    }
  }

  double _calcPointsCumulativePlayerScores(Tournament t) {
    double pts = 0.0;

    for (String nafName in _coaches) {
      Coach? c = t.getCoach(nafName);

      pts += c != null ? c.points() : 0.0;
    }

    return pts;
  }

  double _calcPoints(ScoringDetails details) {
    return _wins * details.winPts +
        _ties * details.tiePts +
        _losses * details.lossPts;
  }

  void updateOppScoreAndTieBreakers(Tournament t) {
    oppPoints = 0.0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      if (c != null) {
        oppPoints += c.oppPoints;
      }
    });

    t.info.squadDetails.squadTieBreakers.forEach((tb) {
      switch (tb) {
        case SquadTieBreakers.OppScore:
          _tieBreakers.add(oppPoints);
          break;
        case SquadTieBreakers.SquadWins:
          _tieBreakers.add(_wins.toDouble());
          break;
        case SquadTieBreakers.SumSquadMemberScore:
          _tieBreakers.add(_coaches.map((nafName) {
            Coach? c = t.getCoach(nafName);
            return c != null ? c.points() : 0.0;
          }).sum);
          break;
        case SquadTieBreakers.SumTdDiff:
          _tieBreakers.add(_coaches.map((nafName) {
            Coach? c = t.getCoach(nafName);
            return c != null ? (c.tds - c.oppTds).toDouble() : 0.0;
          }).sum);
          break;
        case SquadTieBreakers.SumCasDiff:
          _tieBreakers.add(_coaches.map((nafName) {
            Coach? c = t.getCoach(nafName);
            return c != null ? (c.cas - c.oppCas).toDouble() : 0.0;
          }).sum);
          break;
      }
    });
  }

  double sumIndividualScores(Tournament t) {
    double sumScore = 0.0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumScore += c != null ? c.points() : 0.0;
    });

    return sumScore;
  }

  int sumTds(Tournament t) {
    int sumTds = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumTds += c != null ? c.tds : 0;
    });

    return sumTds;
  }

  int sumCas(Tournament t) {
    int sumCas = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumCas += c != null ? c.cas : 0;
    });

    return sumCas;
  }

  int sumOppTds(Tournament t) {
    int sumOppTds = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumOppTds += c != null ? c.oppTds : 0;
    });

    return sumOppTds;
  }

  int sumOppCas(Tournament t) {
    int sumOppCas = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumOppCas += c != null ? c.oppCas : 0;
    });

    return sumOppCas;
  }

  int sumDeltaTds(Tournament t) {
    int sumDeltaTds = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumDeltaTds += c != null ? c.deltaTd() : 0;
    });

    return sumDeltaTds;
  }

  int sumDeltaCas(Tournament t) {
    int sumDeltaCas = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumDeltaCas += c != null ? c.deltaCas() : 0;
    });

    return sumDeltaCas;
  }

  Squad.fromJson(Map<String, Object?> json) {
    final tName = json['name'] as String?;
    this._name = tName != null ? tName : "";

    final tCoaches = json['coaches'] as List<String>?;
    this._coaches = tCoaches != null ? tCoaches : [];
  }

  Map toJson() => {
        'name': _name,
        'coaches': _coaches,
      };
}

class SquadOpponent {
  HashSet<String> squads;
  SquadOpponent(this.squads);

  bool isSingleSquad() {
    return squads.length == 1;
  }

  bool isMixedSquad() {
    return squads.length > 1;
  }

  String name() {
    return isSingleSquad() ? squads.first : "Mixed Squad";
  }
}
