import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/matchup/squad_matchup.dart';

abstract class RoundMatching {
  int round();
  List<IMatchup> getMatches();
}

class SquadRound extends RoundMatching {
  late int _round;
  List<SquadMatchup> matches = [];

  SquadRound.newRound(this._round);
  SquadRound(this._round, this.matches);
  SquadRound.fromRoundMatching(RoundMatching rm) {
    _round = rm.round();
    rm.getMatches().forEach((r) {
      matches.add(r as SquadMatchup);
    });
  }

  int round() {
    return _round;
  }

  List<IMatchup> getMatches() {
    return matches;
  }

  bool hasMatchForSquad(Squad s) {
    return matches.any((SquadMatchup match) => match.hasParticipant(s));
  }

  Map<String, dynamic> toJson() => {
        'round': _round,
        'matches': matches.map((e) => e.toJson()).toList(),
      };
}

class CoachRound extends RoundMatching {
  late int _round;
  List<CoachMatchup> matches = [];

  CoachRound.newRound(this._round);
  CoachRound(this._round, this.matches);
  CoachRound.fromRoundMatching(RoundMatching rm) {
    _round = rm.round();
    rm.getMatches().forEach((r) {
      matches.add(r as CoachMatchup);
    });
  }

  int round() {
    return _round;
  }

  List<IMatchup> getMatches() {
    return matches;
  }

  bool hasMatchForPlayer(Coach c) {
    return matches.any((CoachMatchup match) => match.hasParticipant(c));
  }

  Map<String, dynamic> toJson() => {
        'round': _round,
        'matches': matches.map((e) => e.toJson()).toList(),
      };
}

class SwissRound extends RoundMatching {
  int _round;
  List<IMatchup> matches = [];

  SwissRound(this._round);

  int round() {
    return _round;
  }

  List<IMatchup> getMatches() {
    return matches;
  }

  bool hasMatchForPlayerName(String name) {
    return matches.any((IMatchup match) => match.hasParticipantName(name));
  }

  bool hasMatchForPlayer(IMatchupParticipant p) {
    return matches.any((IMatchup match) => match.hasParticipant(p));
  }

  bool removeMatch(IMatchup match) {
    return matches.remove(match);
  }
}
