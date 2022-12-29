import 'dart:collection';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import "package:collection/collection.dart";
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

class Tournament {
  late final TournamentInfo info;
  //late final XmlDocument xml;

  late final FirstRoundMatchingRule firstRoundMatchingRule;
  late final bool useSquads;

  int curRoundNumber = 0;

  // Key: squad name, Value: Idx in squad list
  HashMap<String, int> _squadIdxMap = new HashMap<String, int>();
  List<Squad> _squads = [];

  // Key: nafName, Value: Idx in coach list
  HashMap<String, int> _coachIdxMap = new HashMap<String, int>();
  List<Coach> _coaches = [];

  List<SquadRound> prevSquadRounds = [];
  List<CoachRound> prevCoachRounds = [];

  SquadRound? curSquadRound;
  CoachRound? curCoachRound;

  void addSquad(Squad s) {
    int idx = _squads.length;
    _squads.add(s);
    _squadIdxMap.putIfAbsent(s.name(), () => idx);
  }

  Squad? getSquad(String squadName) {
    int? idx = _squadIdxMap[squadName];
    return idx != null ? _squads[idx] : null;
  }

  List<Squad> getSquads() {
    return _squads;
  }

  void addCoach(Coach c) {
    int idx = _coaches.length;
    _coaches.add(c);
    _coachIdxMap.putIfAbsent(c.name(), () => idx);
  }

  Coach? getCoach(String nafName) {
    int? idx = _coachIdxMap[nafName];
    return idx != null ? _coaches[idx] : null;
  }

  Squad? getCoachSquad(String nafName) {
    if (!useSquads) {
      return null;
    }

    Coach? coach = getCoach(nafName);
    return coach != null ? getSquad(coach.squadName) : null;
  }

  List<Coach> getCoaches() {
    return _coaches;
  }

  bool updateRound(RoundMatching matchups) {
    int newRound = matchups.round();

    if (newRound != curRoundNumber + 1) {
      debugPrint('Failed to update round: Round numbers do not coincide');
      return false;
    }

    curRoundNumber = newRound;
    if (useSquads) {
      SquadRound squadRound = SquadRound.fromRoundMatching(matchups);
      if (squadRound.getMatches().isEmpty) {
        debugPrint('Failed to update round: Matches list is empty');
        return false;
      }

      prevSquadRounds.add(squadRound);
      curSquadRound = squadRound;

      // TODO: Update coaches too
    } else {
      CoachRound round = CoachRound.fromRoundMatching(matchups);
      if (round.getMatches().isEmpty) {
        debugPrint('Failed to update round: Matches list is empty');
        return false;
      }

      prevCoachRounds.add(round);
      curCoachRound = round;
    }

    return true;
  }

  Tournament.fromJson(TournamentInfo info, Map<String, dynamic> json) {
    this.info = info;

    final tRound = json['round'] as int?;
    this.curRoundNumber = tRound != null ? tRound : 0;

    final tUseSquads = json['usesquads'] as bool?;
    this.useSquads = tUseSquads != null ? tUseSquads : false;

    final tFirstRoundMatching = json['firstroundmatching'] as String?;
    this.firstRoundMatchingRule = SwissPairings.parseFirstRoundMatchingName(
        tFirstRoundMatching != null ? tFirstRoundMatching : "");

    final tCoaches = json['coaches'] as List<dynamic>?;
    if (tCoaches != null) {
      for (int i = 0; i < tCoaches.length; i++) {
        addCoach(Coach.fromJson(i, tCoaches[i] as Map<String, dynamic>));
      }
    }
  }

  void _syncSquadsAndCoaches() {
    _squadIdxMap.clear();
    for (int i = 0; i < _squads.length; i++) {
      Squad s = _squads[i];
      _squadIdxMap.putIfAbsent(s.name(), () => i);
    }

    _coachIdxMap.clear();
    for (int i = 0; i < _coaches.length; i++) {
      Coach c = _coaches[i];
      _coachIdxMap.putIfAbsent(c.name(), () => i);
    }
  }

