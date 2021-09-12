import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/i_matchup.dart';

class CoachMatchup extends IMatchup {
  final int _tableNum;

  final Coach homeCoach;
  final Coach awayCoach;

  CoachMatchup(this._tableNum, this.homeCoach, this.awayCoach);

  @override
  OrgType type() {
    return OrgType.Coach;
  }

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
