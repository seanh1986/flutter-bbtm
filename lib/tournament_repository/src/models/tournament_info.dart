import 'dart:core';
import 'package:bbnaf/rankings/models/models.dart';
import 'package:enum_to_string/enum_to_string.dart';

class TournamentInfo {
  String id = "";
  String name = "";
  String location = "";
  DateTime dateTimeStart = DateTime.now();
  DateTime dateTimeEnd = DateTime.now();
  List<OrganizerInfo> organizers = [];

  IndividualScoringDetails scoringDetails = IndividualScoringDetails();

  CasualtyDetails casualtyDetails = CasualtyDetails();

  SquadDetails squadDetails = SquadDetails();

  String detailsWeather = "";
  String detailsKickOff = "";
  String detailsSpecialRules = "";

  String logoFileName = "";

  TournamentInfo(
      {required this.id,
      required this.name,
      required this.location,
      required this.dateTimeStart,
      required this.dateTimeEnd});

  TournamentInfo.copy(TournamentInfo info)
      : this.fromJson(info.id, info.toJson());

  TournamentInfo.fromJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;

    final tName = json['name'] as String?;
    if (tName != null) {
      this.name = tName;
    }

    final tLocation = json['location'] as String?;
    if (tLocation != null) {
      this.location = tLocation;
    }

    final String? tStart = json['date_time_start'] as String?;
    if (tStart != null) {
      try {
        this.dateTimeStart = DateTime.parse(tStart);
      } catch (_) {}
    }

    final String? tEnd = json['date_time_end'] as String?;
    if (tEnd != null) {
      try {
        this.dateTimeEnd = DateTime.parse(tEnd);
      } catch (_) {}
    }

    final tOrganizers = json['organizers'] as List<dynamic>?;
    if (tOrganizers != null) {
      tOrganizers.forEach((tOrga) {
        var orgaJson = tOrga as Map<String, dynamic>;
        organizers.add(OrganizerInfo.fromJson(orgaJson));
      });
    }

    final tScoringDetails = json['scoring_details'] as Map<String, dynamic>?;
    if (tScoringDetails != null) {
      this.scoringDetails = IndividualScoringDetails.fromJson(tScoringDetails);
    }

    final tCasDetails = json['casualty_details'] as Map<String, dynamic>?;
    if (tCasDetails != null) {
      this.casualtyDetails = CasualtyDetails.fromJson(tCasDetails);
    }

    final tSquadDetails = json['squad_details'] as Map<String, dynamic>?;
    if (tSquadDetails != null) {
      this.squadDetails = SquadDetails.fromJson(tSquadDetails);
    }

    final tDetailsWeather = json['details_weather'] as String?;
    if (tDetailsWeather != null) {
      this.detailsWeather = tDetailsWeather;
    }

    final tDetailsKickOff = json['details_kickoff'] as String?;
    if (tDetailsKickOff != null) {
      this.detailsKickOff = tDetailsKickOff;
    }

    final tDetailsSpecialRules = json['details_special_rules'] as String?;
    if (tDetailsSpecialRules != null) {
      this.detailsSpecialRules = tDetailsSpecialRules;
    }

    final tLogo = json['logo_file_name'] as String?;
    if (tLogo != null) {
      this.logoFileName = tLogo;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'date_time_start': dateTimeStart.toIso8601String(),
        'date_time_end': dateTimeEnd.toIso8601String(),
        'organizers': organizers.map((e) => e.toJson()).toList(),
        'scoring_details': scoringDetails.toJson(),
        'casualty_details': casualtyDetails.toJson(),
        'squad_details': squadDetails.toJson(),
        'details_weather': detailsWeather,
        'details_kickoff': detailsKickOff,
        'details_special_rules': detailsSpecialRules,
        'logo_file_name': logoFileName,
      };
}

class CasualtyDetails {
  bool spp = true;
  bool foul = false;
  bool surf = false;
  bool weapon = false;
  bool dodge = false;

  CasualtyDetails();

  CasualtyDetails.fromJson(Map<String, dynamic> json) {
    final tSpp = json['spp'] as bool?;
    if (tSpp != null) {
      this.spp = tSpp;
    }

    final tFoul = json['foul'] as bool?;
    if (tFoul != null) {
      this.foul = tFoul;
    }

    final tSurf = json['surf'] as bool?;
    if (tSurf != null) {
      this.surf = tSurf;
    }

    final tWeapon = json['weapon'] as bool?;
    if (tWeapon != null) {
      this.weapon = tWeapon;
    }

    final tDodge = json['dodge'] as bool?;
    if (tDodge != null) {
      this.dodge = tDodge;
    }
  }

  Map<String, dynamic> toJson() => {
        'spp': spp,
        'foul': foul,
        'surf': surf,
        'weapon': weapon,
        'dodge': dodge,
      };
}

