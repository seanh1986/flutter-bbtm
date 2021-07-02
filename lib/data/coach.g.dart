// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coach _$CoachFromJson(Map<String, dynamic> json) {
  return Coach(
    json['nafName'] as String,
    json['squadName'] as String,
    json['name'] as String,
    json['race'] as String,
    json['wins'] as int,
    json['ties'] as int,
    json['losses'] as int,
    json['points'] as int,
    json['tds'] as int,
    json['cas'] as int,
    json['stunty'] as bool,
  );
}

Map<String, dynamic> _$CoachToJson(Coach instance) => <String, dynamic>{
      'nafName': instance.nafName,
      'squadName': instance.squadName,
      'name': instance.name,
      'race': instance.race,
      'wins': instance.wins,
      'ties': instance.ties,
      'losses': instance.losses,
      'points': instance.points,
      'tds': instance.tds,
      'cas': instance.cas,
      'stunty': instance.stunty,
    };
