import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';

abstract class ItemClickListener {
  void onItemClicked(int idx);
}

abstract class CoachMatchupListClickListener {
  void onItemClicked(List<CoachMatchup> matchups);
}

abstract class MatchupClickListener {
  void onItemClicked(IMatchup matchup);
}

abstract class ParticipantClickListener {
  void onItemClicked(IMatchupParticipant participant);
}
