import 'package:amorical_cup/data/races.dart';

abstract class IMatchup {
  int tableNum();
  IMatchupParticipant home();
  IMatchupParticipant away();
}

abstract class IMatchupParticipant {
  String name();
  Race race();
  int points();
  int wins();
  int ties();
  int losses();

  String raceName() {
    return RaceUtils.getName(race());
  }
}
