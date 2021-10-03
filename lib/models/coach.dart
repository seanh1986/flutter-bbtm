import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'coach.g.dart';

// @JsonSerializable(nullable: false)
class Coach extends IMatchupParticipant {
  final int teamId;

  final String nafName; // Key

  final String squadName;

  final String coachName;

  final String teamName;

  final int nafNumber;

  final Race _race;

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  int _points = 0;

  int tds = 0;
  int cas = 0;

  Coach(
    this.teamId,
    this.nafName,
    this.squadName,
    this.coachName,
    this._race,
    this.teamName,
    this.nafNumber,
  );

  @override
  OrgType type() {
    return OrgType.Coach;
  }

  @override
  String name() {
    return nafName;
  }

  @override
  String parentName() {
    return squadName;
  }

  @override
  Race race() {
    return _race;
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

  void addWin() {
    _wins++;
  }

  void addTie() {
    _ties++;
  }

  void addLoss() {
    _losses++;
  }

  void calculatePoints(int winPts, int tiePts, int lossPts) {
    _points = _wins * winPts + _ties * tiePts + _losses * lossPts;
  }

  void addTds(int t) {
    tds += t;
  }

  void addCas(int c) {
    cas += c;
  }
}
