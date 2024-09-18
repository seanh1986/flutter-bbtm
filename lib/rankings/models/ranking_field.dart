import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum CoachRankingFieldType {
  Unknown, // Fallback error state
  Pts,
  W,
  T,
  L,
  W_T_L,
  W_Percent,
  Td,
  Cas,
  OppTd,
  OppCas,
  OppScore,
  DeltaTd,
  DeltaCas,
  BestSport,
  Bonus, // Requires specifying the bonus
  CurRank,
  RankFromRound, // Requires specifying the round (since when)
  DeltaRankFromRound, // Requires specifying the round (since when)
}

enum SquadRankingFieldType {
  Unknown, // Fallback error state
  Pts,
  W,
  T,
  L,
  W_T_L,
  W_Percent,
  SumIndividualScore,
  SumTd,
  SumCas,
  SumOppTd,
  SumOppCas,
  SumDeltaTd,
  SumDeltaCas,
  OppScore,
  SumBestSport,
  Bonus, // Requires specifying the bonus
}

/**
 * These are the individual columsn used 
 */
abstract class RankingField {
  late String label;

  RankingField(this.label);

  RankingField.fromJson(Map<String, dynamic> json) {
    final tLabel = json['label'] as String?;
    this.label = tLabel != null ? tLabel : "";
  }

  Map<String, dynamic> toJson() => {
        'label': label,
      };
}

class CoachRankingField extends RankingField {
  late CoachRankingFieldType type;
  int bonusIdx = -1;
  int rankFromRound = -1;

  CoachRankingField(this.type) : super(_getLabel(type));

  CoachRankingField.fromBonus(TournamentInfo info, this.bonusIdx)
      : super(_getLabel(CoachRankingFieldType.Bonus,
            info: info, bonusIdx: bonusIdx)) {
    this.type = CoachRankingFieldType.Bonus;
  }

  CoachRankingField.fromRankFromRound(
      CoachRankingFieldType type, this.rankFromRound)
      : super(_getLabel(type, rankFromRound: rankFromRound)) {
    this.type = type;
  }

  CoachRankingField.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final tType = json['type'] as String?;
    CoachRankingFieldType? tParsed = tType != null
        ? EnumToString.fromString(CoachRankingFieldType.values, tType)
        : null;
    type = tParsed != null ? tParsed : CoachRankingFieldType.Unknown;

    final tBonusIdx = json['bonusIdx'] as int?;
    bonusIdx = tBonusIdx != null ? tBonusIdx : -1;

    final tRankFromRound = json['rank_from_round'] as int?;
    rankFromRound = tRankFromRound != null ? tRankFromRound : -1;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['type'] = EnumToString.convertToString(type);
    data['bonusIdx'] = bonusIdx;
    data['rank_from_round'] = rankFromRound;
    return data;
  }

  static String _getLabel(CoachRankingFieldType type,
      {TournamentInfo? info, int bonusIdx = -1, int rankFromRound = -1}) {
    switch (type) {
      case CoachRankingFieldType.Pts:
        return "Pts";
      case CoachRankingFieldType.W:
        return "W";
      case CoachRankingFieldType.T:
        return "T";
      case CoachRankingFieldType.L:
        return "L";
      case CoachRankingFieldType.W_T_L:
        return "W/T/L";
      case CoachRankingFieldType.W_Percent:
        return "%";
      case CoachRankingFieldType.Td:
        return "Td+";
      case CoachRankingFieldType.Cas:
        return "Cas+";
      case CoachRankingFieldType.OppTd:
        return "Td-";
      case CoachRankingFieldType.OppCas:
        return "Cas-";
      case CoachRankingFieldType.DeltaTd:
        return "Td\u0394";
      case CoachRankingFieldType.DeltaCas:
        return "Cas\u0394";
      case CoachRankingFieldType.OppScore:
        return "OppScore";
      case CoachRankingFieldType.BestSport:
        return "Sport";
      case CoachRankingFieldType.DeltaRankFromRound:
        return "Rank\u0394";
      case CoachRankingFieldType.RankFromRound:
        return "Rank (Rd " + rankFromRound.toString() + ")";
      case CoachRankingFieldType.CurRank:
        return "Rank (Current)";
      case CoachRankingFieldType.Bonus:
        {
          if (info == null) {
            return "";
          }

          ScoringDetails scoringDetails = info.scoringDetails;

          if (bonusIdx < 0 || bonusIdx >= scoringDetails.bonusPts.length) {
            return "";
          }

          BonusDetails bonusDetails = scoringDetails.bonusPts[bonusIdx];

          return bonusDetails.name;
        }
      default:
        return "";
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CoachRankingField &&
        other.type == type &&
        other.bonusIdx == bonusIdx;
  }
}

class SquadRankingField extends RankingField {
  late SquadRankingFieldType type;
  late int bonusIdx;

  SquadRankingField(this.type, {TournamentInfo? info, this.bonusIdx = -1})
      : super(_getLabel(type, info, bonusIdx));

  SquadRankingField.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final tType = json['type'] as String?;
    SquadRankingFieldType? tParsed = tType != null
        ? EnumToString.fromString(SquadRankingFieldType.values, tType)
        : null;
    type = tParsed != null ? tParsed : SquadRankingFieldType.Unknown;

    final tBonusIdx = json['bonusIdx'] as int?;
    bonusIdx = tBonusIdx != null ? tBonusIdx : -1;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['type'] = EnumToString.convertToString(type);
    data['bonusIdx'] = bonusIdx;
    return data;
  }

  static String _getLabel(
      SquadRankingFieldType type, TournamentInfo? info, int bonusIdx) {
    switch (type) {
      case SquadRankingFieldType.Pts:
        return "Pts";
      case SquadRankingFieldType.W:
        return "W";
      case SquadRankingFieldType.T:
        return "T";
      case SquadRankingFieldType.L:
        return "L";
      case SquadRankingFieldType.W_T_L:
        return "W/T/L";
      case SquadRankingFieldType.W_Percent:
        return "%";
      case SquadRankingFieldType.SumIndividualScore:
        return "CoachPts";
      case SquadRankingFieldType.SumTd:
        return "Td+";
      case SquadRankingFieldType.SumCas:
        return "Cas+";
      case SquadRankingFieldType.SumOppTd:
        return "Td-";
      case SquadRankingFieldType.SumOppCas:
        return "Cas-";
      case SquadRankingFieldType.SumDeltaTd:
        return "Td\u0394";
      case SquadRankingFieldType.SumDeltaCas:
        return "Cas\u0394";
      case SquadRankingFieldType.OppScore:
        return "OppScore";
      case SquadRankingFieldType.SumBestSport:
        return "Sport";
      case SquadRankingFieldType.Bonus:
        {
          if (info == null) {
            return "";
          }

          ScoringDetails scoringDetails = info.squadDetails.scoringDetails;

          if (bonusIdx < 0 || bonusIdx >= scoringDetails.bonusPts.length) {
            return "";
          }

          BonusDetails bonusDetails = scoringDetails.bonusPts[bonusIdx];

          return bonusDetails.name;
        }
      default:
        return "";
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SquadRankingField &&
        other.type == type &&
        other.bonusIdx == bonusIdx;
  }
}
