import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory TournamentInfo.fromJson(Map<String, Object?> json) {
    // final id = json['id'] as int?;
    // if (id == null) {
    //   throw UnsupportedError('Invalid data: $json -> "id" is missing');
    // }
    final id = 0;

    final name = json['Name'] as String?;
    if (name == null) {
      throw UnsupportedError('Invalid data: $json -> "Name" is missing');
    }

    final location = json['Location'] as String?;
    if (location == null) {
      throw UnsupportedError('Invalid data: $json -> "Location" is missing');
    }

    final Timestamp? t_start = json['DateTimeStart'] as Timestamp?;
    if (t_start == null) {
      throw UnsupportedError(
          'Invalid data: $json -> "DateTimeStart" is missing');
    }
    final dateTimeStart = t_start.toDate();

    final Timestamp? t_end = json['DateTimeEnd'] as Timestamp?;
    if (t_end == null) {
      throw UnsupportedError('Invalid data: $json -> "DateTimeEnd" is missing');
    }
    final dateTimeEnd = t_start.toDate();

    return TournamentInfo(
        id: id,
        name: name,
        location: location,
        dateTimeStart: dateTimeStart,
        dateTimeEnd: dateTimeEnd);
  }
  // : this(
  //     id: json['id'] as int,
  //     name: json['name']! as String,
  //     location: json['location']! as String,
  //     dateTimeStart: DateTime.parse(json['dateTimeStart'].toString()),
  //     dateTimeEnd: DateTime.parse(json['dateTimeEnd'].toString()),
  //   );

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
