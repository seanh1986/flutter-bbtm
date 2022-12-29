import 'dart:core';
import 'dart:math';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/coach_matchup.dart';
import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/squad_matchup.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:flutter/material.dart';

enum FirstRoundMatchingRule {
  MatchRandom, // Random matchups
  MatchRandomAvoidGroup, // Random matchups but do not match up same groups
}

enum RoundPairingError {
  NoError,
  MissingPreviousResults,
  UnableToFindValidMatches,
}

// https://github.com/i-chess/fast-swiss-pairing/tree/master/src/main/java/com/ichess/fastswisspairing
class SwissPairings {
  Tournament tournament;
  final _random = new Random();

  SwissPairings(this.tournament);

  /// Return true if pairing successful, false if
  RoundPairingError pairNextRound() {
    int round = tournament.curRoundNumber + 1;

    RoundPairingError errorType = RoundPairingError.NoError;

    RoundMatching? matching;

    if (round == 1) {
      matching = _getFirstRoundMatching(tournament.firstRoundMatchingRule);
    } else if (verifyAllResultsEntered()) {
      if (tournament.useSquads) {
        matching = _applySwiss(round, tournament.getSquads());
        // TODO: Match coaches too
      } else {
        matching = _applySwiss(round, tournament.getCoaches());
      }
    } else {
      debugPrint('Not all results entered');
      errorType = RoundPairingError.MissingPreviousResults;
    }

    if (matching != null) {
      tournament.updateRound(matching);
    } else {
      debugPrint('Failed to find matchings');
      if (errorType == RoundPairingError.NoError) {
        errorType = RoundPairingError.UnableToFindValidMatches;
      }
    }

    return errorType;
  }

  RoundMatching? _getFirstRoundMatching(FirstRoundMatchingRule rule) {
    switch (rule) {
      case FirstRoundMatchingRule.MatchRandom:
      case FirstRoundMatchingRule.MatchRandomAvoidGroup:
      default:
        return _firstRoundRandom();
    }
  }

  SwissRound? _firstRoundRandom() {
    List<IMatchupParticipant> notYetPaired = [];

    if (tournament.useSquads) {
      notYetPaired = new List.from(tournament.getSquads());
    } else {
      notYetPaired = new List.from(tournament.getCoaches());
    }

    // Handle case with odd number of coaches
    if (notYetPaired.length % 2 == 1) {
      int byeIdx = _random.nextInt(notYetPaired.length - 1);
      notYetPaired.removeAt(byeIdx);
    }

    if (notYetPaired.length <= 1) {
      return null;
    }

    SwissRound matchings = SwissRound(1);

    int tableNum = 1;

    while (notYetPaired.length > 1) {
      int idx_1 = _random.nextInt(notYetPaired.length - 1);

      IMatchupParticipant player_1 = notYetPaired[idx_1];

      notYetPaired.removeAt(idx_1);

      // Last player will be when lenght is = 1
      int idx_2 = notYetPaired.length > 1
          ? _random.nextInt(notYetPaired.length - 1)
          : 0;

      IMatchupParticipant player_2 = notYetPaired[idx_2];

      notYetPaired.removeAt(idx_2);

      if (tournament.useSquads) {
        matchings.matches
            .add(SquadMatchup(1, tableNum, player_1.name(), player_2.name()));
      } else {
        matchings.matches
            .add(CoachMatchup(1, tableNum, player_1.name(), player_2.name()));
      }

      tableNum++;
    }

    return matchings;
  }

  bool verifyAllResultsEntered() {
    bool allCoachesEntered;

    if (tournament.prevCoachRounds.isEmpty) {
      allCoachesEntered = true;
    } else {
      CoachRound round = tournament.prevCoachRounds.last;
      allCoachesEntered =
          !round.matches.any((match) => match.result == MatchResult.NoResult);
    }

    bool allSquadsEntered;
    if (tournament.prevSquadRounds.isEmpty) {
      allSquadsEntered = true;
    } else {
      SquadRound round = tournament.prevSquadRounds.last;
      allSquadsEntered =
          !round.matches.any((match) => match.result == MatchResult.NoResult);
    }

    return allCoachesEntered && allSquadsEntered;
  }

