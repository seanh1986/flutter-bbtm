import 'package:bbnaf/matchups/matchups.dart';
import 'package:bbnaf/rankings/rankings.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:enum_to_string/enum_to_string.dart';

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
  late List<CoachRankingFields> fields;

  CoachRankingFilter(
      {required String name,
      this.fields = const [
        CoachRankingFields.Pts,
        CoachRankingFields.W_T_L,
        CoachRankingFields.OppScore,
        CoachRankingFields.Td,
        CoachRankingFields.Cas,
      ]})
      : super(name);

  CoachRankingFilter.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    final tFields = json['fields'] as List<dynamic>?;

    List<CoachRankingFields> tParsedFields = [];

    if (tFields != null) {
      tFields.forEach((f) {
        CoachRankingFields? tParsed =
            EnumToString.fromString(CoachRankingFields.values, f);
        if (tParsed != null) {
          tParsedFields.add(tParsed);
        }
      });
    }

    this.fields = tParsedFields;
  }

  bool isActive(IMatchupParticipant p);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['fields'] =
        fields.map((e) => EnumToString.convertToString(e)).toList();
    return data;
  }
}

class StuntyFilter extends CoachRankingFilter {
  StuntyFilter()
      : super(name: "Stunty", fields: [
          CoachRankingFields.Pts,
          CoachRankingFields.Td,
          CoachRankingFields.Cas
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
  late final List<SquadRankingFields> fields;

  SquadRankingFilter(String name, this.fields) : super(name);

  bool isActive(IMatchupParticipant p);

  SquadRankingFilter.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List<SquadRankingFields> tParsedFields = [];

    final tFields = json['fields'] as List<dynamic>?;
    if (tFields != null) {
      tFields.forEach((f) {
        SquadRankingFields? tParsed =
            EnumToString.fromString(SquadRankingFields.values, f);
        if (tParsed != null) {
          tParsedFields.add(tParsed);
        }
      });
    }

    this.fields = tParsedFields;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();

    data['fields'] =
        fields.map((e) => EnumToString.convertToString(e)).toList();
    return data;
  }
}

class SquadNameFilter extends SquadRankingFilter {
  late final List<String> squadNames;

  SquadNameFilter(String name, this.squadNames)
      : super(name, const [
          SquadRankingFields.Pts,
          SquadRankingFields.W_T_L,
          SquadRankingFields.SumIndividualScore,
          SquadRankingFields.OppScore,
          SquadRankingFields.SumTd,
          SquadRankingFields.SumCas,
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
