import 'dart:io';

import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:enum_to_string/enum_to_string.dart';

/**
 * These are filters which apply to the rankings, reducing how many participants are shown
 */
abstract class RankingFilter {
  late String name;

  RankingFilter(this.name);

  bool isActive(IMatchupParticipant p);

  RankingFilter.fromJson(Map<String, dynamic> json) {
    final tName = json['name'] as String?;
    this.name = tName != null ? tName : "";
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

abstract class CoachRankingFilter extends RankingFilter {
  late List<CoachRankingField> fields;

  CoachRankingFilter({required String name, this.fields = const []})
      : super(name) {
    if (fields.isEmpty) {
      fields = [
        CoachRankingField(CoachRankingFieldType.Pts),
        CoachRankingField(CoachRankingFieldType.W_T_L),
        CoachRankingField(CoachRankingFieldType.OppScore),
        CoachRankingField(CoachRankingFieldType.Td),
        CoachRankingField(CoachRankingFieldType.Cas),
      ];
    }
  }

  CoachRankingFilter.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List<CoachRankingField> tParsedFields = [];

    // Backwards compatibility
    final tOldFields = json['fields'] as List<dynamic>?;

    if (tOldFields != null) {
      tOldFields.forEach((f) {
        CoachRankingFieldType? tParsed =
            EnumToString.fromString(CoachRankingFieldType.values, f);
        if (tParsed != null) {
          tParsedFields.add(CoachRankingField(tParsed));
        }
      });
    }

    // New Parsing
    final tFieldList = json['field_list'] as List<dynamic>?;
    if (tFieldList != null) {
      tFieldList.forEach((tField) {
        var fJson = tField as Map<String, dynamic>;
        tParsedFields.add(CoachRankingField.fromJson(fJson));
      });
    }

    this.fields = tParsedFields;
  }

  bool isActive(IMatchupParticipant p);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['field_list'] = fields.map((e) => e.toJson()).toList();
    return data;
  }
}

class StuntyFilter extends CoachRankingFilter {
  StuntyFilter()
      : super(name: "Stunty", fields: [
          CoachRankingField(CoachRankingFieldType.Pts),
          CoachRankingField(CoachRankingFieldType.Td),
          CoachRankingField(CoachRankingFieldType.Cas),
        ]);

  @override
  bool isActive(IMatchupParticipant p) {
    if (p is Coach) {
      return p.isStunty();
    } else {
      return false;
    }
  }
}

class CoachRaceFilter extends CoachRankingFilter {
  late final List<Race> races;

  CoachRaceFilter(String name, this.races) : super(name: name);

  CoachRaceFilter.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final tRaces = json['races'] as List<dynamic>?;

    List<Race> tParsedRaces = [];

    if (tRaces != null) {
      tRaces.forEach((r) {
        Race? tParsed = EnumToString.fromString(Race.values, r);
        if (tParsed != null) {
          tParsedRaces.add(tParsed);
        }
      });
    }

    this.races = tParsedRaces;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['races'] = races.map((e) => EnumToString.convertToString(e)).toList();
    return data;
  }

  @override
  bool isActive(IMatchupParticipant p) {
    if (p is Coach) {
      return races.any((r) => r == p.race);
    } else {
      return false;
    }
  }
}

abstract class SquadRankingFilter extends RankingFilter {
  late final List<SquadRankingField> fields;

  SquadRankingFilter(String name, this.fields) : super(name);

  bool isActive(IMatchupParticipant p);

  SquadRankingFilter.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List<SquadRankingField> tParsedFields = [];

    // Backwards compatibility
    final tOldFields = json['fields'] as List<dynamic>?;

    if (tOldFields != null) {
      tOldFields.forEach((f) {
        SquadRankingFieldType? tParsed =
            EnumToString.fromString(SquadRankingFieldType.values, f);
        if (tParsed != null) {
          tParsedFields.add(SquadRankingField(tParsed));
        }
      });
    }

    // New Parsing
    final tFieldList = json['field_list'] as List<dynamic>?;
    if (tFieldList != null) {
      tFieldList.forEach((tField) {
        var fJson = tField as Map<String, dynamic>;
        tParsedFields.add(SquadRankingField.fromJson(fJson));
      });
    }

    this.fields = tParsedFields;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['field_list'] = fields.map((e) => e.toJson()).toList();
    return data;
  }
}

class SquadNameFilter extends SquadRankingFilter {
  late final List<String> squadNames;

  SquadNameFilter(String name, this.squadNames)
      : super(name, [
          SquadRankingField(SquadRankingFieldType.Pts),
          SquadRankingField(SquadRankingFieldType.W_T_L),
          SquadRankingField(SquadRankingFieldType.SumIndividualScore),
          SquadRankingField(SquadRankingFieldType.OppScore),
          SquadRankingField(SquadRankingFieldType.SumTd),
          SquadRankingField(SquadRankingFieldType.SumCas),
        ]);

  SquadNameFilter.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final tSquadNames = json['squad_names'] as List<dynamic>?;

    squadNames = [];
    if (tSquadNames != null) {
      tSquadNames.forEach((r) {
        if (r != null && r is String) {
          squadNames.add(r);
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['squad_names'] = squadNames.toList();
    return data;
  }

  @override
  bool isActive(IMatchupParticipant p) {
    if (p is Squad) {
      return squadNames.any((r) => r.toLowerCase() == p.name().toLowerCase());
    } else {
      return false;
    }
  }
}
