import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:meta/meta.dart';

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
    return homeSquadName.toLowerCase() == squadName.toLowerCase() ||
        awaySquadName.toLowerCase() == squadName.toLowerCase();
  }

  // SquadMatchup.fromJson(Map<String, dynamic> json) {
  //   final tHomeName = json['home_name'] as String?;
  //   this.homeSquadName = tHomeName != null ? tHomeName : "";

  //   final tAwayName = json['away_name'] as String?;
  //   this.awaySquadName = tAwayName != null ? tAwayName : "";

  //   // TODO: Coach Matchups! (maybe use index only?)
  // }

  // Map<String, dynamic> toJson() => {
  //       'home_name': homeSquadName,
  //       'away_name': awaySquadName,
  //     };
}