enum TieBreaker {
  OppScore,
  Td,
  Cas,
  SumTdAndCas,
  TdDiff,
  CasDiff,
  SumTdDiffAndCasDiff,
  SquadScore,
  NumWins,
  NumTies,
}

enum SquadTieBreakers {
  SquadWins,
  SquadTies,
  SumSquadMemberScore, // Across all squad members
  OppScore,
  SumTdDiff, // Across all squad members
  SumCasDiff, // Across all squad members
  SumTdDiffPlusCasDiff, // Across all squad members
}

class BonusDetails {
  late String name;
  late double weight;

  BonusDetails(this.name, this.weight);

  BonusDetails.fromJsonWithDefault(
      Map<String, dynamic> json, String? defaultName) {
    final tName = json['name'] as String?;
    this.name =
        tName != null ? tName : (defaultName != null ? defaultName : "");

    final tWeight = json['weight'] as double?;
    this.weight = tWeight != null ? tWeight : 1;
  }

  BonusDetails.fromJson(Map<String, dynamic> json) {
    BonusDetails.fromJsonWithDefault(json, null);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'weight': weight,
      };
}

class ScoringDetails {
  late double winPts;
  late double tiePts;
  late double lossPts;

  // Optional list of bonus points and weights
  List<BonusDetails> bonusPts = [];

  ScoringDetails(this.winPts, this.tiePts, this.lossPts);

  // Default for coaches
  ScoringDetails.defaultForCoaches() {
    this.winPts = 5;
    this.tiePts = 2;
    this.lossPts = 0;
  }

  // Default for squad
  ScoringDetails.defaultForSquad() {
    this.winPts = 2;
    this.tiePts = 1;
    this.lossPts = 0;
  }

