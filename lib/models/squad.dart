import 'dart:collection';

import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/rounds.dart';
import 'package:bbnaf/models/squad_matchup.dart';

// Different options for how squads are used
enum SquadScoreMode {
  NO_SQUADS, // No squads at all
  CUMULATIVE_PLAYER_SCORES, // Squad pts are sum of player pts
  W_T_L_1_HALF_0, // 1 pt for W, 0.5 for tie, 0 for loss
  COUNT_WINS_ONLY, // pts = num wins
}

class Squad extends IMatchupParticipant {
  final String _name; // Key

  List<String> _coaches = []; // nafNames

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0.0;

  bool stunty = false;

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
  Race race() {
    return Race.Unknown;
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

  List<String> getCoaches() {
    return _coaches;
  }

  void addCoach(Coach c) {
    _coaches.add(c.nafName);
  }

  void calculateWinsTiesLosses(List<SquadRound> prevSquadRounds) {
    for (SquadRound sr in prevSquadRounds) {
      for (SquadMatchup sm in sr.squadMatchups) {
        bool isHome;
        if (sm.homeSquad.name() == _name) {
          isHome = true;
        } else if (sm.awaySquad.name() == _name) {
          isHome = false;
        } else {
          continue;
        }

        int numWins = 0;
        int numTies = 0;
        int numLosses = 0;
        for (CoachMatchup cm in sm.coachMatchups) {
          if (cm.homeTds > cm.awayTds) {
            // home wins
            if (isHome) {
              numWins++;
            } else {
              numLosses++;
            }
          } else if (cm.homeTds < cm.awayTds) {
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

  void calculatePoints(
      SquadScoreMode scoreMode, HashMap<String, Coach> coachMap) {
    switch (scoreMode) {
      case SquadScoreMode.CUMULATIVE_PLAYER_SCORES:
        _calculatePointsCumulativePlayerScores(coachMap);
        break;
      case SquadScoreMode.W_T_L_1_HALF_0:
        _calculatePointsWinTieLossOneHalfZero();
        break;
      case SquadScoreMode.COUNT_WINS_ONLY:
        _calculatePointsWinsOnly();
        break;
      default:
        break;
    }
  }

  void _calculatePointsCumulativePlayerScores(HashMap<String, Coach> coachMap) {
    _points = 0;
    for (String nafName in _coaches) {
      Coach? c = coachMap[nafName];
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

  static SquadScoreMode getSquadScoreMode(int groupScoreMode) {
    switch (groupScoreMode) {
      case 0:
        return SquadScoreMode.CUMULATIVE_PLAYER_SCORES;
      case 1:
        return SquadScoreMode.W_T_L_1_HALF_0;
      case 2:
        return SquadScoreMode.COUNT_WINS_ONLY;
      default:
        return SquadScoreMode.NO_SQUADS;
    }
  }
}
