import 'dart:collection';
import 'dart:math';

import 'package:amorical_cup/data/coach.dart';
import 'package:amorical_cup/data/races.dart';
import 'package:amorical_cup/data/squad.dart';

class Tournament {
  final String name;

  // Key: squad name
  List<Squad> squads;
  HashMap _squadMap = HashMap<String, Squad>();

  // Key: nafName
  List<Coach> coaches;
  HashMap _coachMap = new HashMap<String, Coach>();

  Tournament(this.name, this.squads, this.coaches) {
    _squadMap =
        HashMap.fromIterable(squads, key: (s) => s.name, value: (s) => s);
    _coachMap =
        HashMap.fromIterable(coaches, key: (c) => c.nafName, value: (c) => c);
  }

  Squad getSquad(String squadName) {
    return _squadMap[squadName];
  }

  Coach getCoach(String nafName) {
    return _coachMap[nafName];
  }

  static Tournament getExampleTournament() {
    String name = "Amorical Cup";

    List<Squad> squads = [
      Squad("The Tragically Hit",
          ["natsirtdm", "stimme", "genghis", "doomington"], 3, 1, 0, 7, true),
      Squad("Strange Brew", ["hammer16", "grant85", "tlawson", "kikurasis"], 2,
          2, 0, 6, false),
      Squad("Waterlosers", ["iniq", "SheepNine", "catleesi", "Bloodbombers"], 1,
          3, 0, 2, false),
      Squad(
          "Grand River 'Eh' Team",
          ["KidRichard", "seanh1986", "L3athalK", "Duke_of_Edmund"],
          4,
          0,
          0,
          8,
          false)
    ];

    // Create coaches
    var rng = new Random();

    List<Coach> coaches = [];

    squads.forEach((squad) {
      squad.coaches.forEach((nafName) {
        int wins = rng.nextInt(4);
        int ties = rng.nextInt(4 - wins);
        int losses = 4 - wins - ties;

        int points = wins * 5 + ties * 2;

        int tds = rng.nextInt(4 * 2);
        int cas = rng.nextInt(4 * 2);

        bool stunty = rng.nextBool();

        Race race = RaceUtils.randomRace(rng);

        coaches.add(Coach(nafName, squad.name(), "", race, wins, ties, losses,
            points, tds, cas, stunty));
      });
    });

    Tournament t = Tournament(name, squads, coaches);
    return t;
  }
}