  ScoringDetails.fromJson(Map<String, dynamic> json) {
    final tWinPts = json['win_pts'] as double?;
    this.winPts = tWinPts != null ? tWinPts : 5;

    final tTiePts = json['tie_pts'] as double?;
    this.tiePts = tTiePts != null ? tTiePts : 2;

    final tLossPts = json['loss_pts'] as double?;
    this.lossPts = tLossPts != null ? tLossPts : 0;

    final tBonusPts = json['bonus_pts'] as List<dynamic>?;
    if (tBonusPts != null) {
      for (int i = 0; i < tBonusPts.length; i++) {
        bonusPts.add(BonusDetails.fromJsonWithDefault(
            tBonusPts[i] as Map<String, dynamic>, "Bonus_" + i.toString()));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'win_pts': winPts,
        'tie_pts': tiePts,
        'loss_pts': lossPts,
        'bonus_pts': bonusPts.map((e) => e.toJson()).toList(),
      };
}

class IndividualScoringDetails extends ScoringDetails {
  List<TieBreaker> tieBreakers = [
    TieBreaker.OppScore,
    TieBreaker.Td,
    TieBreaker.Cas,
    TieBreaker.TdDiff,
    TieBreaker.CasDiff,
  ];

  List<CoachRaceFilter> coachRaceRankingFilters = [];

  IndividualScoringDetails() : super.defaultForCoaches();

  IndividualScoringDetails.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    final tTieBreakers = json['tie_breakers'] as List<dynamic>?;

    List<TieBreaker> tParsedTieBrakers = [];

    if (tTieBreakers != null) {
      tTieBreakers.forEach((tb) {
        TieBreaker? tParsed = EnumToString.fromString(TieBreaker.values, tb);
        if (tParsed != null) {
          tParsedTieBrakers.add(tParsed);
        }
      });
    }

    this.tieBreakers = tParsedTieBrakers;

    if (this.tieBreakers.isEmpty) {
      this.tieBreakers = [
        TieBreaker.OppScore,
        TieBreaker.Td,
        TieBreaker.Cas,
        TieBreaker.TdDiff,
        TieBreaker.CasDiff,
      ];
    }

    final tRankingFilters =
        json['coach_race_ranking_filters'] as List<dynamic>?;
    if (tRankingFilters != null) {
      tRankingFilters.forEach((tFilter) {
        var filterJson = tFilter as Map<String, dynamic>;
        coachRaceRankingFilters.add(CoachRaceFilter.fromJson(filterJson));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['tie_breakers'] =
        tieBreakers.map((e) => EnumToString.convertToString(e)).toList();

    data['coach_race_ranking_filters'] =
        coachRaceRankingFilters.map((e) => e.toJson()).toList();
    return data;
  }
}

class OrganizerInfo {
  late String email;
  late String nafName;
  late bool primary;

  OrganizerInfo(this.email, this.nafName, this.primary);

  OrganizerInfo.fromJson(Map<String, dynamic> json) {
    final tEmail = json['email'] as String?;
    if (tEmail != null) {
      this.email = tEmail;
    } else {
      throw UnsupportedError('Invalid data: $json -> "email" is missing');
    }

    final tNafName = json['nafname'] as String?;
    if (tNafName != null) {
      this.nafName = tNafName;
    } else {
      throw UnsupportedError('Invalid data: $json -> "nafname" is missing');
    }

    final tPrimary = json['primary'] as bool?;
    primary = tPrimary != null ? tPrimary : false;
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'nafname': nafName,
        'primary': primary,
      };
}

enum SquadUsage {
  NO_SQUADS,
  INDIVIDUAL_USE_SQUADS_FOR_INIT,
  SQUADS,
}

enum SquadMatchMaking {
  ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES, // attempt to match squad vs squad when possible but allow for mix matching to avoid byes
  FORCE_SQUAD_VS_SQUAD_W_BYES, // force squad vs squad, may result in squad byes
  INDIVIDUAL_SWISS_AVOIDING_SQUAD, // solo-swiss but can't play squad members
}

enum SquadScoring {
  CUMULATIVE_PLAYER_SCORES,
  SQUAD_RESULT_W_T_L,
}

class SquadDetails {
  SquadUsage type = SquadUsage.NO_SQUADS;
  int requiredNumCoachesPerSquad = 0; // Number of active coaches required
  int maxNumCoachesPerSquad = 0; // Max number allowed on a squad

  SquadMatchMaking matchMaking =
      SquadMatchMaking.ATTEMPT_SQUAD_VS_SQUAD_AVOID_BYES;
  SquadScoring scoringType = SquadScoring.CUMULATIVE_PLAYER_SCORES;
  ScoringDetails scoringDetails = ScoringDetails.defaultForSquad();

  List<SquadTieBreakers> squadTieBreakers = [
    SquadTieBreakers.OppScore,
    SquadTieBreakers.SquadWins,
    SquadTieBreakers.SumSquadMemberScore,
    SquadTieBreakers.SumTdDiff,
    SquadTieBreakers.SumCasDiff,
  ];

  SquadDetails();

  SquadDetails.fromJson(Map<String, dynamic> json) {
    final tType = json['type'] as String?;
    if (tType != null) {
      SquadUsage? pType = EnumToString.fromString(SquadUsage.values, tType);
      if (pType != null) {
        this.type = pType;
      }
    }

    final tRequiredCoaches = json['required_coaches_per_squad'] as int?;
    if (tRequiredCoaches != null) {
      this.requiredNumCoachesPerSquad = tRequiredCoaches;
    }

    final tMaxCoaches = json['max_coaches_per_squad'] as int?;
    if (tMaxCoaches != null) {
      this.maxNumCoachesPerSquad = tMaxCoaches;
    }

    final tScoringType = json['scoring_type'] as String?;
    if (tScoringType != null) {
      SquadScoring? pScoringType =
          EnumToString.fromString(SquadScoring.values, tScoringType);
      if (pScoringType != null) {
        this.scoringType = pScoringType;
      }
    }

    final tScoringDetails = json['scoring_details'] as Map<String, dynamic>?;
    if (tScoringDetails != null) {
      this.scoringDetails = ScoringDetails.fromJson(tScoringDetails);
    }

    final tMatchMaking = json['squad_match_making'] as String?;
    if (tMatchMaking != null) {
      SquadMatchMaking? pMatchMaking =
          EnumToString.fromString(SquadMatchMaking.values, tMatchMaking);
      if (pMatchMaking != null) {
        this.matchMaking = pMatchMaking;
      }
    }

    final tTieBreakers = json['squad_tie_breakers'] as List<dynamic>?;

    List<SquadTieBreakers> tParsedTieBrakers = [];

    if (tTieBreakers != null) {
      tTieBreakers.forEach((tb) {
        SquadTieBreakers? tParsed =
            EnumToString.fromString(SquadTieBreakers.values, tb);
        if (tParsed != null) {
          tParsedTieBrakers.add(tParsed);
        }
      });
    }

    this.squadTieBreakers = tParsedTieBrakers;

    if (this.squadTieBreakers.isEmpty) {
      this.squadTieBreakers = [
        SquadTieBreakers.OppScore,
        SquadTieBreakers.SquadWins,
        SquadTieBreakers.SumSquadMemberScore,
        SquadTieBreakers.SumTdDiff,
        SquadTieBreakers.SumCasDiff,
      ];
    }
  }

  Map<String, dynamic> toJson() => {
        'type': EnumToString.convertToString(type),
        'required_coaches_per_squad': requiredNumCoachesPerSquad,
        'max_coaches_per_squad': maxNumCoachesPerSquad,
        'scoring_type': EnumToString.convertToString(scoringType),
        'scoring_details': scoringDetails.toJson(),
        'squad_match_making': EnumToString.convertToString(matchMaking),
        'squad_tie_breakers': squadTieBreakers
            .map((e) => EnumToString.convertToString(e))
            .toList(),
      };
}
