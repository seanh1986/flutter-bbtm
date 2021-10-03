import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'squad.g.dart';

// @JsonSerializable(nullable: false)
class Squad extends IMatchupParticipant {
  final String _name; // Key

  List<String> _coaches = []; // nafNames

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  int _points = 0;

  bool stunty = false;

  Squad(this._name);

  @override
  OrgType type() {
    return OrgType.Squad;
  }

  @override
  String name() {
    return _name;
  }

  @override
  Race race() {
    return Race.Unknown;
  }

  @override
  String parentName() {
    return "";
  }

  @override
  int points() {
    return _points;
  }

  @override
  int wins() {
    return _wins;
  }

  @override
  int ties() {
    return _ties;
  }

  @override
  int losses() {
    return _losses;
  }

  List<String> getCoaches() {
    return _coaches;
  }

  void addCoach(Coach c) {
    _coaches.add(c.nafName);
  }

  void setWins(int w) {
    _wins = w;
  }

  void setTies(int t) {
    _ties = t;
  }

  void setLosses(int l) {
    _losses = l;
  }

  void setPoints(int p) {
    _points = p;
  }
}