  /// Want to sort in descending order
  /// a > b  | Returns a negative value.
  /// a == b | Returns 0.
  /// a < b  | Returns a positive value.
  int sortDescendingOperator(IMatchupParticipant a, IMatchupParticipant b) {
    int ptsCompare = a.points().compareTo(b.points());
    if (ptsCompare != 0) {
      return -1 * ptsCompare;
    }

    List<double> aTieBreakers = a.tiebreakers();
    List<double> bTieBreakers = b.tiebreakers();
    if (aTieBreakers.length != bTieBreakers.length || aTieBreakers.isEmpty) {
      return -1 * ptsCompare;
    }

    for (int i = 0; i < aTieBreakers.length; i++) {
      double aI = aTieBreakers[i];
      double bI = bTieBreakers[i];

      int iCompare = aI.compareTo(bI);
      if (iCompare != 0) {
        return -1 * iCompare;
      }
    }

    return -1 * ptsCompare;
  }

  SwissRound? _applySwiss(int roundNum, List<IMatchupParticipant> players) {
    // 1. Sort using tie breakers
    List<Coach> sortedPlayers = new List.from(players);
    sortedPlayers.sort((a, b) => sortDescendingOperator(a, b));

    // 2. Handle case of non-even number of players
    int byePlayerIdx = _findByePlayerIndex(sortedPlayers);

    // 3. Find Swiss pairings
    return _findPairings(roundNum, sortedPlayers, byePlayerIdx);
  }

  SwissRound? _findPairings(
      int roundNum, List<IMatchupParticipant> sortedPlayers, int byePlayerIdx) {
    SwissRound newMatchups = SwissRound(roundNum);

    // Iterate over the players, find a matching for the top player

    for (int i = 0; i < sortedPlayers.length; i++) {
      IMatchupParticipant bestPlayer = sortedPlayers[i];

      if (byePlayerIdx == i) {
        debugPrint("round " +
            roundNum.toString() +
            " Player on bye:" +
            bestPlayer.name());
        continue; // check if this player is on bye
      }
      // check if this player is already scheduled this round
      if (newMatchups.hasMatchForPlayer(bestPlayer)) {
        debugPrint("round " +
            roundNum.toString() +
            " Match already exists for" +
            bestPlayer.name());
        continue;
      }

      IMatchup? matchup =
          _findMatchupForPlayer(roundNum, sortedPlayers, i, byePlayerIdx);
      if (matchup != null) {
        newMatchups.matches.add(matchup);
        continue; // Move on ot ext player
      }

      if (newMatchups.matches.length == sortedPlayers.length / 2) {
        return newMatchups; // All necessary matchups
      }

      bool success = _handleNoMatchForBestPlayer(
          roundNum, sortedPlayers, i, byePlayerIdx, newMatchups);
      if (!success) {
        debugPrint("could not match all players. not enough players?");
        return null;
      }
    }

    return newMatchups;
  }

  int _findByePlayerIndex(List<IMatchupParticipant> sortedPlayers) {
    int byePlayerIdx = -1;

    if (sortedPlayers.length % 2 == 1) {
      // Choose bye player
      int idx = sortedPlayers.length - 1;
      while (idx >= 0) {
        IMatchupParticipant p = sortedPlayers[idx];
        bool hadBye = p.opponents().any((opp) => opp == "bye");
        if (!hadBye) {
          byePlayerIdx = idx;
          break;
        }
        idx--;
      }
    }

    return byePlayerIdx;
  }

