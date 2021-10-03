import 'dart:collection';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament_info.dart';
import 'package:xml/xml.dart';

class Tournament {
  final TournamentInfo info;
  final XmlDocument xml;

  final bool useSquads;

  // Key: squad name
  final HashMap<String, Squad> squadMap;

  // Key: nafName
  final HashMap<String, Coach> coachMap;

  Tournament(
      this.info, this.xml, this.squadMap, this.coachMap, this.useSquads) {}

  Squad? getSquad(String squadName) {
    return squadMap[squadName];
  }

  Coach? getCoach(String nafName) {
    return coachMap[nafName];
  }

  factory Tournament.fromXml(XmlDocument xml, TournamentInfo info) {
    HashMap<String, Squad> squadMap = HashMap<String, Squad>();
    HashMap<String, Coach> coachMap = new HashMap<String, Coach>();

    HashMap<int, String> teamIdToNafName = new HashMap<int, String>();

    final tournamentTag = xml.findAllElements('tournament').first;

    // Find out about different group modes and their scoring!
    int groupMode =
        int.parse(tournamentTag.getElement("groupmode")?.text ?? "0");
    bool useSquads = groupMode == 1;

    int roundNumber =
        int.parse(tournamentTag.getElement("currentround")?.text ?? "0");

    int winValue = int.parse(tournamentTag.getElement("win")?.text ?? "0");

    int tieValue = int.parse(tournamentTag.getElement("draw")?.text ?? "0");

    int lossValue = int.parse(tournamentTag.getElement("loss")?.text ?? "0");

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

    int curRound = 0;

    final roundsTags = xml.findAllElements('round');
    for (var r in roundsTags) {
      int roundNumber = int.parse(r.getAttribute('number') ?? "0");

      curRound = roundNumber;

      final gamesTags = r.findAllElements('game');
      for (var g in gamesTags) {
        int tableNumber = int.parse(r.getAttribute('table') ?? "0");
        int team1 = int.parse(g.getElement('team1')!.text); // team id
        int team2 = int.parse(g.getElement('team2')!.text); // team id
        int td1 = int.parse(g.getElement('td1')!.text);
        int td2 = int.parse(g.getElement('td2')!.text);
        int cas1 = int.parse(g.getElement('cas1')!.text);
        int cas2 = int.parse(g.getElement('cas2')!.text);

        // This means it's just the next matchups
        // TODO move somewhere else
        if (td1 < 0 || td2 < 0) {
          continue;
        }

        String? nafName1 = teamIdToNafName[team1];
        Coach? coach1 = coachMap[nafName1];

        String? nafName2 = teamIdToNafName[team2];
        Coach? coach2 = coachMap[nafName2];

        if (coach1 == null || coach2 == null) {
          continue;
        }

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

        coach1.addTds(td1);
        coach1.addCas(cas1);

        coach2.addTds(td2);
        coach2.addCas(cas2);

        coach1.calculatePoints(winValue, tieValue, lossValue);
        coach2.calculatePoints(winValue, tieValue, lossValue);
      }
    }

    return new Tournament(info, xml, squadMap, coachMap, useSquads);
  }
}
