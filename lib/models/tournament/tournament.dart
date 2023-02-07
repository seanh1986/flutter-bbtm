import 'dart:collection';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

enum Authorization {
  Unauthorized,
  HomeCoach,
  AwayCoach,
  HomeCaptain,
  AwayCaptain,
  Admin,
}

enum TieBreaker {
  OppScore,
  Td,
  Cas,
  TdDiff,
  CasDiff,
}

class Tournament {
  late final TournamentInfo info;

  late final FirstRoundMatchingRule firstRoundMatchingRule;
  late final bool useSquads;

  // Key: squad name, Value: Idx in squad list
  HashMap<String, int> _squadIdxMap = new HashMap<String, int>();
  List<Squad> _squads = [];

  // Key: nafName, Value: Idx in coach list
  HashMap<String, int> _coachIdxMap = new HashMap<String, int>();
  List<Coach> _coaches = [];

  List<SquadRound> squadRounds = [];
  List<CoachRound> coachRounds = [];

  List<TieBreaker> tieBreakers = [
    TieBreaker.OppScore,
    TieBreaker.Td,
    TieBreaker.Cas
  ];

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

  void updateCoaches(List<Coach> coaches) {
    _coaches = coaches;
    _syncSquadsAndCoaches();
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

  int curRoundNumber() {
    return coachRounds.length;
  }

  // Try to process round (i.e., populate coaches with results)
  bool processRound() {
    if (coachRounds.isEmpty) {
      return true;
    }

    CoachRound round = coachRounds.last;
    if (round.matches.any((m) => !m.hasResult())) {
      return false;
    }

    // Avoid duplicates (TODO: do better)
    if (coachRounds.length == _coaches.first.matches.length) {
      return false;
    }

    round.matches.forEach((m) {
      Coach? homeCoach = getCoach(m.homeNafName);
      Coach? awayCoach = getCoach(m.awayNafName);

      // Update Matches
      homeCoach?.matches.add(m);
      awayCoach?.matches.add(m);

      // Overwrite records
      homeCoach?.overwriteRecord(info);
      awayCoach?.overwriteRecord(info);
    });

    return true;
  }

  void reProcessAllRounds() {
    // Clear all coach matchups
    _coaches.forEach((c) {
      c.matches.clear();
    });

    // Update matches for each coach
    coachRounds.forEach((r) {
      if (r.matches.any((m) => !m.hasResult())) {
        return;
      }

      r.matches.forEach((m) {
        Coach? homeCoach = getCoach(m.homeNafName);
        Coach? awayCoach = getCoach(m.awayNafName);

        // Update Matches
        homeCoach?.matches.add(m);
        awayCoach?.matches.add(m);
      });

      // Check for byes
      _coaches.forEach((c) {
        if (!r.hasMatchForPlayer(c)) {
          c.matches.add(CoachMatchup(-1, c.nafName, CoachMatchup.Bye));
        }
      });
    });

    // Overwrite records
    _coaches.forEach((c) {
      c.overwriteRecord(info);
    });

    // Update opponent score
    _coaches.forEach((c) {
      c.updateOppScoreAndTieBreakers(this);
    });
  }

  // Increment to next round by updating the coach/squad rounds
  bool updateRound(RoundMatching matchups) {
    int newRound = matchups.round();

    if (newRound != curRoundNumber() + 1) {
      debugPrint('Failed to update round: Round numbers do not coincide');
      return false;
    }

    if (useSquads) {
      SquadRound squadRound = SquadRound.fromRoundMatching(matchups);
      if (squadRound.getMatches().isEmpty) {
        debugPrint('Failed to update round: Matches list is empty');
        return false;
      }

      squadRounds.add(squadRound);

      // TODO: Update coaches too
    } else {
      CoachRound round = CoachRound.fromRoundMatching(matchups);
      if (round.getMatches().isEmpty) {
        debugPrint('Failed to update round: Matches list is empty');
        return false;
      }

      coachRounds.add(round);
    }

    return true;
  }

  Authorization getMatchAuthorization(CoachMatchup matchup, AuthUser authUser) {
    // Check if Admin
    if (isUserAdmin(authUser)) {
      return Authorization.Admin;
    }

    // TODO: Check if squad captain

    // User is in matchup
    if (matchup.awayNafName.toLowerCase() == authUser.nafName?.toLowerCase()) {
      return Authorization.AwayCoach;
    } else if (matchup.homeNafName.toLowerCase() ==
        authUser.nafName?.toLowerCase()) {
      return Authorization.HomeCoach;
    }

    return Authorization.Unauthorized;
  }

  bool isUserAdmin(AuthUser authUser) {
    return authUser.user?.email != null &&
        info.organizers.any((e) => e.email == authUser.user?.email);
  }

  Tournament.fromJson(TournamentInfo info, Map<String, dynamic> json) {
    this.info = info;

    final tUseSquads = json['use_squads'] as bool?;
    this.useSquads = tUseSquads != null ? tUseSquads : false;

    final tFirstRoundMatching = json['first_round_matching'] as String?;
    this.firstRoundMatchingRule = SwissPairings.parseFirstRoundMatchingName(
        tFirstRoundMatching != null ? tFirstRoundMatching : "");

    final tCoaches = json['coaches'] as List<dynamic>?;
    if (tCoaches != null) {
      for (int i = 0; i < tCoaches.length; i++) {
        addCoach(Coach.fromJson(i, tCoaches[i] as Map<String, dynamic>));
      }
    }

    final tSquads = json['squads'] as List<dynamic>?;
    if (tSquads != null) {
      for (int i = 0; i < tSquads.length; i++) {
        addSquad(Squad.fromJson(tSquads[i] as Map<String, dynamic>));
      }
    }

    final tCoachRounds = json['coach_rounds'] as List<dynamic>?;
    if (tCoachRounds != null) {
      for (int i = 0; i < tCoachRounds.length; i++) {
        coachRounds
            .add(CoachRound.fromJson(tCoachRounds[i] as Map<String, dynamic>));
      }
    }

    reProcessAllRounds();
    _syncSquadsAndCoaches();
  }

  Map<String, dynamic> toJson() => {
        'use_squads': useSquads,
        'first_round_matching':
            SwissPairings.getFirstRoundMatchingName(firstRoundMatchingRule),
        'coaches': _coaches.map((e) => e.toJson()).toList(),
        'squads': _squads.map((e) => e.toJson()).toList(),
        'squad_rounds': squadRounds.map((e) => e.toJson()).toList(),
        'coach_rounds': coachRounds.map((e) => e.toJson()).toList(),
      };

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

  Tournament.fromCanadianOpen() {
    info = TournamentInfo(
        id: "X0qh35qbzPhBQKBb6y6c",
        name: "Canadian Open",
        location: "Waterloo, Ontario",
        dateTimeStart: DateTime.utc(2023, 2, 10),
        dateTimeEnd: DateTime.utc(2023, 2, 11));

    info.scoringDetails.winPts = 5;
    info.scoringDetails.tiePts = 3;
    info.scoringDetails.lossPts = 1;

    const htmlDetailsWeather = r"""
<p><u><strong>2. Howling Winds</strong></u><br />
The fans are shivering in the stands as a ferocious gale blows steadily down the pitch. Any pass attempts have<br />
an additional -1 modifier. Each player rolls a D6 (re-rolling ties) &ndash; the wind is blowing down the pitch towards the losing<br />
player&rsquo;s End Zone. Whenever the ball scatters for a kick-off or inaccurate pass, it will be blown down the pitch. Before making<br />
the Scatter roll, place the Throw-in template over the ball so that the 3-4 result is pointing in the same direction as the wind,<br />
then roll a D6 and move the ball one space in the corresponding direction. Repeat this a second time, then scatter the ball as<br />
normal.</p>

<p><u><strong>3.&nbsp;Freezing</strong></u><br />
A sudden cold snap turns the ground as hard as granite (and not the &lsquo;astro&rsquo; variety that players are used to). Whenever<br />
a player is Knocked Down, add 1 to the result of the Armour roll.</p>

<p><u><strong>4-10. Brisk</strong></u><br />
It&rsquo;s rather chilly, but it is as close to perfect Blood Bowl weather as you can hope for at this time of year! This counts as a<br />
&lsquo;Nice&rsquo; result for purposes of the Changing Weather result on the Kick-off table.</p>

<p><u><strong>11. Heavy Snow</strong></u><br />
Visibility is low, it&rsquo;s slippery underfoot and it&rsquo;s impossible to spot tripping hazards, making it very difficult indeed<br />
to block effectively. Whenever a player makes a Blitz Action, their ST is reduced by 1 for the duration of that Action.</p>

<p><u><strong>12. Blizzard</strong></u><br />
Between the snow, the wind and the icy ground, it is a miracle the game&rsquo;s still in progress! Any player attempting to<br />
move an extra square (GFI) will slip and be Knocked Down on a roll of 1-2, and only Quick or Short Passes can be attempted.</p>
    """;
    info.detailsWeather = htmlDetailsWeather.toString();

    const htmlDetailSpecialRules = r"""
<p><strong>Norse</strong> teams get <u>+1 dedicated fans</u> at no cost as this is their turf.</p>

<p>Teams MUST be painted to <u>3 colour minimum</u>. There will be penalties for unpainted figures or teams at TO discretion.</p>

<p>After building your roster, <u>pick a player to be Captain</u>, they get PRO for FREE if you have same Captain in both the Canadian Open AND Icebowl (UNLESS you bring the same race to both tournaments - in that instance they get Bone Head)</p>

<p>In general if they cost the same, and have the same stats, minor skill or skill access differences are inconsequential.</p>

<ul>
	<li>Goblin or Troll from Orc, Goblin, Chaos Pact or Underworld, Snotling</li>
	<li>Skaven Lineman from Skaven, Chaos Pact or Underworld</li>
	<li>Minotaur from Chaos, Chaos Dwarf, Chaos Pact</li>
	<li>Treeman from Halfling, Wood Elf.</li>
	<li>Ogre from Human, Chaos Pact, Ogres</li>
</ul>

<p>There are <u>three exceptions</u> that are not allowed. This is for fluff reasons:</p>

<ul>
	<li>Dwarf &amp; Chaos Dwarf blocker</li>
	<li>High &amp; Dark Elf blitzer</li>
	<li>High &amp; Dark Elf lineman</li>
</ul>

<p><u>Hobby Bonus</u>:</p>

<ul>
	<li>You may <u>NOT</u> purchase assistant coaches or cheerleaders.</li>
	<li>If you have a coach model painted +1 assistant coach</li>
	<li>You MUST have a coach model to argue the call!!!</li>
	<li>If you have a cheerleader model painted +1 cheerleader (doesnt need to be female/pom poms)<br />
	A mascot can replace one or other @ TO discretion</li>
	<li>Max of 1 each, except stunties can have 2 each</li>
	<li>These do&nbsp;not cost any gold.</li>
</ul>
    """;
    info.detailsSpecialRules = htmlDetailSpecialRules.toString();

    info.organizers
        .add(OrganizerInfo("thecanadianopen@gmail.com", "grant85", true));

    info.organizers
        .add(OrganizerInfo("huberman.sean@gmail.com", "seanh1986", false));

    firstRoundMatchingRule = FirstRoundMatchingRule.MatchRandom;
    useSquads = false;

    int id = -1;
    addCoach(Coach(
        "seanh1986", "", "Sean", Race.NecromanticHorror, "Sean Team", 23461));
    addCoach(
        Coach("grant85", "", "Grant", Race.DaemonOfKhorne, "Grant Team", 6482));
    addCoach(
        Coach("hammer16", "", "Chris H", Race.Ogre, "Chris H Team", 20377));
    addCoach(Coach("Duke_of_Edmund", "", "Andew W", Race.ShamblingUndead,
        "Andrew Team", 27220));
    addCoach(Coach(
        "Grither", "", "Bryan T", Race.ChaosDwarf, "Bryan T Team", 10904));
    addCoach(
        Coach("L3athalK", "", "Leathan", Race.Amazon, "Leathan Team", 7465));
    addCoach(Coach(
        "KidRichard", "", "Derek T", Race.Snotling, "Derek T Team", 24415));
    addCoach(
        Coach("delevus", "", "Matt V", Race.Vampire, "Vanderby Team", 9884));
    addCoach(
        Coach("Stimme", "", "Alex W", Race.TombKings, "Alex W Team", 17245));
    addCoach(Coach("Manz62", "", "Manu", Race.Slann, "Manu Team", 9753));
    addCoach(Coach(
        "Buffalo_Chris", "", "Buffalo", Race.WoodElf, "Buffalo Team", 5624));
    addCoach(Coach("AviD", "", "Avi", Race.HighElf, "Avi Team", 25207));
    addCoach(
        Coach("runki_khrum", "", "Colin", Race.Skaven, "Colin Team", 6780));
    addCoach(Coach("TrevCraig", "", "Trev", Race.Goblin, "Tev Team", 23648));
  }

  // factory Tournament.fromXml(XmlDocument xml, TournamentInfo info) {
  //   List<Squad> squads = [];
  //   HashMap<String, int> squadMap = new HashMap<String, int>();

  //   List<Coach> coaches = [];
  //   HashMap<String, int> coachMap = new HashMap<String, int>();

  //   HashMap<int, String> teamIdToNafName = new HashMap<int, String>();

  //   final tournamentTag = xml.findAllElements('tournament').first;

  //   // Find out about different group modes and their scoring!
  //   int groupMode =
  //       int.parse(tournamentTag.getElement("groupmode")?.text ?? "0");
  //   bool useSquads = groupMode == 1;

  //   int groupScoreMode =
  //       int.parse(tournamentTag.getElement("groupscore")?.text ?? "0");

  //   SquadScoreMode squadScoreMode = Squad.getSquadScoreMode(groupScoreMode);

  //   int curRoundNumber =
  //       int.parse(tournamentTag.getElement("currentround")?.text ?? "0");

  //   double winValue =
  //       double.parse(tournamentTag.getElement("win")?.text ?? "0.0");

  //   double tieValue =
  //       double.parse(tournamentTag.getElement("draw")?.text ?? "0.0");

  //   double lossValue =
  //       double.parse(tournamentTag.getElement("loss")?.text ?? "0.0");

  //   if (useSquads) {
  //     // List of squads
  //     final groupTags = tournamentTag.findAllElements('group');

  //     for (var g in groupTags) {
  //       String squadName = g.text;

  //       int idx = squads.length;

  //       squads.add(Squad(squadName));
  //       squadMap.putIfAbsent(squadName, () => idx);
  //     }
  //   }

  //   // List of teams
  //   final teamsTags = xml.findAllElements('team');

  //   for (var t in teamsTags) {
  //     int id = int.parse(t.getAttribute('id') ?? "0");

  //     String teamName = t.getElement('teamname')!.text;
  //     String coachName = t.getElement('coach')!.text;
  //     String nafName = t.getElement('nafname')!.text;
  //     int nafNumber = int.parse(t.getElement('nafnumber')!.text);
  //     String race = t.getElement('nafrace')!.text;
  //     String squadName = t.getElement('group')!.text;

  //     teamIdToNafName.putIfAbsent(id, () => nafName);

  //     Coach c = new Coach(id, nafName, squadName, coachName,
  //         RaceUtils.getRace(race), teamName, nafNumber);

  //     int idx = coaches.length;

  //     coaches.add(c);

  //     coachMap.putIfAbsent(c.nafName, () => idx);

  //     if (useSquads) {
  //       int? idx = squadMap[squadName];
  //       Squad? squad = idx != null ? squads[idx] : null;
  //       squad!.addCoach(c);
  //     }
  //   }

  //   List<CoachRound> coachRounds = [];

  //   final roundsTags = xml.findAllElements('round');
  //   for (var r in roundsTags) {
  //     int roundNumber = int.parse(r.getAttribute('number') ?? "0");

  //     bool isCurrentRound = roundNumber == curRoundNumber;

  //     List<CoachMatchup> coachMatchups = [];

  //     final gamesTags = r.findAllElements('game');
  //     for (var g in gamesTags) {
  //       int tableNumber = int.parse(g.getAttribute('table') ?? "0");
  //       int team1 = int.parse(g.getElement('team1')!.text); // team id
  //       int team2 = int.parse(g.getElement('team2')!.text); // team id
  //       int td1 = int.parse(g.getElement('td1')!.text);
  //       int td2 = int.parse(g.getElement('td2')!.text);
  //       int cas1 = int.parse(g.getElement('cas1')!.text);
  //       int cas2 = int.parse(g.getElement('cas2')!.text);

  //       String? nafName1 = teamIdToNafName[team1];
  //       int? idx1 = coachMap[nafName1];
  //       Coach? coach1 = idx1 != null ? coaches[idx1] : null;

  //       String? nafName2 = teamIdToNafName[team2];
  //       int? idx2 = coachMap[nafName2];
  //       Coach? coach2 = idx2 != null ? coaches[idx2] : null;

  //       if (coach1 == null || coach2 == null) {
  //         continue;
  //       }

  //       CoachMatchup matchup = new CoachMatchup(
  //           roundNumber, tableNumber, coach1.nafName, coach2.nafName);
  //       coachMatchups.add(matchup);

  //       if (isCurrentRound) {
  //         continue;
  //       }

  //       ReportedMatchResult result = ReportedMatchResult();
  //       result.homeTds = td1;
  //       result.homeCas = cas1;
  //       result.awayTds = td2;
  //       result.awayCas = cas2;

  //       matchup.homeReportedResults = result;
  //       matchup.awayReportedResults = result;

  //       coach1.addTds(td1);
  //       coach1.addCas(cas1);

  //       coach2.addTds(td2);
  //       coach2.addCas(cas2);

  //       if (td1 > td2) {
  //         coach1.addWin();
  //         coach2.addLoss();
  //       } else if (td2 > td1) {
  //         coach1.addLoss();
  //         coach2.addWin();
  //       } else {
  //         coach1.addTie();
  //         coach2.addTie();
  //       }
  //     }

  //     // Update Coach Rounds
  //     CoachRound coachRound = new CoachRound(roundNumber, coachMatchups);

  //     coachRounds.add(coachRound);
  //   }

  //   // Update coach points
  //   coaches.forEach((Coach coach) {
  //     coach.calculatePoints(winValue, tieValue, lossValue);
  //   });

  //   if (useSquads) {
  //     List<SquadRound> squadRounds =
  //         _getSquadRounds(coachRounds, squadMap, squads, coachMap, coaches);

  //     // Update squad points
  //     squads.forEach((Squad squad) {
  //       squad.calculatePoints(squadScoreMode, coachMap, coaches);
  //       squad.calculateWinsTiesLosses(squadRounds);
  //     });

  //     return new Tournament.squads(
  //       info,
  //       // xml,
  //       curRoundNumber,
  //       squads,
  //       coaches,
  //       squadRounds,
  //       coachRounds,
  //     );
  //   } else {
  //     return new Tournament.noSquads(
  //       info,
  //       // xml,
  //       curRoundNumber,
  //       coaches,
  //       coachRounds,
  //     );
  //   }
  // }

// // Squad constructor
//   Tournament.squads(this.info, this.curRoundNumber, this._squads, this._coaches,
//       this.squadRounds, this.coachRounds) {
//     useSquads = true;

//     _syncSquadsAndCoaches();
//   }

//   // Non-squad constructor
//   Tournament.noSquads(
//       this.info, this.curRoundNumber, this._coaches, this.coachRounds) {
//     useSquads = false;

//     _syncSquadsAndCoaches();
//   }

  // static List<SquadRound> _getSquadRounds(
  //     List<CoachRound> coachRounds,
  //     HashMap<String, int> squadMap,
  //     List<Squad> squads,
  //     HashMap<String, int> coachMap,
  //     List<Coach> coaches) {
  //   List<SquadRound> squadRounds = [];

  //   for (CoachRound cr in coachRounds) {
  //     SquadRound squadRound =
  //         _getSquadRound(cr, squadMap, squads, coachMap, coaches);
  //     squadRounds.add(squadRound);
  //   }

  //   return squadRounds;
  // }

  // static SquadRound _getSquadRound(CoachRound cr, HashMap<String, int> squadMap,
  //     List<Squad> squads, HashMap<String, int> coachMap, List<Coach> coaches) {
  //   int roundNumber = cr.round();

  //   List<SquadMatchup> squadMatchupList = [];

  //   // HomeSquad to list of coach matchups
  //   Map<String, List<CoachMatchup>> groups = groupBy(
  //       cr.matches,
  //       (CoachMatchup cm) =>
  //           getHomeSquadNameFromCoachMatchup(cm, coachMap, coaches));

  //   int tableNum = 1;
  //   for (String homeSquadName in groups.keys) {
  //     List<CoachMatchup>? coachMatchups = groups[homeSquadName];
  //     if (coachMatchups == null || coachMatchups.isEmpty) {
  //       continue;
  //     }

  //     int? homeSquadIdx = squadMap[homeSquadName];
  //     Squad? homeSquad = homeSquadIdx != null ? squads[homeSquadIdx] : null;

  //     int? awayCoachIdx = coachMap[coachMatchups.first.homeNafName];
  //     String awaySquadName =
  //         awayCoachIdx != null ? coaches[awayCoachIdx].squadName : "";

  //     int? awaySquadIdx = squadMap[awaySquadName];
  //     Squad? awaySquad = awaySquadIdx != null ? squads[awaySquadIdx] : null;
  //     if (homeSquad == null || awaySquad == null) {
  //       continue;
  //     }

  //     SquadMatchup squadMatchup = new SquadMatchup(
  //         roundNumber, tableNum, homeSquad.name(), awaySquad.name());

  //     squadMatchup.coachMatchups = coachMatchups;

  //     squadMatchupList.add(squadMatchup);

  //     tableNum++;
  //   }

  //   return new SquadRound(roundNumber, squadMatchupList);
  // }
//
  // static String getHomeSquadNameFromCoachMatchup(
  //     CoachMatchup cm, HashMap<String, int> coachMap, List<Coach> coaches) {
  //   int? coachIdx = coachMap[cm.homeNafName];
  //   return coachIdx != null ? coaches[coachIdx].squadName : "";
  // }
}
