// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Squad _$SquadFromJson(Map<String, dynamic> json) {
  return Squad(
    json['name'] as String,
    (json['coaches'] as List).map((e) => e as String).toList(),
    json['wins'] as int,
    json['ties'] as int,
    json['losses'] as int,
    json['points'] as int,
    json['stunty'] as bool,
  );
}

Map<String, dynamic> _$SquadToJson(Squad instance) => <String, dynamic>{
      'name': instance.name,
      'coaches': instance.coaches,
      'wins': instance.wins,
      'ties': instance.ties,
      'losses': instance.losses,
      'points': instance.points,
      'stunty': instance.stunty,
    };