  IMatchup? _findMatchupForPlayer(
      int roundNum,
      List<IMatchupParticipant> sortedPlayers,
      int bestPlayerIdx,
      int byePlayerIdx) {
    IMatchupParticipant bestPlayer = sortedPlayers[bestPlayerIdx];

    for (int j = bestPlayerIdx + 1; j < sortedPlayers.length; j++) {
      IMatchupParticipant nextPlayer = sortedPlayers[j];

      if (byePlayerIdx == j) {
        debugPrint("Player on bye:" + nextPlayer.name());
        continue; // check if this player is on bye
      }

      bool haveAlreadyPlayed =
          bestPlayer.opponents().any((name) => nextPlayer.name() == name);

      if (haveAlreadyPlayed) {
        debugPrint("game already exists between (" +
            bestPlayer.name() +
            " & " +
            nextPlayer.name());
        continue;
      }

      if (bestPlayer.type() == OrgType.Coach) {
        return CoachMatchup(roundNum, -1, bestPlayer.name(), nextPlayer.name());
      } else {
        return SquadMatchup(roundNum, -1, bestPlayer.name(), nextPlayer.name());
      }
    }

    // No valid match found
    return null;
  }

  bool _handleNoMatchForBestPlayer(
      int roundNum,
      List<IMatchupParticipant> sortedPlayers,
      int bestPlayerIdx,
      int byePlayerIdx,
      SwissRound newMatchups) {
    IMatchupParticipant bestPlayer = sortedPlayers[bestPlayerIdx];

    // no match for the best player found. we now have to find a couple to break,
    // and opp for this player that will satisfy all conditions
    // so iterate on the pairing so far in reverse order
    debugPrint("round " +
        roundNum.toString() +
        " need to switch pairs for " +
        bestPlayer.name() +
        " we have " +
        newMatchups.matches.length.toString() +
        " games");

    for (int g = newMatchups.matches.length - 1; g >= 0; g--) {
      IMatchup pairedGame = newMatchups.matches[g];

      IMatchupParticipant player_1 = pairedGame.home(tournament);
      IMatchupParticipant player_2 = pairedGame.away(tournament);

      bool hasBestPlayerPlayedVsPlayer_1 =
          bestPlayer.opponents().any((name) => player_1.name() == name);

      bool hasBestPlayerPlayedVsPlayer_2 =
          bestPlayer.opponents().any((name) => player_2.name() == name);

      if (hasBestPlayerPlayedVsPlayer_1 && hasBestPlayerPlayedVsPlayer_2) {
        // Can't use this pair because the best score user already played vs both of them
        continue;
      }

      // ok have a candidate pairing. lets iterate over the players again from the bottom to find someone
      // to switch pairs with

      IMatchupParticipant switchPlayer;

      for (int p = sortedPlayers.length - 1; p >= 0; p--) {
        switchPlayer = sortedPlayers[p];

        // check that the switch player is not scheduled, and that it is not the bye user, or the best
        // score user, or the chosen pairs p1, p2
        // check if this player is already scheduled this round
        if (newMatchups.hasMatchForPlayerName(switchPlayer.name())) {
          debugPrint("round " +
              roundNum.toString() +
              " Match already exists for switchlayer: " +
              bestPlayer.name());
          continue;
        }

        if (switchPlayer == bestPlayer ||
            p == byePlayerIdx ||
            switchPlayer == player_1 ||
            switchPlayer == player_2) {
          debugPrint("round " +
              roundNum.toString() +
              " switch player: " +
              switchPlayer.name() +
              " is either best score, bye, p1, or p2");
          continue;
        }

        debugPrint("round " +
            roundNum.toString() +
            " candidate switch player: " +
            switchPlayer.name());

        // Check if that it is possible to make some pairing switch
        bool hasSwitchPlayedPlayer1 =
            switchPlayer.opponents().any((name) => player_1.name() == name);

        if (!hasSwitchPlayedPlayer1 && !hasBestPlayerPlayedVsPlayer_2) {
          // we can switch. p1 vs the switch user, best player vs p2
          debugPrint("round " +
              roundNum.toString() +
              "pairing remove game " +
              pairedGame.homeName() +
              " vs. " +
              pairedGame.awayName());

          bool success = newMatchups.matches.remove(pairedGame);
          if (!success) {
            return false;
          }

          if (bestPlayer.type() == OrgType.Coach) {
            newMatchups.matches.add(
                CoachMatchup(roundNum, -1, bestPlayer.name(), player_2.name()));
            newMatchups.matches.add(CoachMatchup(
                roundNum, -1, player_1.name(), switchPlayer.name()));
          } else {
            newMatchups.matches.add(
                SquadMatchup(roundNum, -1, bestPlayer.name(), player_2.name()));
            newMatchups.matches.add(SquadMatchup(
                roundNum, -1, player_1.name(), switchPlayer.name()));
          }

          return true;
        }

        bool hasSwitchPlayedPlayer2 =
            switchPlayer.opponents().any((name) => player_2.name() == name);
        if (!hasSwitchPlayedPlayer2 && !hasBestPlayerPlayedVsPlayer_1) {
          // we can switch. p2 vs the switch user, best player vs p1
          debugPrint("round " +
              roundNum.toString() +
              "pairing remove game " +
              pairedGame.homeName() +
              " vs. " +
              pairedGame.awayName());

          bool success = newMatchups.matches.remove(pairedGame);
          if (!success) {
            return false;
          }

          if (bestPlayer.type() == OrgType.Coach) {
            newMatchups.matches.add(
                CoachMatchup(roundNum, -1, bestPlayer.name(), player_1.name()));
            newMatchups.matches.add(CoachMatchup(
                roundNum, -1, player_2.name(), switchPlayer.name()));
          } else {
            newMatchups.matches.add(
                SquadMatchup(roundNum, -1, bestPlayer.name(), player_1.name()));
            newMatchups.matches.add(SquadMatchup(
                roundNum, -1, player_2.name(), switchPlayer.name()));
          }

          return true;
        }
      }
    }
    // nothing to do... probably not enough players or some crazy pairing
    return false;
  }

