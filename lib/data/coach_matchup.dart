import 'package:amorical_cup/data/coach.dart';
import 'package:amorical_cup/data/i_matchup.dart';

class CoachMatchup implements IMatchup {
  final int _tableNum;

  final Coach homeCoach;
  final Coach awayCoach;

  CoachMatchup(this._tableNum, this.homeCoach, this.awayCoach);

  int tableNum() {
    return _tableNum;
  }

  String homeName() {
    return homeCoach.nafName;
  }

  String awayName() {
    return awayCoach.nafName;
  }

  String homeLogo() {
    return "";
  }

  String awayLogo() {
    return "";
  }

  int homeWins() {
    return homeCoach.wins;
  }

  int awayWin() {
    return awayCoach.wins;
  }

  int homeTies() {
    return homeCoach.ties;
  }

  int awayTies() {
    return awayCoach.ties;
  }

  int homeLosses() {
    return homeCoach.losses;
  }

  int awayLosses() {
    return awayCoach.losses;
  }
}
