import 'package:bbnaf/models/races.dart';

// Identifies if the object is of type squad or coach
enum OrgType {
  Squad,
  Coach,
}

enum MatchResult {
  NoResult, // no result assigned yet
  HomeWon,
  AwayWon,
  Draw,
}

abstract class IMatchup {
  OrgType type();
  int roundNum();
  int tableNum();
  IMatchupParticipant home();
  IMatchupParticipant away();

  MatchResult result = MatchResult.NoResult;

  String matchupName() {
    switch (type()) {
      case OrgType.Coach:
        return home().parentName() + " vs. " + away().parentName();
      case OrgType.Squad:
      default:
        return "Squad Table #" + tableNum().toString();
    }
  }

  bool hasResult() {
    return result != MatchResult.NoResult;
  }

  void setResult(MatchResult result) {
    this.result = result;
  }

  bool hasParticipant(IMatchupParticipant p) {
    return home().name() == p.name() || away().name() == p.name();
  }

  bool hasParticipants(IMatchupParticipant p1, IMatchupParticipant p2) {
    return (home() == p1 && away() == p2) || (home() == p2 && away() == p1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is IMatchup &&
        other.type() == type() &&
        other.roundNum() == roundNum() &&
        other.home() == home() &&
        other.away() == away();
  }

  @override
  int get hashCode => Object.hash(type(), roundNum(), home(), away());
}

// Abstract class which represents a matchup
// This can be squad vs squad or coach vs coach
abstract class IMatchupParticipant {
  OrgType type();
  String name();
  String parentName();
  Race race();
  double points();
  int wins();
  int ties();
  int losses();
  List<double> tiebreakers();
  List<String> opponents();

  // Returns "" if not valid
  String raceName() {
    return RaceUtils.getName(race());
  }

  String showRecord() {
    return wins().toString() +
        "-" +
        ties().toString() +
        "-" +
        losses().toString() +
        " (" +
        winPercent().toStringAsFixed(1) +
        "%)";
  }

  int gamesPlayed() {
    return wins() + ties() + losses();
  }

  double winPercent() {
    int games = gamesPlayed();
    return games > 0 ? 100.0 * (1.0 * wins() + 0.5 * ties()) / games : 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is IMatchupParticipant &&
        other.type() == type() &&
        other.name() == name();
  }

  @override
  int get hashCode => Object.hash(type(), name());
}
