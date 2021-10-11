import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/squad_matchup.dart';

class SquadRound {
  int roundNumber;
  List<SquadMatchup> squadMatchups;
  SquadRound(this.roundNumber, this.squadMatchups);
}

class CoachRound {
  int roundNumber;
  List<CoachMatchup> coachMatchups;
  CoachRound(this.roundNumber, this.coachMatchups);
}
