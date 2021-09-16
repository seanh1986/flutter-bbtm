import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class TournamentInfo {
  final String id;
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

  factory TournamentInfo.fromJson(
      String documentId, Map<String, Object?> json) {
    final name = json['Name'] as String?;
    if (name == null) {
      throw UnsupportedError('Invalid data: $json -> "Name" is missing');
    }

    final location = json['Location'] as String?;
    if (location == null) {
      throw UnsupportedError('Invalid data: $json -> "Location" is missing');
    }

    final Timestamp? tStart = json['DateTimeStart'] as Timestamp?;
    if (tStart == null) {
      throw UnsupportedError(
          'Invalid data: $json -> "DateTimeStart" is missing');
    }
    final dateTimeStart = tStart.toDate();

    final Timestamp? tEnd = json['DateTimeEnd'] as Timestamp?;
    if (tEnd == null) {
      throw UnsupportedError('Invalid data: $json -> "DateTimeEnd" is missing');
    }
    final dateTimeEnd = tStart.toDate();

    return TournamentInfo(
        id: documentId,
        name: name,
        location: location,
        dateTimeStart: dateTimeStart,
        dateTimeEnd: dateTimeEnd);
  }

  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Location': location,
      'DateTimeStart': dateTimeStart,
      'DateTimeEnd': dateTimeEnd,
    };
  }
}