  static String getFirstRoundMatchingName(FirstRoundMatchingRule rule) {
    switch (rule) {
      case FirstRoundMatchingRule.MatchRandomAvoidGroup:
        return "MatchRandomAvoidGroup";
      case FirstRoundMatchingRule.MatchRandom:
      default:
        return "MatchRandom";
    }
  }

  static FirstRoundMatchingRule parseFirstRoundMatchingName(String rule) {
    switch (rule) {
      case "MatchRandomAvoidGroup":
        return FirstRoundMatchingRule.MatchRandomAvoidGroup;
      case "MatchRandom":
      default:
        return FirstRoundMatchingRule.MatchRandom;
    }
  }

  // List<IMatchup>? _applySwissOld(
  //     List<IMatchupParticipant> teams, bool allowRematches) {
  //   // 1. Sort using tie breakers
  //   teams.sort((a, b) => sortDescendingOperator(a, b));

  //   // 2. Ensure even number of teams (or add bye)
  //   _ensureEvenNumTeamsOld(teams);

  //   // 3. Group Teams
  //   List<List<IMatchupParticipant>> groupedTeams = _groupTeamsOld(teams);

  //   // 4. Assign Pairings
  //   List<IMatchup>? matchups = _assignPairingsOld(groupedTeams);
  //   return matchups;
  // }

  // /// If we have an odd number of teams, assign a bye team
  // void _ensureEvenNumTeamsOld(List<IMatchupParticipant> teams) {
  //   if (teams.isEmpty) {
  //     return;
  //   }

  //   OrgType orgType = teams.first.type();

