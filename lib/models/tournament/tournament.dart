import 'dart:collection';
import 'package:bbnaf/repos/auth/auth_user.dart';
import 'package:bbnaf/screens/admin/edit_participants_widget.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/swiss/swiss.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

enum Authorization {
  Unauthorized,
  HomeCoach,
  AwayCoach,
  HomeCaptain,
  AwayCaptain,
  Admin,
}

class Tournament {
  late final TournamentInfo info;

  late final FirstRoundMatchingRule firstRoundMatchingRule;
  // late final bool useSquads;

  // Key: squad name, Value: Idx in squad list
  HashMap<String, int> _squadIdxMap = new HashMap<String, int>();
  List<Squad> _squads = [];

  // Key: nafName, Value: Idx in coach list
  HashMap<String, int> _coachIdxMap = new HashMap<String, int>();
  List<Coach> _coaches = [];

  List<SquadRound> squadRounds = [];
  List<CoachRound> coachRounds = [];

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

  void updateCoaches(List<Coach> newCoaches, List<RenameNafName> renames) {
    // Update coach list
    _coaches = List.from(newCoaches);

    // Rename all coaches if necesssary
    renames.forEach((r) {
      Coach? coach = newCoaches.firstWhereOrNull((element) =>
          element.nafName.toLowerCase() == r.newNafName.toLowerCase());

      if (coach != null) {
        coachRounds.forEach((cr) {
          cr.matches.forEach((m) {
            if (m.isHome(r.oldNafName)) {
              m.homeNafName = coach.nafName;
            } else if (m.isAway(r.oldNafName)) {
              m.awayNafName = coach.nafName;
            }
          });
        });
      }
    });

    _syncSquadsAndCoaches();
  }

  Coach? getCoach(String nafName) {
    int? idx = _coachIdxMap[nafName];
    return idx != null ? _coaches[idx] : null;
  }

