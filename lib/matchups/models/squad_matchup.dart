import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';

class SquadMatchup extends IMatchup {
  late final String homeSquadName;
  late final String awaySquadName;

  List<CoachMatchup> coachMatchups = [];

  SquadMatchup(this.homeSquadName, this.awaySquadName);

  @override
  OrgType type() {
    return OrgType.Squad;
  }

  @override
  String homeName() {
    return homeSquadName;
  }

  @override
  String awayName() {
    return awaySquadName;
  }

  @override
  IMatchupParticipant home(Tournament t) {
    return t.getSquad(homeSquadName)!;
  }

  @override
  IMatchupParticipant away(Tournament t) {
    return t.getSquad(awaySquadName)!;
  }

  @override
  bool matchSearch(String search) {
    return homeSquadName.toLowerCase().contains(search) ||
        awaySquadName.toLowerCase().contains(search);
  }

  @override
  MatchResult getResult() {
    int homeWins = 0;
    int homeTies = 0;
    int homeLosses = 0;
    int numUndecided = 0;

    coachMatchups.forEach((m) {
      MatchResult r = m.getResult();
      switch (r) {
        case MatchResult.HomeWon:
          homeWins++;
          break;
        case MatchResult.AwayWon:
          homeLosses++;
          break;
        case MatchResult.Draw:
          homeTies++;
          break;
        case MatchResult.NoResult:
        case MatchResult.Conflict:
          numUndecided++;
          break;
      }
    });

    if (numUndecided > 0) {
      return MatchResult.NoResult;
    }

    double roundWinRate =
        (homeWins + homeTies * 0.5) / (homeWins + homeTies + homeLosses);

    if (roundWinRate > 0.5) {
      return MatchResult.HomeWon;
    } else if (roundWinRate < 0.5) {
      return MatchResult.AwayWon;
    } else {
      return MatchResult.Draw;
    }
  }

  bool hasSquad(String squadName) {
    return isHome(squadName) || isAway(squadName);
  }

  bool isHome(String? squadName) {
    return squadName != null &&
        homeSquadName.toLowerCase() == squadName.toLowerCase();
  }

  bool isAway(String? squadName) {
    return squadName != null &&
        awaySquadName.toLowerCase() == squadName.toLowerCase();
  }
}