  //   if (teams.length % 2 != 0) {
  //     switch (orgType) {
  //       case OrgType.Squad:
  //         teams.add(new Squad("Bye"));
  //         break;
  //       case OrgType.Coach:
  //         teams.add(new Coach(-1, "Bye", "Bye", "Bye", Race.Unknown, "", -1));
  //         break;
  //     }
  //   }
  // }

  // /// Teams are assumed to already be sorted in descending order and even
  // /// 1. We group players by points
  // /// 2. If any groups have odd numbers, move last player to the next group
  // List<List<IMatchupParticipant>> _groupTeamsOld(
  //     List<IMatchupParticipant> teams) {
  //   List<List<IMatchupParticipant>> groups = <List<IMatchupParticipant>>[];
  //   groups.add(<IMatchupParticipant>[]);

  //   double prevPts = teams.first.points();
  //   for (int i = 0; i < teams.length; i++) {
  //     double pts = teams[i].points();
  //     if (pts != prevPts) {
  //       // Done with previous group, check if even
  //       // If odd, relegate last team into this new group
  //       IMatchupParticipant? relegatedTeam = null;
  //       if (groups.last.length % 2 != 0) {
  //         relegatedTeam = groups.last.last;
  //       }
  //       groups.add(<IMatchupParticipant>[]);
  //       if (relegatedTeam != null) {
  //         groups.last.add(relegatedTeam);
  //       }
  //     }

  //     groups.last.add(teams[i]);
  //   }

  //   return groups;
  // }

  // /// 1. For each Group, find pairings that will pair each player with someone not already played
  // /// 2. If no valid set of pairings in a group, merge group with next group
  // /// 3. If can't match last group, then unmatch previous groups & merge those with current one
  // /// 4. If can't generate pairings after entire list is considered then allow rematches (Rare)
  // List<IMatchup>? _assignPairingsOld(
  //     List<List<IMatchupParticipant>> groupedTeams) {}

  // double _weightOld(
  //     double maxPts, IMatchupParticipant p1, IMatchupParticipant p2) {
  //   double w = 0.0;

  //   // A pairing where the participants have not played each other as many times
  //   // as they have played at least one other participant outscore all pairings
  //   // where the participants have played the most times.
  //   // This will stave off re-pairs and second byes for as long as possible, and
  //   // then re-re-pairs and third byes, and so on …

  //   int numOpponents = p1.opponents().length;
  //   int numTimesPlayedP2 = p1.opponents().where((a) => p2.name() == a).length;
  //   int maxDuplicates = findMaxNumDuplicatedElementInListOld(p1.opponents());

  //   if (numOpponents > 0 && numTimesPlayedP2 < maxDuplicates) {
  //     w += _qualityOld(maxPts, maxPts) + 1;
  //   }

  //   // Determine a score for the quality of this pairing based on the points of
  //   // the higher scoring participant of the two (importance) and
  //   // how close the two participant's records are.

  //   double p1Pts = p1.points();
  //   double p2Pts = p2.points();

  //   double best = max(p1Pts, p2Pts);
  //   double worst = min(p1Pts, p2Pts);
  //   double spread = best - worst;
  //   double closeness = maxPts - spread;
  //   double importance = best;

  //   w += _qualityOld(importance, closeness);

  //   return w;
  // }

  // /// importance and closeness are values in the range 0..highest_points
  // double _qualityOld(double importance, double closeness) {
  //   // Add one to these values to avoid sometimes multiplying by zero and losing information.
  //   return (importance + 1) * (closeness + 1);
  // }

  // /// Find the max count of any duplicated items in a list
  // int findMaxNumDuplicatedElementInListOld<T>(Iterable<T> list) => list
  //     .fold<Map<T, int>>(
  //         {},
  //         (map, element) =>
  //             map..update(element, (value) => value + 1, ifAbsent: () => 1))
  //     .entries
  //     .reduce((e1, e2) => e1.value > e2.value ? e1 : e2)
  //     .value;
}