  Squad? getCoachSquad(String nafName) {
    if (!useSquads() && !useSquadsForInitOnly()) {
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

  bool useSquads() {
    return info.squadDetails.type == SquadUsage.SQUADS;
  }

  bool useSquadsForInitOnly() {
    return info.squadDetails.type == SquadUsage.INDIVIDUAL_USE_SQUADS_FOR_INIT;
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

    if (useSquads()) {
      _squads.forEach((squad) {
        squad.overwriteRecord(this);
      });
    }

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

    if (useSquads()) {
      // Overwrite records
      _squads.forEach((squad) {
        squad.overwriteRecord(this);
      });

      // Update opponent score
      _squads.forEach((squad) {
        squad.updateOppScoreAndTieBreakers(this);
      });
    }
  }

  // Increment to next round by updating the coach/squad rounds
  bool updateRound(RoundMatching matchups) {
    int newRound = matchups.round();

    if (newRound != curRoundNumber() + 1) {
      debugPrint('Failed to update round: Round numbers do not coincide');
      return false;
    }

    if (useSquads()) {
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

  Tournament.empty()
      : this.fromJson(TournamentInfo.fromJson("0", Map<String, dynamic>()),
            Map<String, dynamic>());

  Tournament.fromJson(TournamentInfo info, Map<String, dynamic> json) {
    this.info = info;

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

    // TODO: Eventually logic can be moved elsewhere
    _coaches.forEach((c) {
      if (c.rosterFileName.isEmpty) {
        c.rosterFileName = info.id + "/" + c.nafName.toLowerCase() + ".pdf";
      }
    });
  }

  XmlDocument generateNafUploadFile() {
    OrganizerInfo mainOrganizer = info.organizers.firstWhere((o) => o.primary);
    DateTime roundTime = info.dateTimeStart;
    print("Start Time: " + DateFormat("y-M-d H:mm").format(roundTime));

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    Map<String, String> nafReportAttribute = {};
    nafReportAttribute.putIfAbsent(
        "xmlns:blo", () => "http://www.bloodbowl.net");

    builder.element("nafReport", attributes: nafReportAttribute, nest: () {
      // Organizer
      builder.element("organizer", nest: mainOrganizer.primary);
      //Coaches
      builder.element("coaches", nest: () {
        _coaches.forEach((c) {
          builder.element("coach", nest: () {
            builder.element("name", nest: c.nafName);
            builder.element("number", nest: c.nafNumber);
            builder.element("team", nest: c.raceName());
          });
        });
      });

      // Matches
      coachRounds.forEach((cr) {
        String roundTimeStr = DateFormat("y-M-d H:mm").format(roundTime);

        print("Round " + cr.round().toString() + " time: " + roundTimeStr);

        // For each Match
        cr.matches.forEach((m) {
          Coach c1 = getCoach(m.homeNafName)!;
          Coach c2 = getCoach(m.awayNafName)!;

          ReportedMatchResultWithStatus r = m.getReportedMatchStatus();

          builder.element("game", nest: () {
            builder.element("timeStamp", nest: roundTimeStr);
            builder.element("playerRecord", nest: () {
              builder.element("name", nest: c1.nafName);
              builder.element("number", nest: c1.nafNumber);
              builder.element("teamRating", nest: 100);
              builder.element("touchDowns", nest: r.homeTds);
              builder.element("badlyHurt", nest: r.homeCas);
            });
            builder.element("playerRecord", nest: () {
              builder.element("name", nest: c2.nafName);
              builder.element("number", nest: c2.nafNumber);
              builder.element("teamRating", nest: 100);
              builder.element("touchDowns", nest: r.awayTds);
              builder.element("badlyHurt", nest: r.awayCas);
            });
          });
        });

        roundTime = roundTime.add(Duration(hours: 2, minutes: 30));
      });
    });

    XmlDocument xml = builder.buildDocument();
    return xml;
  }

  XmlDocument generateGlamFile() {
    OrganizerInfo mainOrganizer = info.organizers.firstWhere((o) => o.primary);

    List<Coach> coachResults = List.from(_coaches);
    // Sort in descending order
    coachResults.sort((a, b) =>
        -1 *
        a
            .pointsWithTieBreakersBuiltIn()
            .compareTo(b.pointsWithTieBreakersBuiltIn()));

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    Map<String, String> glamAttribute = {};
    glamAttribute.putIfAbsent("xmlns:blo", () => "http://www.glamts.com");

    builder.element("glam", attributes: glamAttribute, nest: () {
      // Tournament
      builder.element("tournament", nest: () {
        builder.element("name", nest: info.name);
        builder.element("location", nest: info.location);
        builder.element("num_games", nest: coachRounds.length);
        builder.element("organizer", nest: mainOrganizer.nafName);
      });
      //Coaches
      builder.element("results", nest: () {
        coachResults.forEach((c) {
          builder.element("nafName", nest: c.nafName);
          builder.element("race", nest: c.raceName());
          builder.element("wins", nest: c.wins());
          builder.element("ties", nest: c.ties());
          builder.element("losses", nest: c.losses());
          builder.element("td_for", nest: c.tds);
          builder.element("td_vs", nest: c.oppTds);
          builder.element("cas_for", nest: c.cas);
          builder.element("cas_vs", nest: c.oppCas);
        });
      });
    });

    XmlDocument xml = builder.buildDocument();
    return xml;
  }

// Tournament.fromIceBowl() {
//     info = TournamentInfo(
//         id: "JxUszJ2tZ3Pw7M7mMgHB",
//         name: "Ice Bowl",
//         location: "Waterloo, Ontario",
//         dateTimeStart: DateTime.utc(2023, 2, 12),
//         dateTimeEnd: DateTime.utc(2023, 2, 12));

//     info.scoringDetails.winPts = 5;
//     info.scoringDetails.tiePts = 3;
//     info.scoringDetails.lossPts = 1;

//     const htmlDetailsWeather = r"""
// <p><u><strong>2. Wind Chill</strong></u><br />
// The cold wind is enough to force some players off the pitch seeking shelter from the cold. At the end of step 1 of the start of drive sequence,<br />
// both coaches roll a d6. Who ever rolls lowest (In the event of a tie both coaches) Randomly select a player on the pitch.<br />
// Remove that player and set them in the reserves box.</p>

// <p><u><strong>3. Freezing Fog</strong></u><br />
// The cold makes hands and fingers numb. - 1 to all Catch, Pick Up, Passing and Interference and Interception rolls.</p>

// <p><u><strong>4-10. Nice</strong></u><br />
// Perfect Blood Bowl Weather.</p>

// <p><u><strong>11. Hail Shower</strong></u><br />
// At the start of each team's turn randomly select one player. They are struck with a giant ball of hail. Make an immediate armour roll.<br />
// If the armour roll is successful, do not make a injury roll. The player is instead placed stunned.<br />
// This will not cause a turn over, even if the player was holding the ball.</p>

// <p><u><strong>12. White Out</strong></u><br />
// The snow is blowing and pass actions can NOT be attempted.<br />
// Additionally a blitz action can not be performed against an opposing player if they are more than 3 squares away.</p>
//     """;
//     info.detailsWeather = htmlDetailsWeather.toString();

//     const htmlDetailsKickOff = r"""
// <p><u><strong>2. Pitch Side Brawl</strong></u><br />
// A fight has broken out in the stands and has spilled onto the pitch. Each coach randomly selects d3 players who are placed stunned.</p>

// <p><u><strong>3. Icicles!</strong></u><br />
// Icicles have formed around the stadium. Each coach randomly selects a player on their team.<br />
// That player may perform the special STAB action once before the end of the drive.</p>

// <p><u><strong>4. Snowballs!</strong></u><br />
// Fans have been hurling snowballs onto the pitch. Each coach randomly selects a player on their team.<br />
// Upon the first activation of that player, the activation immediately ends as the player is scanning the crowd looking for the perpetrator.</p>

// <p><u><strong>5. High Kick</strong></u><br />
// As per normal kick off chart.</p>

// <p><u><strong>6. Cheering Fans</strong></u><br />
// As per normal kick off chart.</p>

// <p><u><strong>7. Brilliant Coaching</strong></u><br />
// As per normal kick off chart.</p>

// <p><u><strong>8. Changing Weather</strong></u><br />
// As per normal kick off chart.</p>

// <p><u><strong>9. Quick Snap</strong></u><br />
// As per normal kick off chart.</p>

// <p><u><strong>10. Snow Drifts</strong></u><br />
// Snow has drifted onto the pitch. If a player if knocked down apply a -1 to the armour roll until the end of this drive.</p>

// <p><u><strong>11. Reckless Rookies</strong></u><br />
// Blood bowl is to alluring for the fans. Each coach immediately gains a Norse Raider linemen.<br />
// Place this new team mate any where in their half, except the wide zones. This may increase the players on the pitch beyond the normal 11.<br />
// At the end of the drive, the referee will eject them from the game.</p>

// <p><u><strong>12. Feast and Revelry</strong></u><br />
// Both teams have enjoyed a pre-match party. All players on both teams gain the Drunkard Trait, if they don't have it already.</p>
//     """;
//     info.detailsKickOff = htmlDetailsKickOff.toString();

//     const htmlDetailSpecialRules = r"""
// <div dir="ltr" align="left">
// <table><colgroup><col width="85" /><col width="26" /><col width="26" /><col width="34" /><col width="23" /><col width="34" /><col width="285" /></colgroup>
// <tbody>
// <tr>
// <td>
// <p dir="ltr">Beer Boar</p>
// </td>
// <td>
// <p dir="ltr">5&nbsp;</p>
// </td>
// <td>
// <p dir="ltr">1&nbsp;</p>
// </td>
// <td>
// <p dir="ltr">3+&nbsp;</p>
// </td>
// <td>
// <p dir="ltr">-&nbsp;</p>
// </td>
// <td>
// <p dir="ltr">6+&nbsp;</p>
// </td>
// <td>
// <p dir="ltr">Dodge, No Hands, Stunty, Titchy, Pick Me Up! Loner(3+) {no loner on Norse teams}</p>
// </td>
// </tr>
// </tbody>
// </table>
// </div>
// <p dir="ltr">Pick Me Up! - At the end of the opposition&rsquo;s team turn, roll a D6 for each Prone, non-Stunned team-mate within three squares of a Standing player with this Trait. On a 5+, the Prone player may immediately stand up.<br /><br /></p>
// <p dir="ltr"><strong>Norse Balls</strong></p>
// <p dir="ltr">Pre Game roll to determine what type of ball your game will have for the entire match:</p>
// <ul>
// <li>1-2 Normal blood bowl ball, regular and covered in blood</li>
// <li>3-4 Hammer of Legend Ball</li>
// <li>5-6 The Runestone Ball</li>
// </ul>
// <p>Hammer of Legend Ball<br /><br />When ever a player attempts to pick up this ball roll a d6 before the agility roll. On a 1 the player is not worthy to pick up the ball. Place the player in the square they occupied before entering the square with the ball. That player's activation ends immediately</p>
// <p dir="ltr">The Runestone Ball</p>
// <p dir="ltr">Whenever a player carrying the Runestone ball declares a Pass action, that player applies an additional -1 modifier when making a Passing Ability test. Additionally, whenever a player carrying the Runestone ball makes an Armour roll against an opposition player, they apply a +1 modifier to the result.</p>
// <p>&nbsp;</p>
// <p><strong>Frozen Lake Blood Bowl Pitch</strong></p>
// <p dir="ltr">Frozen Surface: At the start of the game, the waters of the lake are as solid as astrogranite. The surfaces difficult to find traction on but, once a player does, coming to a stop can be a problem! Players may attempt to Rush one additional time. However, players must apply a -1 modifier to the roll on each Rush attempt after the first.</p>
// <p dir="ltr">Additionally, as the end of each drive, before removing any models, count up the total number of Prone players on the pitch. If the total between both teams is five or more, the Fragmented Surface pitch rules will apply for the remainder of the game.</p>
// <p dir="ltr">Fragmented Surface: All those players hitting the deck have caused a chain reaction of cracks and fissures. The players are going to need to keep their balance to ensure they dont fall over on the uneven surface! Players suffer an additional -1 modifier on Agility tests when they attempt to Dodge, Leap, Jump or land after being thrown.</p>
// <p>&nbsp;</p>

// <p><strong>Norse</strong> teams get <u>+1 dedicated fans</u> at no cost as this is their turf.</p>

// <p>Teams MUST be painted to <u>3 colour minimum</u>. There will be penalties for unpainted figures or teams at TO discretion.</p>

// <p>After building your roster, <u>pick a player to be Captain</u>, they get PRO for FREE if you have same Captain in both the Canadian Open AND Icebowl (UNLESS you bring the same race to both tournaments - in that instance they get Bone Head)</p>

// <p>In general if they cost the same, and have the same stats, minor skill or skill access differences are inconsequential.</p>

// <ul>
// 	<li>Goblin or Troll from Orc, Goblin, Chaos Pact or Underworld, Snotling</li>
// 	<li>Skaven Lineman from Skaven, Chaos Pact or Underworld</li>
// 	<li>Minotaur from Chaos, Chaos Dwarf, Chaos Pact</li>
// 	<li>Treeman from Halfling, Wood Elf.</li>
// 	<li>Ogre from Human, Chaos Pact, Ogres</li>
// </ul>

// <p>There are <u>three exceptions</u> that are not allowed. This is for fluff reasons:</p>

// <ul>
// 	<li>Dwarf &amp; Chaos Dwarf blocker</li>
// 	<li>High &amp; Dark Elf blitzer</li>
// 	<li>High &amp; Dark Elf lineman</li>
// </ul>

// <p><u>Hobby Bonus</u>:</p>

// <ul>
// 	<li>You may <u>NOT</u> purchase assistant coaches or cheerleaders.</li>
// 	<li>If you have a coach model painted +1 assistant coach</li>
// 	<li>You MUST have a coach model to argue the call!!!</li>
// 	<li>If you have a cheerleader model painted +1 cheerleader (doesnt need to be female/pom poms)<br />
// 	A mascot can replace one or other @ TO discretion</li>
// 	<li>Max of 1 each, except stunties can have 2 each</li>
// 	<li>These do&nbsp;not cost any gold.</li>
// </ul>
//     """;
//     info.detailsSpecialRules = htmlDetailSpecialRules.toString();

//     info.organizers
//         .add(OrganizerInfo("thecanadianopen@gmail.com", "grant85", true));

//     info.organizers
//         .add(OrganizerInfo("huberman.sean@gmail.com", "seanh1986", false));

//     firstRoundMatchingRule = FirstRoundMatchingRule.MatchRandom;
//     useSquads = false;

//     addCoach(Coach(
//         "Hammer16", "", "Chris Hamm", Race.BlackOrc, "Hammer16's team", 20377));
//     addCoach(Coach("seanh1986", "", "Sean Huberman", Race.UnderworldDenizens,
//         "seanh1986's team", 23461));
//     addCoach(Coach("Duke_of_Edmund", "", "Andrew Witmer", Race.Unknown,
//         "Duke_of_Edmund's team", 27220));
//     addCoach(Coach("codered", "", "Cody Clerke", Race.ChaosDwarf,
//         "codered's team", 26601));
//     addCoach(Coach("KidRichard", "", "Derek Thompson", Race.Skaven,
//         "KidRichard's team", 24415));
//     addCoach(Coach("sgtsaunders", "", "Paul Saunders", Race.Norse,
//         "sgtsaunders's team", 29936));
//     addCoach(Coach("spazzfist", "", "Craig Thompson-Wood", Race.Norse,
//         "spazzfist's team", 5675));
//     addCoach(Coach("HouseBlackfyre", "", "Sean Cowley", Race.ShamblingUndead,
//         "HouseBlackfyre's team", 28534));
//     addCoach(Coach("resolutespore", "", "Scotty Milne", Race.Goblin,
//         "resolutespore's team", 30637));
//     addCoach(Coach("coachMcGirt", "", "Tanner  Durnin", Race.UnderworldDenizens,
//         "coachMcGirt's team", 28337));
//     addCoach(Coach("drakenspear", "", "Stephen Jarrett", Race.Human,
//         "drakenspear's team", 28841));
//     addCoach(Coach("Frozenflame", "", "Mike Coon", Race.Norse,
//         "Frozenflame's team", 4789));
//     addCoach(Coach("delevus", "", "Matt Vanderby", Race.ImperialNobility,
//         "delevus's team", 9884));
//     addCoach(Coach("TrevCraig", "", "Trevor Craig", Race.ChaosRenegade,
//         "TrevCraig's team", 23648));
//     addCoach(Coach("NotThePornGuy", "", "Ian McKinley", Race.Halfling,
//         "NotThePornGuy's team", 28320));
//     addCoach(Coach("ItsEnZe", "", "Connor Melville", Race.Snotling,
//         "ItsEnZe's team", 31366));
//     addCoach(Coach("Wraithrwinkle", "", "Michael Singerling", Race.Norse,
//         "Wraithrwinkle's team", 34302));
//     addCoach(Coach(
//         "BrainSap", "", "Kent Chapman", Race.Human, "BrainSap's team", 32041));
//     addCoach(Coach("flyingdingle        ", "", "Sol Knicely", Race.Unknown,
//         "flyingdingle        's team", 4244));
//     addCoach(
//         Coach("iniq", "", "Derek Hall", Race.Lizardmen, "iniq's team", 24413));
//     addCoach(Coach("azmodi", "", "Mike Patriarca", Race.ChaosChosen,
//         "azmodi's team", 28531));
//     addCoach(Coach("coachcooper", "", "Mark Cooper", Race.Slann,
//         "coachcooper's team", 28338));
//     addCoach(Coach(
//         "tlawson", "", "Tim Lawson", Race.Nurgle, "tlawson's team", 19205));
//     addCoach(Coach(
//         "mlamont", "", "Mitch Lamont", Race.BlackOrc, "mlamont's team", 33427));
//     addCoach(Coach("lionel_hutz", "", "Christopher Thibert", Race.ChaosDwarf,
//         "lionel_hutz's team", 27461));
//     addCoach(Coach(
//         "Da5id", "", "Chris Poynter", Race.BlackOrc, "Da5id's team", 11292));
//     addCoach(Coach("wererat", "", "Michael  Damecour", Race.Goblin,
//         "wererat's team", 22400));
//     addCoach(Coach("catleesi", "", "Cat Demone", Race.ShamblingUndead,
//         "catleesi's team", 26640));
//     addCoach(Coach("clockwerks77", "", "Adam(D.Hall friend) Stephens",
//         Race.Lizardmen, "clockwerks77's team", 34310));
//   }

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
