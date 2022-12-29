import 'dart:collection';
import 'dart:convert';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'coach.g.dart';

// @JsonSerializable(nullable: false)
class Coach extends IMatchupParticipant {
  late final int teamId;

  late final String nafName; // Key

  late final String squadName;

  late final String coachName;

  late final String teamName;

  late final int nafNumber;

  late final Race _race;

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0;

  int tds = 0;
  int cas = 0;

  List<double> _tieBreakers = <double>[];

  List<String> _opponents = <String>[];

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
  double points() {
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

  @override
  List<double> tiebreakers() {
    return _tieBreakers;
  }

  @override
  List<String> opponents() {
    return _opponents;
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

  void calculatePoints(double winPts, double tiePts, double lossPts) {
    _points = _wins * winPts + _ties * tiePts + _losses * lossPts;
  }

  void updateTiebreakers(List<double> tieBreakers) {
    _tieBreakers = tieBreakers;
  }

  void addNewOpponent(String opponentName) {
    _opponents.add(opponentName);
  }

  void addTds(int t) {
    tds += t;
  }

  void addCas(int c) {
    cas += c;
  }

  Coach.fromJson(int id, Map<String, Object?> json) {
    this.teamId = id;

    final tNafName = json['nafname'] as String?;
    this.nafName = tNafName != null ? tNafName : "";

    final tCoachName = json['coachname'] as String?;
    this.coachName = tCoachName != null ? tCoachName : "";

    final tTeamName = json['teamname'] as String?;
    this.teamName = tTeamName != null ? tTeamName : "";

    final tSquadName = json['squadname'] as String?;
    this.squadName = tSquadName != null ? tSquadName : "";

    final tRace = json['race'] as String?;
    this._race = tRace != null ? RaceUtils.getRace(tRace) : Race.Unknown;

    final tNafNumber = json['nafnumber'] as int?;
    this.nafNumber = tNafNumber != null ? tNafNumber : -1;

    final tWins = json['wins'] as int?;
    this._wins = tWins != null ? tWins : 0;

    final tTies = json['ties'] as int?;
    this._ties = tTies != null ? tTies : 0;

    final tLosses = json['losses'] as int?;
    this._losses = tLosses != null ? tLosses : 0;

    final tTd = json['td'] as int?;
    this.tds = tTd != null ? tTd : 0;

    final tCas = json['cas'] as int?;
    this.cas = tCas != null ? tCas : 0;
  }

  Map toJson() => {
        'nafname': nafName,
        'coachname': coachName,
        'teamname': teamName,
        'squadname': squadName,
        'race': RaceUtils.getName(_race),
        'nafnumber': nafNumber,
        'wins': _wins,
        'ties': _ties,
        'losses': _losses,
        'td': tds,
        'cas': cas,
        'opponents': jsonEncode(_opponents)
      };
}
