import 'dart:core';
import 'dart:math';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/matchup/squad_matchup.dart';
import 'package:bbnaf/models/squad.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:flutter/material.dart';

// enum FirstRoundMatchingRule {
//   MatchRandom, // Random matchups
//   MatchRandomAvoidGroup, // Random matchups but do not match up same groups
// }

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
    bool useSquads = tournament.info.squadDetails.type == SquadUsage.SQUADS;

    if (useSquads) {
      // TODO: Handle avoiding byes case eventually
      bool pairAsIndividualsAvoidingSquad =
          tournament.info.squadDetails.matchMaking ==
                  SquadMatchMaking.INDIVIDUAL_SWISS_AVOIDING_SQUAD ||
              tournament.info.squadDetails.matchMaking ==
                  SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES;

      if (pairAsIndividualsAvoidingSquad) {
        // Squad tournament based on individual pairings
        return _pairNextRoundAsIndividuals(true, true);
      } else {
        // True squad pairings
        return _pairNextRoundAsSquads();
      }
    } else {
      // Individual pairings (may or may not use groups for init)
      bool avoidSquadsForInit = tournament.info.squadDetails.type ==
          SquadUsage.INDIVIDUAL_USE_SQUADS_FOR_INIT;
      return _pairNextRoundAsIndividuals(avoidSquadsForInit, false);
    }
  }

  RoundPairingError _pairNextRoundAsSquads() {
    int round = tournament.curRoundNumber() + 1;

    RoundPairingError errorType = RoundPairingError.NoError;

    RoundMatching? matching;

    if (round == 1) {
      matching = _getFirstRoundMatching(true, true);
    } else if (verifyAllResultsEntered()) {
      List<Squad> squads =
          tournament.getSquads().where((s) => s.isActive(tournament)).toList();
      matching = _applySwiss(round, squads, true);
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

  RoundPairingError _pairNextRoundAsIndividuals(
      bool avoidSquadsForInit, bool avoidSquadsAfterInit) {
    int round = tournament.curRoundNumber() + 1;

    RoundPairingError errorType = RoundPairingError.NoError;

    RoundMatching? matching;

    if (round == 1) {
      matching = _getFirstRoundMatching(false, avoidSquadsForInit);
    } else if (verifyAllResultsEntered()) {
      List<Coach> coaches =
          tournament.getCoaches().where((c) => c.active).toList();
      matching = _applySwiss(round, coaches, avoidSquadsAfterInit);
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

  RoundMatching? _getFirstRoundMatching(
      bool matchSquads, bool avoidSquadsForInit) {
    // TODO: Handle different types
    return _firstRoundRandom(matchSquads, avoidSquadsForInit);
  }

  SwissRound? _firstRoundRandom(bool matchSquads, bool avoidWithinSquads) {
    List<IMatchupParticipant> notYetPaired = [];

    if (matchSquads) {
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

      // Last player will be when length is = 1
      int idx_2 = notYetPaired.length > 1
          ? _random.nextInt(notYetPaired.length - 1)
          : 0;

      IMatchupParticipant player_2 = notYetPaired[idx_2];

      // If necessary, verify not same squad
      if (avoidWithinSquads && player_1 is Coach && player_2 is Coach) {
        Squad? squad_1 = tournament.getCoachSquad(player_1.nafName);
        Squad? squad_2 = tournament.getCoachSquad(player_2.nafName);

        if (squad_1 != null &&
            squad_2 != null &&
            squad_1.name() == squad_2.name()) {
          // Add back player_1 and try again
          notYetPaired.add(player_1);
          continue;
        }
      }

      notYetPaired.removeAt(idx_2);

      if (matchSquads) {
        SquadMatchup sm = SquadMatchup(player_1.name(), player_2.name());

        _populateCoachMatchupsInsideSquadMatchup(sm);

        matchings.matches.add(sm);
      } else {
        matchings.matches.add(CoachMatchup(player_1.name(), player_2.name()));
      }
    }

    return matchings;
  }

  bool verifyAllResultsEntered() {
    bool allCoachesEntered;

    if (tournament.coachRounds.isEmpty) {
      allCoachesEntered = true;
    } else {
      CoachRound round = tournament.coachRounds.last;
      allCoachesEntered = !round.matches
          .any((match) => match.getResult() == MatchResult.NoResult);
    }

    bool allSquadsEntered;
    if (tournament.squadRounds.isEmpty) {
      allSquadsEntered = true;
    } else {
      SquadRound round = tournament.squadRounds.last;
      allSquadsEntered = !round.matches
          .any((match) => match.getResult() == MatchResult.NoResult);
    }

    return allCoachesEntered && allSquadsEntered;
  }

  SwissRound? _applySwiss(
      int roundNum, List<IMatchupParticipant> players, bool avoidWithinSquads) {
    // 1. Sort using tie breakers
    List<Coach> sortedPlayers = new List.from(players);
    sortedPlayers
        .sort((a, b) => IMatchupParticipant.sortDescendingOperator(a, b));

    print("SortedPlayers:");
    int i = 1;
    sortedPlayers.forEach((p) {
      StringBuffer sb = new StringBuffer();
      sb.write(i.toString() +
          ": " +
          p.name() +
          ": " +
          p.points().toString() +
          " -> [");
      p.tiebreakers().forEach((tb) {
        sb.write(tb.toString() + ",");
      });
      sb.write("]");
      print(sb.toString());
      i++;
    });
    print("");

    // 2. Handle case of non-even number of players
    int byePlayerIdx = _findByePlayerIndex(sortedPlayers);

    // 3. Find Swiss pairings
    SwissRound? pairings =
        _findPairings(roundNum, sortedPlayers, byePlayerIdx, avoidWithinSquads);

    if (pairings != null) {
      // Ensure correct table numbers
      int tableNum = 1;

      for (int i = 0; i < pairings.matches.length; i++) {
        IMatchup matchup = pairings.matches[i];
        if (matchup is CoachMatchup) {
          matchup.tableNum = tableNum;
          tableNum++;
        } else if (matchup is SquadMatchup) {
          for (int j = 0; j < matchup.coachMatchups.length; j++) {
            matchup.coachMatchups[j].tableNum = tableNum;
            tableNum++;
          }
        }
      }

      print("Results:");
      pairings.matches.forEach((m) {
        StringBuffer sb = new StringBuffer();

        if (m is CoachMatchup) {
          sb.write("T" + m.tableNum.toString() + ":");
        }

        sb.write(m.homeName() + " vs. " + m.awayName());
        print(sb.toString());
        i++;
      });
      print("");
    }

    return pairings;
  }

  SwissRound? _findPairings(
      int roundNum,
      List<IMatchupParticipant> sortedPlayers,
      int byePlayerIdx,
      bool avoidWithinSquads) {
    SwissRound newMatchups = SwissRound(roundNum);

    // Iterate over the players, find a matching for the top player

    for (int i = 0; i < sortedPlayers.length; i++) {
      IMatchupParticipant bestPlayer = sortedPlayers[i];

      if (byePlayerIdx == i) {
        debugPrint("round " +
            roundNum.toString() +
            " Player on bye: " +
            bestPlayer.name());
        continue; // check if this player is on bye
      }
      // check if this player is already scheduled this round
      if (newMatchups.hasMatchForPlayer(bestPlayer)) {
        // debugPrint("round " +
        //     roundNum.toString() +
        //     " Skip " +
        //     bestPlayer.name() +
        //     " since they already have a match assigned");
        continue;
      }

      IMatchup? matchup = _findMatchupForPlayer(newMatchups, roundNum,
          sortedPlayers, i, byePlayerIdx, avoidWithinSquads);
      if (matchup != null) {
        if (matchup is SquadMatchup) {
          _populateCoachMatchupsInsideSquadMatchup(matchup);
        }

        newMatchups.matches.add(matchup);
        continue; // Move on to next player
      }

      int numMatchupsWeShouldHave = (sortedPlayers.length / 2).floor();
      if (newMatchups.matches.length == numMatchupsWeShouldHave) {
        return newMatchups; // All necessary matchups
      }

      debugPrint("Could not find match for " +
          bestPlayer.name() +
          " -> # matchups assigned: " +
          newMatchups.matches.length.toString());

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
    // No byes necessary
    if (sortedPlayers.length % 2 == 0) {
      return -1;
    }

    // All zeros array (index is playerIdx)
    List<int> numByes = List.filled(sortedPlayers.length, 0);

    for (int i = sortedPlayers.length - 1; i >= 0; i--) {
      IMatchupParticipant p = sortedPlayers[i];

      int byes = p.opponents().where((opp) => opp == CoachMatchup.Bye).length;
      if (byes == 0) {
        print("Bye player: " + p.name());
        return i; // First player that hasn't gotten a bye yet
      }

      numByes[i] = byes;
    }

    // All players had at least 1 bye
    // Find "last" player with min number of byes
    int minByes = numByes.reduce(min);
    int byePlayerIdx = numByes.lastIndexWhere((element) => element == minByes);

    if (byePlayerIdx >= 0) {
      print("Bye player: " + sortedPlayers[byePlayerIdx].name());
    } else {
      print("Bye player: Not found");
    }

    return byePlayerIdx;
  }

  IMatchup? _findMatchupForPlayer(
      SwissRound newMatchups,
      int roundNum,
      List<IMatchupParticipant> sortedPlayers,
      int bestPlayerIdx,
      int byePlayerIdx,
      bool avoidWithinSquads) {
    IMatchupParticipant bestPlayer = sortedPlayers[bestPlayerIdx];

    for (int j = bestPlayerIdx + 1; j < sortedPlayers.length; j++) {
      IMatchupParticipant nextPlayer = sortedPlayers[j];

      if (byePlayerIdx == j) {
        debugPrint("Player on bye:" + nextPlayer.name());
        continue; // check if this player is on bye
      }

      bool haveAlreadyPlayed = bestPlayer
          .opponents()
          .any((name) => nextPlayer.name().toLowerCase() == name.toLowerCase());

      if (haveAlreadyPlayed) {
        debugPrint("skip " +
            bestPlayer.name() +
            " vs. " +
            nextPlayer.name() +
            " -> already played");
        continue;
      }

      // check that the next player is not already scheduled
      if (newMatchups.hasMatchForPlayerName(nextPlayer.name())) {
        debugPrint("skip " +
            bestPlayer.name() +
            " vs. " +
            nextPlayer.name() +
            " -> already assigned matchup for: " +
            nextPlayer.name());
        continue;
      }

      // If necessary, verify not same squad
      if (avoidWithinSquads && bestPlayer is Coach && nextPlayer is Coach) {
        Squad? squad_1 = tournament.getCoachSquad(bestPlayer.nafName);
        Squad? squad_2 = tournament.getCoachSquad(nextPlayer.nafName);

        if (squad_1 != null &&
            squad_2 != null &&
            squad_1.name() == squad_2.name()) {
          debugPrint("skip " +
              bestPlayer.name() +
              " vs. " +
              nextPlayer.name() +
              " -> same squad");
          continue;
        }
      }

      if (bestPlayer.type() == OrgType.Coach) {
        return CoachMatchup(bestPlayer.name(), nextPlayer.name());
      } else {
        return SquadMatchup(bestPlayer.name(), nextPlayer.name());
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

      bool hasBestPlayerPlayedVsPlayer_1 = bestPlayer
          .opponents()
          .any((name) => player_1.name().toLowerCase() == name.toLowerCase());

      bool hasBestPlayerPlayedVsPlayer_2 = bestPlayer
          .opponents()
          .any((name) => player_2.name().toLowerCase() == name.toLowerCase());

      debugPrint("  -> Matchup to break(?): " +
          player_1.name().toString() +
          " vs. " +
          player_2.name().toString() +
          ". hasBestPlayerPlayedVsPlayer_1: " +
          (hasBestPlayerPlayedVsPlayer_1 ? "Y" : "N") +
          ". hasBestPlayerPlayedVsPlayer_2: " +
          (hasBestPlayerPlayedVsPlayer_2 ? "Y" : "N"));

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
              " Match already exists for switchPlayer: " +
              bestPlayer.name());
          continue;
        }

        if (switchPlayer == bestPlayer ||
            p == byePlayerIdx ||
            switchPlayer == player_1 ||
            switchPlayer == player_2) {
          // debugPrint("round " +
          //     roundNum.toString() +
          //     " switch player: " +
          //     switchPlayer.name() +
          //     " is either bestPlayer, bye, p1, or p2");
          continue;
        }

        debugPrint("round " +
            roundNum.toString() +
            " candidate switch player: " +
            switchPlayer.name());

        // Check if that it is possible to make some pairing switch
        bool hasSwitchPlayedPlayer1 = switchPlayer
            .opponents()
            .any((name) => player_1.name().toLowerCase() == name.toLowerCase());

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
            newMatchups.matches
                .add(CoachMatchup(bestPlayer.name(), player_2.name()));
            newMatchups.matches
                .add(CoachMatchup(player_1.name(), switchPlayer.name()));
          } else {
            newMatchups.matches
                .add(SquadMatchup(bestPlayer.name(), player_2.name()));
            newMatchups.matches
                .add(SquadMatchup(player_1.name(), switchPlayer.name()));
          }

          return true;
        }

        bool hasSwitchPlayedPlayer2 = switchPlayer
            .opponents()
            .any((name) => player_2.name().toLowerCase() == name.toLowerCase());
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
            newMatchups.matches
                .add(CoachMatchup(bestPlayer.name(), player_1.name()));
            newMatchups.matches
                .add(CoachMatchup(player_2.name(), switchPlayer.name()));
          } else {
            newMatchups.matches
                .add(SquadMatchup(bestPlayer.name(), player_1.name()));
            newMatchups.matches
                .add(SquadMatchup(player_2.name(), switchPlayer.name()));
          }

          return true;
        }
      }
    }
    // nothing to do... probably not enough players or some crazy pairing
    return false;
  }

  /// Pair coaches within squads
  void _populateCoachMatchupsInsideSquadMatchup(SquadMatchup sm) {
    Squad? squad_1 = tournament.getSquad(sm.homeSquadName);
    Squad? squad_2 = tournament.getSquad(sm.awaySquadName);

    if (squad_1 == null || squad_2 == null) {
      return; // Invalid
    }

    // Get coaches from Squad 1
    List<Coach> coaches_1 = [];
    squad_1.getCoaches().forEach((nafName) {
      Coach? c = tournament.getCoach(nafName);
      if (c != null && c.active) {
        coaches_1.add(c);
      }
    });

    // Get coaches from Squad 2
    List<Coach> coaches_2 = [];
    squad_2.getCoaches().forEach((nafName) {
      Coach? c = tournament.getCoach(nafName);
      if (c != null && c.active) {
        coaches_2.add(c);
      }
    });

    if (coaches_1.length != coaches_2.length ||
        coaches_1.length !=
            tournament.info.squadDetails.requiredNumCoachesPerSquad) {
      return; // Invalid
    }

    // Sort coaches
    coaches_1.sort((c1, c2) => c1
        .pointsWithTieBreakersBuiltIn()
        .compareTo(c2.pointsWithTieBreakersBuiltIn()));

    coaches_2.sort((c1, c2) => c1
        .pointsWithTieBreakersBuiltIn()
        .compareTo(c2.pointsWithTieBreakersBuiltIn()));

    for (int i = 0; i < coaches_1.length; i++) {
      sm.coachMatchups
          .add(CoachMatchup(coaches_1[i].name(), coaches_2[i].name()));
    }
  }
}
