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
  MatchResult getResult() {
    return MatchResult.NoResult;
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