  factory Tournament.fromXml(XmlDocument xml, TournamentInfo info) {
    List<Squad> squads = [];
    HashMap<String, int> squadMap = new HashMap<String, int>();

    List<Coach> coaches = [];
    HashMap<String, int> coachMap = new HashMap<String, int>();

    HashMap<int, String> teamIdToNafName = new HashMap<int, String>();

    final tournamentTag = xml.findAllElements('tournament').first;

    // Find out about different group modes and their scoring!
    int groupMode =
        int.parse(tournamentTag.getElement("groupmode")?.text ?? "0");
    bool useSquads = groupMode == 1;

    int groupScoreMode =
        int.parse(tournamentTag.getElement("groupscore")?.text ?? "0");

    SquadScoreMode squadScoreMode = Squad.getSquadScoreMode(groupScoreMode);

    int curRoundNumber =
        int.parse(tournamentTag.getElement("currentround")?.text ?? "0");

    double winValue =
        double.parse(tournamentTag.getElement("win")?.text ?? "0.0");

    double tieValue =
        double.parse(tournamentTag.getElement("draw")?.text ?? "0.0");

    double lossValue =
        double.parse(tournamentTag.getElement("loss")?.text ?? "0.0");

    if (useSquads) {
      // List of squads
      final groupTags = tournamentTag.findAllElements('group');

      for (var g in groupTags) {
        String squadName = g.text;

        int idx = squads.length;

        squads.add(Squad(squadName));
        squadMap.putIfAbsent(squadName, () => idx);
      }
    }

    // List of teams
    final teamsTags = xml.findAllElements('team');

    for (var t in teamsTags) {
      int id = int.parse(t.getAttribute('id') ?? "0");

      String teamName = t.getElement('teamname')!.text;
      String coachName = t.getElement('coach')!.text;
      String nafName = t.getElement('nafname')!.text;
      int nafNumber = int.parse(t.getElement('nafnumber')!.text);
      String race = t.getElement('nafrace')!.text;
      String squadName = t.getElement('group')!.text;

      teamIdToNafName.putIfAbsent(id, () => nafName);

      Coach c = new Coach(id, nafName, squadName, coachName,
          RaceUtils.getRace(race), teamName, nafNumber);

      int idx = coaches.length;

      coaches.add(c);

      coachMap.putIfAbsent(c.nafName, () => idx);

      if (useSquads) {
        int? idx = squadMap[squadName];
        Squad? squad = idx != null ? squads[idx] : null;
        squad!.addCoach(c);
      }
    }

    List<CoachRound> prevCoachRounds = [];
    CoachRound? curCoachRound;

    final roundsTags = xml.findAllElements('round');
    for (var r in roundsTags) {
      int roundNumber = int.parse(r.getAttribute('number') ?? "0");

      bool isCurrentRound = roundNumber == curRoundNumber;

      List<CoachMatchup> coachMatchups = [];

      final gamesTags = r.findAllElements('game');
      for (var g in gamesTags) {
        int tableNumber = int.parse(g.getAttribute('table') ?? "0");
        int team1 = int.parse(g.getElement('team1')!.text); // team id
        int team2 = int.parse(g.getElement('team2')!.text); // team id
        int td1 = int.parse(g.getElement('td1')!.text);
        int td2 = int.parse(g.getElement('td2')!.text);
        int cas1 = int.parse(g.getElement('cas1')!.text);
        int cas2 = int.parse(g.getElement('cas2')!.text);

        String? nafName1 = teamIdToNafName[team1];
        int? idx1 = coachMap[nafName1];
        Coach? coach1 = idx1 != null ? coaches[idx1] : null;

        String? nafName2 = teamIdToNafName[team2];
        int? idx2 = coachMap[nafName2];
        Coach? coach2 = idx2 != null ? coaches[idx2] : null;

        if (coach1 == null || coach2 == null) {
          continue;
        }

        CoachMatchup matchup =
            new CoachMatchup(roundNumber, tableNumber, coach1, coach2);
        coachMatchups.add(matchup);

        if (isCurrentRound) {
          continue;
        }

        matchup.homeTds = td1;
        matchup.homeCas = cas1;
        coach1.addTds(td1);
        coach1.addCas(cas1);

        matchup.awayTds = td2;
        matchup.awayCas = cas2;
        coach2.addTds(td2);
        coach2.addCas(cas2);

        if (td1 > td2) {
          coach1.addWin();
          coach2.addLoss();
        } else if (td2 > td1) {
          coach1.addLoss();
          coach2.addWin();
        } else {
          coach1.addTie();
          coach2.addTie();
        }
      }

      // Update Coach Rounds
      CoachRound coachRound = new CoachRound(roundNumber, coachMatchups);

      if (isCurrentRound) {
        curCoachRound = coachRound;
      } else {
        prevCoachRounds.add(coachRound);
      }
    }

    // Update coach points
    coaches.forEach((Coach coach) {
      coach.calculatePoints(winValue, tieValue, lossValue);
    });

    if (useSquads) {
      List<SquadRound> prevSquadRounds =
          _getSquadRounds(prevCoachRounds, squadMap, squads, coachMap, coaches);
      SquadRound curSquadRound =
          _getSquadRound(curCoachRound!, squadMap, squads, coachMap, coaches);

      // Update squad points
      squads.forEach((Squad squad) {
        squad.calculatePoints(squadScoreMode, coachMap, coaches);
        squad.calculateWinsTiesLosses(prevSquadRounds);
      });

      return new Tournament.squads(
          info,
          // xml,
          curRoundNumber,
          squads,
          coaches,
          prevSquadRounds,
          prevCoachRounds,
          curSquadRound,
          curCoachRound);
    } else {
      return new Tournament.noSquads(
          info,
          // xml,
          curRoundNumber,
          coaches,
          prevCoachRounds,
          curCoachRound);
    }
  }

// Squad constructor
  Tournament.squads(
      this.info,
      // this.xml,
      this.curRoundNumber,
      this._squads,
      this._coaches,
      this.prevSquadRounds,
      this.prevCoachRounds,
      this.curSquadRound,
      this.curCoachRound) {
    useSquads = true;

    // for (int i = 0; i < _squads.length; i++) {
    //   Squad s = _squads[i];
    //   _squadMap.putIfAbsent(s.name(), () => i);
    // }

    // for (int i = 0; i < _coaches.length; i++) {
    //   Coach c = _coaches[i];
    //   _coachMap.putIfAbsent(c.name(), () => i);
    // }
    _syncSquadsAndCoaches();
  }

