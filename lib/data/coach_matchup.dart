import 'package:amorical_cup/data/coach.dart';
import 'package:amorical_cup/data/i_matchup.dart';

class CoachMatchup implements IMatchup {
  final int _tableNum;

  final Coach homeCoach;
  final Coach awayCoach;

  CoachMatchup(this._tableNum, this.homeCoach, this.awayCoach);

  @override
  int tableNum() {
    return _tableNum;
  }

  @override
  IMatchupParticipant home() {
    return homeCoach;
  }

  @override
  IMatchupParticipant away() {
    return awayCoach;
  }
}
