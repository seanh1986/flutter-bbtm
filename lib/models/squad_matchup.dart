import 'package:amorical_cup/models/squad.dart';
import 'package:amorical_cup/models/coach.dart';
import 'package:amorical_cup/models/tournament.dart';
import 'package:amorical_cup/models/coach_matchup.dart';
import 'dart:math';
import 'package:amorical_cup/models/i_matchup.dart';

class SquadMatchup extends IMatchup {
  final int _tableNum;

  final Squad homeSquad;
  final Squad awaySquad;

  final List<CoachMatchup> coachMatchups;

  SquadMatchup(
      this._tableNum, this.homeSquad, this.awaySquad, this.coachMatchups);

  @override
  OrgType type() {
    return OrgType.Squad;
  }

  @override
  int tableNum() {
    return _tableNum;
  }

  @override
  IMatchupParticipant home() {
    return homeSquad;
  }

  @override
  IMatchupParticipant away() {
    return awaySquad;
  }

  static List<SquadMatchup> getExampleSquadMatchups(Tournament t) {
    List<SquadMatchup> squadMatchups = [];

    int squadTableNum = 0;
    int coachTableNum = 0;
    for (int i = 1; i < t.squads.length; i += 2) {
      squadTableNum++;

      Squad homeSquad = t.squads[i - 1];
      Squad awaySquad = t.squads[i];

      List<CoachMatchup> coachMatchups = [];

      int numCoachesPerSquad =
          min(homeSquad.coaches.length, awaySquad.coaches.length);

      for (int j = 0; j < numCoachesPerSquad; j++) {
        coachTableNum++;

        Coach homeCoach = t.getCoach(homeSquad.coaches[j]);
        Coach awayCoach = t.getCoach(awaySquad.coaches[j]);

        coachMatchups
            .add(new CoachMatchup(coachTableNum, homeCoach, awayCoach));
      }

      squadMatchups.add(
          new SquadMatchup(squadTableNum, homeSquad, awaySquad, coachMatchups));
    }

    return squadMatchups;
  }
}
