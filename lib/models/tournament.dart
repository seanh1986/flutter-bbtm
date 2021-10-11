import 'dart:collection';
import "package:collection/collection.dart";
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/rounds.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/squad_matchup.dart';
import 'package:bbnaf/models/tournament_info.dart';
import 'package:xml/xml.dart';

class Tournament {
  late final TournamentInfo info;
  late final XmlDocument xml;

  late final bool useSquads;

  late final int curRoundNumber;

  // Key: squad name
  late final HashMap<String, Squad> squadMap;

  // Key: nafName
  late final HashMap<String, Coach> coachMap;

  late final List<SquadRound> prevSquadRounds;
  late final List<CoachRound> prevCoachRounds;

  SquadRound? curSquadRound;
  CoachRound? curCoachRound;

  Squad? getSquad(String squadName) {
    return squadMap[squadName];
  }

  Coach? getCoach(String nafName) {
    return coachMap[nafName];
  }

  // Squad constructor
  Tournament.squads(
      this.info,
      this.xml,
      this.curRoundNumber,
      this.squadMap,
      this.coachMap,
      this.prevSquadRounds,
      this.prevCoachRounds,
      this.curSquadRound,
      this.curCoachRound) {
    useSquads = true;
  }

  // Non-squad constructor
  Tournament.noSquads(this.info, this.xml, this.curRoundNumber, this.coachMap,
      this.prevCoachRounds, this.curCoachRound) {
    useSquads = false;
    squadMap = new HashMap<String, Squad>();
    curSquadRound = null;
  }

  factory Tournament.fromXml(XmlDocument xml, TournamentInfo info) {
    HashMap<String, Squad> squadMap = new HashMap<String, Squad>();
    HashMap<String, Coach> coachMap = new HashMap<String, Coach>();

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
        squadMap.putIfAbsent(squadName, () => Squad(squadName));
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
      coachMap.putIfAbsent(c.nafName, () => c);

      if (useSquads) {
        Squad? squad = squadMap[squadName];
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
        Coach? coach1 = coachMap[nafName1];

        String? nafName2 = teamIdToNafName[team2];
        Coach? coach2 = coachMap[nafName2];

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
    for (Coach c in coachMap.values) {
      c.calculatePoints(winValue, tieValue, lossValue);
    }

    if (useSquads) {
      List<SquadRound> prevSquadRounds =
          _getSquadRounds(prevCoachRounds, squadMap, coachMap);
      SquadRound curSquadRound =
          _getSquadRound(curCoachRound!, squadMap, coachMap);

      // Update squad points
      for (Squad s in squadMap.values) {
        s.calculatePoints(squadScoreMode, coachMap);
        s.calculateWinsTiesLosses(prevSquadRounds);
      }

      return new Tournament.squads(
          info,
          xml,
          curRoundNumber,
          squadMap,
          coachMap,
          prevSquadRounds,
          prevCoachRounds,
          curSquadRound,
          curCoachRound);
    } else {
      return new Tournament.noSquads(
          info, xml, curRoundNumber, coachMap, prevCoachRounds, curCoachRound);
    }
  }

  static List<SquadRound> _getSquadRounds(List<CoachRound> coachRounds,
      HashMap<String, Squad> squadMap, HashMap<String, Coach> coachMap) {
    List<SquadRound> squadRounds = [];

    for (CoachRound cr in coachRounds) {
      SquadRound squadRound = _getSquadRound(cr, squadMap, coachMap);
      squadRounds.add(squadRound);
    }

    return squadRounds;
  }

  static SquadRound _getSquadRound(CoachRound cr,
      HashMap<String, Squad> squadMap, HashMap<String, Coach> coachMap) {
    int roundNumber = cr.roundNumber;

    List<SquadMatchup> squadMatchupList = [];

    // HomeSquad to list of coach matchups
    Map<String, List<CoachMatchup>> groups =
        groupBy(cr.coachMatchups, (CoachMatchup cm) => cm.homeCoach.squadName);

    int tableNum = 1;
    for (String homeSquadName in groups.keys) {
      List<CoachMatchup>? coachMatchups = groups[homeSquadName];
      if (coachMatchups == null || coachMatchups.isEmpty) {
        continue;
      }

      Squad? homeSquad = squadMap[homeSquadName];
      Squad? awaySquad = squadMap[coachMatchups.first.awayCoach.squadName];
      if (homeSquad == null || awaySquad == null) {
        continue;
      }

      SquadMatchup squadMatchup = new SquadMatchup(
          roundNumber, tableNum, homeSquad, awaySquad, coachMatchups);

      squadMatchupList.add(squadMatchup);

      tableNum++;
    }

    return new SquadRound(roundNumber, squadMatchupList);
  }
}
