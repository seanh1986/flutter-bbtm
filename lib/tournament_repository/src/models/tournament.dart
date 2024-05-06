import 'dart:collection';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
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
  late TournamentInfo info;

  // Key: squad name (lowercase), Value: Idx in squad list
  HashMap<String, int> _squadIdxMap = new HashMap<String, int>();
  List<Squad> _squads = [];

  // Key: nafName (lowercase), Value: Idx in coach list
  HashMap<String, int> _coachIdxMap = new HashMap<String, int>();
  List<Coach> _coaches = [];

  List<SquadRound> squadRounds = [];
  List<CoachRound> coachRounds = [];

  void addSquad(Squad s) {
    int idx = _squads.length;
    _squads.add(s);
    _squadIdxMap.putIfAbsent(s.name().trim().toLowerCase(), () => idx);
  }

  Squad? getSquad(String squadName) {
    int? idx = _squadIdxMap[squadName.trim().toLowerCase()];
    return idx != null ? _squads[idx] : null;
  }

  List<Squad> getSquads() {
    return _squads;
  }

  void addCoach(Coach c) {
    int idx = _coaches.length;
    _coaches.add(c);
    _coachIdxMap.putIfAbsent(c.name().toLowerCase().trim(), () => idx);
  }

  void updateCoaches(List<Coach> newCoaches, List<RenameNafName> renames) {
    // Update coach list
    _coaches = List.from(newCoaches);

    // Rename all coaches if necesssary
    renames.forEach((r) {
      // If rename was already applied
      Coach? coach = newCoaches.firstWhereOrNull((element) =>
          element.nafName.toLowerCase() == r.newNafName.toLowerCase());

      // Check if rename was not yet applied -> apply it
      if (coach == null) {
        coach = newCoaches.firstWhereOrNull((element) =>
            element.nafName.toLowerCase() == r.oldNafName.toLowerCase());

        if (coach != null) {
          coach.nafName = r.newNafName;
        }
      }

      if (coach != null) {
        coachRounds.forEach((cr) {
          cr.matches.forEach((m) {
            if (m.isHome(r.oldNafName)) {
              m.homeNafName = coach!.nafName;
            } else if (m.isAway(r.oldNafName)) {
              m.awayNafName = coach!.nafName;
            }
          });
        });
      }
    });

    _syncSquadsAndCoaches();
  }

  Coach? getCoach(String nafName) {
    int? idx = _coachIdxMap[nafName.trim().toLowerCase()];
    return idx != null ? _coaches[idx] : null;
  }

  Squad? getCoachSquad(String nafName) {
    if (!useSquads() && !useSquadsForInitOnly()) {
      return null;
    }

    Coach? coach = getCoach(nafName);
    return coach != null ? getSquad(coach.squadName) : null;
  }

  bool areSameSquad(String nafName1, String nafName2) {
    Squad? squad1 = getCoachSquad(nafName1);
    Squad? squad2 = getCoachSquad(nafName2);

    if (squad1 == null || squad2 == null) {
      return false;
    }

    return squad1.name().toLowerCase() == squad2.name().toLowerCase();
  }

  bool isSquadCaptainFor(String captain, String memberNafName) {
    Squad? squad1 = getCoachSquad(captain);
    Squad? squad2 = getCoachSquad(memberNafName);

    if (squad1 == null || squad2 == null) {
      return false;
    }

    return squad1.name().toLowerCase() == squad2.name().toLowerCase();
  }

  List<Coach> getCoaches() {
    return _coaches;
  }

  int curRoundNumber() {
    return coachRounds.length;
  }

  int curRoundIdx() {
    return coachRounds.length - 1;
  }

  bool isLocked() {
    return info.locked;
  }

  bool useSquads() {
    return info.squadDetails.type == SquadUsage.SQUADS;
  }

  bool useSquadsForInitOnly() {
    return info.squadDetails.type == SquadUsage.INDIVIDUAL_USE_SQUADS_FOR_INIT;
  }

  bool useSquadVsSquad() {
    if (!useSquads()) {
      return false;
    }

    if (info.squadDetails.matchMaking ==
        SquadMatchMaking.FORCE_SQUAD_VS_SQUAD_W_BYES) {
      return true;
    } else if (info.squadDetails.matchMaking ==
        SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES) {
      // If # active squads is divisble by 2, then valid
      int activeSquads = _squads.where((s) => s.isActive(this)).length;
      return activeSquads % 2 == 0;
    }

    return false;
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

      if (useSquadVsSquad()) {
        squadRounds.add(SquadRound.fromCoachRound(this, round));
      }
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
      r.matches.forEach((m) {
        if (!m.hasResult()) {
          return;
        }

        Coach? homeCoach = getCoach(m.homeNafName);
        Coach? awayCoach = getCoach(m.awayNafName);

        // Update Matches
        homeCoach?.matches.add(m);
        awayCoach?.matches.add(m);
      });

      // Check for byes
      _coaches.forEach((c) {
        if (!r.hasMatchForPlayer(c)) {
          c.matches.add(CoachMatchup(c.nafName, CoachMatchup.Bye));
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

      if (useSquadVsSquad()) {
        coachRounds.forEach((r) {
          squadRounds.add(SquadRound.fromCoachRound(this, r));
        });
      }
    }
  }

  // Increment to next round by updating the coach/squad rounds
  bool updateRound(RoundMatching matchups) {
    int newRound = matchups.round();

    if (newRound != curRoundNumber() + 1) {
      debugPrint('Failed to update round: Round numbers do not coincide');
      return false;
    }

    if (useSquads() &&
        matchups.getMatches().isNotEmpty &&
        matchups.getMatches().first is SquadMatchup) {
      SquadRound squadRound = SquadRound.fromRoundMatching(matchups);
      if (squadRound.getMatches().isEmpty) {
        debugPrint('Failed to update round: Matches list is empty');
        return false;
      }

      squadRounds.add(squadRound);

      squadRound.matches.forEach((squadMatch) {
        squadMatch.coachMatchups.forEach((coachMatch) {});
      });
    }

    CoachRound round = CoachRound.fromRoundMatching(matchups);
    if (round.getMatches().isEmpty) {
      debugPrint('Failed to update round: Matches list is empty');
      return false;
    }

    coachRounds.add(round);

    return true;
  }

  Authorization getMatchAuthorization(CoachMatchup matchup, User user) {
    // Check if Admin
    if (isUserAdmin(user)) {
      return Authorization.Admin;
    }

    String nafName = user.getNafName();

    // User is in matchup
    if (matchup.isAway(nafName)) {
      return Authorization.AwayCoach;
    } else if (matchup.isHome(nafName)) {
      return Authorization.HomeCoach;
    }

    if (useSquads()) {
      if (isSquadCaptainFor(nafName, matchup.awayNafName)) {
        return Authorization.AwayCaptain;
      } else if (isSquadCaptainFor(nafName, matchup.homeNafName)) {
        return Authorization.HomeCaptain;
      }
    }

    return Authorization.Unauthorized;
  }

  Authorization getSquadMatchAuthorization(SquadMatchup matchup, User user) {
    // Check if Admin
    if (isUserAdmin(user)) {
      return Authorization.Admin;
    }

    String nafName = user.getNafName();
    Squad? squad = getCoachSquad(nafName);
    if (squad == null) {
      return Authorization.Unauthorized;
    }

    String squadName = squad.name();

    if (matchup.isAway(squadName)) {
      return Authorization.AwayCoach;
    } else if (matchup.isHome(squadName)) {
      return Authorization.HomeCoach;
    }

    return Authorization.Unauthorized;
  }

  bool isUserAdmin(User user) {
    return info.organizers.any((e) => e.email == user.getEmail());
  }

  bool isEmpty() {
    return info.id.isEmpty;
  }

  Tournament.empty()
      : this.fromJson(TournamentInfo.fromJson("0", Map<String, dynamic>()),
            Map<String, dynamic>());

  Tournament.fromJson(TournamentInfo info, Map<String, dynamic> json) {
    this.info = info;

    final tCoaches = json['coaches'] as List<dynamic>?;
    if (tCoaches != null) {
      for (int i = 0; i < tCoaches.length; i++) {
        var coachJson = tCoaches[i] as Map<String, dynamic>;
        addCoach(Coach.fromJson(i, coachJson));
      }
    }

    final tCoachRounds = json['coach_rounds'] as List<dynamic>?;
    if (tCoachRounds != null) {
      for (int i = 0; i < tCoachRounds.length; i++) {
        var coachRoundJson = tCoachRounds[i] as Map<String, dynamic>;
        coachRounds.add(CoachRound.fromJson(coachRoundJson, info));
      }
    }

    _syncSquadsAndCoaches();
    reProcessAllRounds();
  }

  Map<String, dynamic> toJson() => {
        'coaches': _coaches.map((e) => e.toJson()).toList(),
        'coach_rounds': coachRounds.map((e) => e.toJson()).toList(),
      };

  void _syncSquadsAndCoaches() {
    // Sync Squads
    _squads.clear();
    _coaches.groupListsBy((c) => c.squadName).forEach((key, value) {
      _squads.add(Squad(key, value.map((e) => e.nafName).toList()));
    });

    // Update squad map
    _squadIdxMap.clear();
    for (int i = 0; i < _squads.length; i++) {
      Squad s = _squads[i];
      _squadIdxMap.putIfAbsent(s.name().toLowerCase().trim(), () => i);
    }

    /// Update coach map
    _coachIdxMap.clear();
    for (int i = 0; i < _coaches.length; i++) {
      Coach c = _coaches[i];
      _coachIdxMap.putIfAbsent(c.name().toLowerCase().trim(), () => i);
    }

    // TODO: Eventually logic can be moved elsewhere
    // Update rosters
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
          if (c.gamesPlayed() <= 0) {
            return;
          }

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

    List<Coach> coachResults =
        List.from(_coaches.where((c) => c.gamesPlayed() > 0));
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
}
