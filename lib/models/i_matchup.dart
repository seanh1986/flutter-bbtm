import 'package:bbnaf/models/races.dart';

// Identifies if the object is of type squad or coach
enum OrgType {
  Squad,
  Coach,
}

abstract class IMatchup {
  OrgType type();
  int roundNum();
  int tableNum();
  IMatchupParticipant home();
  IMatchupParticipant away();

  String matchupName() {
    switch (type()) {
      case OrgType.Coach:
        return home().parentName() + " vs. " + away().parentName();
      case OrgType.Squad:
      default:
        return "Squad Table #" + tableNum().toString();
    }
  }
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
}
