import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';

abstract class RankingFilter {
  final String name;

  RankingFilter(this.name);

  bool isActive(IMatchupParticipant p);
}

class CoachRankingFilter extends RankingFilter {
  bool Function(Coach c) _predicate;
  final List<CoachRankingFields> fields;

  CoachRankingFilter(String name, this._predicate, this.fields) : super(name);

  bool isActive(IMatchupParticipant p) {
    if (p is Coach) {
      return _predicate.call(p);
    } else {
      return false;
    }
  }
}

class SquadRankingFilter extends RankingFilter {
  bool Function(Squad c) _predicate;
  final List<SquadRankingFields> fields;

  SquadRankingFilter(String name, this._predicate, this.fields) : super(name);

  bool isActive(IMatchupParticipant p) {
    if (p is Squad) {
      return _predicate.call(p);
    } else {
      return false;
    }
  }
}

class StuntyFilter extends CoachRankingFilter {
  StuntyFilter()
      : super("Stunty", (c) {
          return c.isStunty();
        }, [
          CoachRankingFields.Pts,
          CoachRankingFields.Td,
          CoachRankingFields.Cas
        ]);
}
