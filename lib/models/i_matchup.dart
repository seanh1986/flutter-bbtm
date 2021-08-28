import 'package:amorical_cup/models/races.dart';

enum OrgType {
  Squad,
  Coach,
}

abstract class IMatchup {
  OrgType type();
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

abstract class IMatchupParticipant {
  OrgType type();
  String name();
  String parentName();
  Race race();
  int points();
  int wins();
  int ties();
  int losses();

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
    return games > 0
        ? 100.0 * (1.0 * wins() + 0.5 * ties()) / gamesPlayed()
        : 0.0;
  }
}
