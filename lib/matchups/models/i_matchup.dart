import 'package:bbnaf/tournament_repository/src/models/models.dart';

// Identifies if the object is of type squad or coach
enum OrgType {
  Squad,
  Coach,
}

enum MatchResult {
  NoResult, // no result assigned yet
  Conflict, // Inputted results do not agree
  HomeWon,
  AwayWon,
  Draw,
}

abstract class IMatchup {
  OrgType type();

  String homeName();
  String awayName();

  IMatchupParticipant home(Tournament t);
  IMatchupParticipant away(Tournament t);

  bool matchSearch(String search);

  // Map<String, dynamic> toJson();

  bool hasResult() {
    return getResult() != MatchResult.NoResult;
  }

  MatchResult getResult();

  bool hasParticipantName(String name) {
    String nameLc = name.toLowerCase().trim();
    return homeName().toLowerCase().trim() == nameLc ||
        awayName().toLowerCase().trim() == nameLc;
  }

  bool hasParticipant(IMatchupParticipant p) {
    String nameLc = p.name().toLowerCase().trim();
    return homeName().toLowerCase().trim() == nameLc ||
        awayName().toLowerCase().trim() == nameLc;
  }

  bool hasParticipants(
      Tournament t, IMatchupParticipant p1, IMatchupParticipant p2) {
    return (home(t) == p1 && away(t) == p2) || (home(t) == p2 && away(t) == p1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is IMatchup &&
        other.type() == type() &&
        other.homeName().toLowerCase() == homeName().toLowerCase() &&
        other.awayName().toLowerCase() == awayName().toLowerCase();
  }

  @override
  int get hashCode =>
      Object.hash(type(), homeName().toLowerCase(), awayName().toLowerCase());

  // static String getResultName(MatchResult result) {
  //   switch (result) {
  //     case MatchResult.HomeWon:
  //       return "HomeWon";
  //     case MatchResult.AwayWon:
  //       return "AwayWon";
  //     case MatchResult.Draw:
  //       return "Draw";
  //     case MatchResult.NoResult:
  //     default:
  //       return "NoResult";
  //   }
  // }

  // static MatchResult parseResult(String result) {
  //   switch (result) {
  //     case "HomeWon":
  //       return MatchResult.HomeWon;
  //     case "AwayWon":
  //       return MatchResult.AwayWon;
  //     case "Draw":
  //       return MatchResult.Draw;
  //     case "NoResult":
  //     default:
  //       return MatchResult.NoResult;
  //   }
  // }
}

// Abstract class which represents a matchup
// This can be squad vs squad or coach vs coach
abstract class IMatchupParticipant {
  OrgType type();
  String name(); // Used for swiss pairings, etc.
  String parentName();
  double points();
  int wins();
  int ties();
  int losses();
  List<double> tiebreakers();
  List<String> opponents();
  bool isActive(Tournament t);
  String displayName(TournamentInfo info); // Used for matchups & rankings UI

  // Check if it matches the search word
  bool matchSearch(String search);

  String showRecord() {
    return wins().toString() +
        "-" +
        ties().toString() +
        "-" +
        losses().toString() +
        " (" +
        winPercent().toStringAsFixed(1) +
        "%)";
  }

  int gamesPlayed() {
    return wins() + ties() + losses();
  }

  double winPercent() {
    int games = gamesPlayed();
    return games > 0 ? 100.0 * (1.0 * wins() + 0.5 * ties()) / games : 0.0;
  }

  // Approximate
  double pointsWithTieBreakersBuiltIn() {
    // Shift by mStep after each tiebreaker
    int mStep = 100;
    int m = 1;

    double ptsWithT = 0.0;

    List<double> tbPtsList = tiebreakers();

    // Reverse order for tiebreakers
    for (int i = tbPtsList.length - 1; i >= 0; i--) {
      double tbPts = tbPtsList[i];
      ptsWithT += tbPts * m;
      m *= mStep;
    }

    m *= 10; // Extra Buffer
    ptsWithT += points() * m;

    // StringBuffer sb = new StringBuffer();
    // sb.write(name() + ": " + points().toString() + " -> [");
    // tiebreakers().forEach((tb) {
    //   sb.write(tb.toString() + ",");
    // });
    // sb.write("] -> ");
    // sb.write(ptsWithT.toDouble());
    // print(sb.toString());

    return ptsWithT;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is IMatchupParticipant &&
        other.type() == type() &&
        other.name().toLowerCase() == name().toLowerCase();
  }

  @override
  int get hashCode => Object.hash(type(), name().toLowerCase());

  /// Want to sort in descending order
  /// a > b  | Returns a negative value.
  /// a == b | Returns 0.
  /// a < b  | Returns a positive value.
  static int sortDescendingOperator(
      IMatchupParticipant a, IMatchupParticipant b) {
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
}
