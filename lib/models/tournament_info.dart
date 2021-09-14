import 'package:flutter/foundation.dart';

@immutable
class TournamentInfo {
  final int id;
  final String name;
  final String location;
  final DateTime dateTimeStart;
  final DateTime dateTimeEnd;

  TournamentInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.dateTimeStart,
    required this.dateTimeEnd,
  });

  TournamentInfo.fromJson(Map<String, Object?> json)
      : this(
          id: json['id']! as int,
          name: json['name']! as String,
          location: json['location']! as String,
          dateTimeStart: DateTime.parse(json['dateTimeStart'].toString()),
          dateTimeEnd: DateTime.parse(json['dateTimeEnd'].toString()),
        );

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'dateTimeStart': dateTimeStart,
      'dateTimeEnd': dateTimeEnd,
    };
  }
}
