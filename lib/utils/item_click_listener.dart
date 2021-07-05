import 'package:amorical_cup/data/coach_matchup.dart';
import 'package:amorical_cup/data/i_matchup.dart';

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
