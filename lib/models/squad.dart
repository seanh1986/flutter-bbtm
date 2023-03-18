import 'dart:collection';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/matchup/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';

class Squad extends IMatchupParticipant {
  late final String _name; // Key

  List<String> _coaches = []; // nafNames

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0.0;

  List<double> _tieBreakers = <double>[];

  List<String> _opponents = <String>[];

  Squad(this._name);

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
    return _opponents;
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

  List<String> getCoaches() {
    return _coaches;
  }

  void calculateWinsTiesLosses(List<SquadRound> prevSquadRounds) {
    for (SquadRound sr in prevSquadRounds) {
      for (SquadMatchup sm in sr.matches) {
        bool isHome;
        if (sm.homeSquadName == _name) {
          isHome = true;
        } else if (sm.awaySquadName == _name) {
          isHome = false;
        } else {
          continue;
        }

        int numWins = 0;
        int numTies = 0;
        int numLosses = 0;
        for (CoachMatchup cm in sm.coachMatchups) {
          ReportedMatchResultWithStatus r = cm.getReportedMatchStatus();

          if (r.homeTds > r.awayTds) {
            // home wins
            if (isHome) {
              numWins++;
            } else {
              numLosses++;
            }
          } else if (r.homeTds < r.awayTds) {
            // away wins
            if (isHome) {
              numLosses++;
            } else {
              numWins++;
            }
          } else {
            numTies++;
          }
        }

        double winPts = numWins + numTies * 0.5;
        double lossPts = numLosses + numTies * 0.5;

        if (winPts > lossPts) {
          _wins++;
        } else if (winPts < lossPts) {
          _losses++;
        } else {
          _ties++;
        }
      }
    }
  }

  void calculatePoints(SquadScoring scoreMode, HashMap<String, int> coachMap,
      List<Coach> coachList) {
    switch (scoreMode) {
      case SquadScoring.CUMULATIVE_PLAYER_SCORES:
        _calculatePointsCumulativePlayerScores(coachMap, coachList);
        break;
      case SquadScoring.W_T_L_1_HALF_0:
        _calculatePointsWinTieLossOneHalfZero();
        break;
      case SquadScoring.COUNT_WINS_ONLY:
        _calculatePointsWinsOnly();
        break;
      default:
        break;
    }
  }

  void _calculatePointsCumulativePlayerScores(
      HashMap<String, int> coachMap, List<Coach> coachList) {
    _points = 0;
    for (String nafName in _coaches) {
      int? cIdx = coachMap[nafName];
      Coach? c = cIdx != null ? coachList[cIdx] : null;
      if (c == null) {
        continue;
      }

      _points += c.points();
    }
  }

  void _calculatePointsWinTieLossOneHalfZero() {
    _points = _wins * 1 + _ties * 0.5 + _losses * 0;
  }

  void _calculatePointsWinsOnly() {
    _points = _wins as double;
  }

  void updateTiebreakers(List<double> tieBreakers) {
    _tieBreakers = tieBreakers;
  }

  void addNewOpponent(String opponentName) {
    _opponents.add(opponentName);
  }

  // For parsing score .bbd files
  static SquadScoring getSquadScoreModeFromScoreFile(int groupScoreMode) {
    switch (groupScoreMode) {
      case 0:
        return SquadScoring.CUMULATIVE_PLAYER_SCORES;
      case 1:
        return SquadScoring.W_T_L_1_HALF_0;
      case 2:
        return SquadScoring.COUNT_WINS_ONLY;
      default:
        return SquadScoring.NO_SQUADS;
    }
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
