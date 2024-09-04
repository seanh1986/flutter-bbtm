import 'dart:collection';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:collection/collection.dart';

class Squad extends IMatchupParticipant {
  late final String _name; // Key

  List<String> _coaches = []; // nafNames

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0.0;

  double oppPoints = 0.0;

  double oppCoachPoints = 0.0;

  List<double> _bonusPts = <double>[];

  List<double> _tieBreakers = <double>[];

  List<SquadOpponent> _opponents = <SquadOpponent>[];

  Squad(String name, List<String> coaches) {
    this._name = name.trim();
    this._coaches = coaches.map((e) => e.trim()).toList();
  }

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

  // Used for matchups & rankings UI
  @override
  String displayName(TournamentInfo info) {
    return name();
  }

// Search is lower case
  @override
  bool matchSearch(String search) {
    return _name.toLowerCase().contains(search) ||
        _coaches.any((c) => c.toLowerCase().contains(search));
  }

  int getNumActiveCoaches(Tournament t) {
    return _coaches.where((nafName) {
      Coach? c = t.getCoach(nafName);
      return c != null && c.active;
    }).length;
  }

  bool hasCoach(String nafName) {
    String nafNameLc = nafName.toLowerCase().trim();
    return _coaches
        .where((element) => element.toLowerCase() == nafNameLc)
        .isNotEmpty;
  }

  List<String> getCoaches() {
    return _coaches;
  }

  String getCoachesLabel() {
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < _coaches.length; i++) {
      sb.write(_coaches[i]);

      if (i + 1 < _coaches.length) {
        sb.write("\n");
      }
    }

    return sb.toString();
  }

  void overwriteRecord(Tournament t) {
    _wins = 0;
    _ties = 0;
    _losses = 0;
    _points = 0;
    _opponents.clear();

    int numExpectedMatches = t.info.squadDetails.requiredNumCoachesPerSquad;

    _bonusPts.clear();

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

      // Update bonus points
      List<int>? bonuses = cr.squadBonuses[_name];
      if (bonuses != null) {
        _bonusPts = bonuses.map((b) => b as double).toList();
      }

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

    // Add bonus points to total points
    List<BonusDetails> bonusDetails =
        t.info.squadDetails.scoringDetails.bonusPts;

    for (int i = 0; i < _bonusPts.length; i++) {
      double weight = i < bonusDetails.length ? bonusDetails[i].weight : 0.0;
      _points += _bonusPts[i] * weight;
    }
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
    oppCoachPoints = 0.0;
    _tieBreakers.clear();

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      if (c != null) {
        oppCoachPoints += c.oppPoints;
      }
    });

    if (t.useSquadVsSquad()) {
      _opponents.forEach((s) {
        String oppSquadName = s.name();
        Squad? oppSquad = t.getSquad(oppSquadName);
        if (oppSquad != null) {
          oppPoints += oppSquad.points();
        }
      });
    } else {
      oppPoints = oppCoachPoints;
    }

    t.info.squadDetails.squadTieBreakers.forEach((tb) {
      switch (tb) {
        case SquadTieBreakers.OppScore:
          _tieBreakers.add(oppPoints);
          break;
        case SquadTieBreakers.SquadWins:
          _tieBreakers.add(_wins.toDouble());
          break;
        case SquadTieBreakers.SquadTies:
          _tieBreakers.add(_ties.toDouble());
          break;
        case SquadTieBreakers.SumSquadMemberScore:
          _tieBreakers.add(_coaches.map((nafName) {
            Coach? c = t.getCoach(nafName);
            return c != null ? c.points() : 0.0;
          }).sum);
          break;
        case SquadTieBreakers.SumTdDiff:
          _tieBreakers.add(_sumTdDiff(t).toDouble());
          break;
        case SquadTieBreakers.SumCasDiff:
          _tieBreakers.add(_sumCasDiff(t).toDouble());
          break;
        case SquadTieBreakers.SumTdDiffPlusCasDiff:
          _tieBreakers.add((_sumTdDiff(t) + _sumCasDiff(t)).toDouble());
          break;
      }
    });
  }

  int _sumTdDiff(Tournament t) {
    return _coaches.map((nafName) {
      Coach? c = t.getCoach(nafName);
      return c != null ? c.tds - c.oppTds : 0;
    }).sum;
  }

  int _sumCasDiff(Tournament t) {
    return _coaches.map((nafName) {
      Coach? c = t.getCoach(nafName);
      return c != null ? c.cas - c.oppCas : 0;
    }).sum;
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

  int sumBestSport(Tournament t) {
    int sumBestSport = 0;

    _coaches.forEach((nafName) {
      Coach? c = t.getCoach(nafName);
      sumBestSport += c != null ? c.bestSportPoints : 0;
    });

    return sumBestSport;
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
    this._name = tName != null ? tName.trim() : "";

    final tCoaches = json['coaches'] as List<String>?;
    this._coaches =
        tCoaches != null ? tCoaches.map((e) => e.trim()).toList() : [];
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
