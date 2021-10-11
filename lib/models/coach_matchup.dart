import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/i_matchup.dart';

class CoachMatchup extends IMatchup {
  final int _roundNum;
  final int _tableNum;

  final Coach homeCoach;
  int homeTds = 0;
  int homeCas = 0;

  final Coach awayCoach;
  int awayTds = 0;
  int awayCas = 0;

  CoachMatchup(this._roundNum, this._tableNum, this.homeCoach, this.awayCoach);

  @override
  OrgType type() {
    return OrgType.Coach;
  }

  @override
  int roundNum() {
    return _roundNum;
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