  // Non-squad constructor
  Tournament.noSquads(
      this.info,
      // this.xml,
      this.curRoundNumber,
      this._coaches,
      this.prevCoachRounds,
      this.curCoachRound) {
    useSquads = false;
    curSquadRound = null;

    // for (int i = 0; i < _coaches.length; i++) {
    //   Coach c = _coaches[i];
    //   _coachMap.putIfAbsent(c.name(), () => i);
    // }
    _syncSquadsAndCoaches();
  }

  static List<SquadRound> _getSquadRounds(
      List<CoachRound> coachRounds,
      HashMap<String, int> squadMap,
      List<Squad> squads,
      HashMap<String, int> coachMap,
      List<Coach> coaches) {
    List<SquadRound> squadRounds = [];

    for (CoachRound cr in coachRounds) {
      SquadRound squadRound =
          _getSquadRound(cr, squadMap, squads, coachMap, coaches);
      squadRounds.add(squadRound);
    }

    return squadRounds;
  }

  static SquadRound _getSquadRound(CoachRound cr, HashMap<String, int> squadMap,
      List<Squad> squads, HashMap<String, int> coachMap, List<Coach> coaches) {
    int roundNumber = cr.round();

    List<SquadMatchup> squadMatchupList = [];

    // HomeSquad to list of coach matchups
    Map<String, List<CoachMatchup>> groups =
        groupBy(cr.matches, (CoachMatchup cm) => cm.homeCoach.squadName);

    int tableNum = 1;
    for (String homeSquadName in groups.keys) {
      List<CoachMatchup>? coachMatchups = groups[homeSquadName];
      if (coachMatchups == null || coachMatchups.isEmpty) {
        continue;
      }

      int? homeSquadIdx = squadMap[homeSquadName];
      Squad? homeSquad = homeSquadIdx != null ? squads[homeSquadIdx] : null;

      int? awaySquadIdx = squadMap[coachMatchups.first.awayCoach.squadName];
      Squad? awaySquad = awaySquadIdx != null ? squads[awaySquadIdx] : null;
      if (homeSquad == null || awaySquad == null) {
        continue;
      }

      SquadMatchup squadMatchup =
          new SquadMatchup(roundNumber, tableNum, homeSquad, awaySquad);

      squadMatchup.coachMatchups = coachMatchups;

      squadMatchupList.add(squadMatchup);

      tableNum++;
    }

    return new SquadRound(roundNumber, squadMatchupList);
  }
}
