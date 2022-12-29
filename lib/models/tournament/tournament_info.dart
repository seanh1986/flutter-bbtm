import 'dart:core';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentInfo {
  late final String id;
  late final String name;
  late final String location;
  late final DateTime dateTimeStart;
  late final DateTime dateTimeEnd;
  List<OrganizerInfo> organizers = [];

  TournamentInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.dateTimeStart,
    required this.dateTimeEnd,
  });

  TournamentInfo.fromJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;

    final tName = json['Name'] as String?;
    if (tName != null) {
      this.name = tName;
    } else {
      throw UnsupportedError('Invalid data: $json -> "Name" is missing');
    }

    final tLocation = json['Location'] as String?;
    if (tLocation != null) {
      this.location = tLocation;
    } else {
      throw UnsupportedError('Invalid data: $json -> "Location" is missing');
    }

    final Timestamp? tStart = json['DateTimeStart'] as Timestamp?;
    if (tStart != null) {
      this.dateTimeStart = tStart.toDate();
    } else {
      throw UnsupportedError(
          'Invalid data: $json -> "DateTimeStart" is missing');
    }

    final Timestamp? tEnd = json['DateTimeEnd'] as Timestamp?;
    if (tEnd != null) {
      this.dateTimeEnd = tStart.toDate();
    } else {
      throw UnsupportedError('Invalid data: $json -> "DateTimeEnd" is missing');
    }

    final tOrganizers = json['organizers'] as List<dynamic>?;
    if (tOrganizers != null) {
      tOrganizers.forEach((tOrga) {
        organizers.add(OrganizerInfo.fromJson(tOrga as Map<String, dynamic>));
      });
    }
  }

  Map toJson() => {
        'Name': name,
        'Location': location,
        'DateTimeStart': dateTimeStart,
        'DateTimeEnd': dateTimeEnd,
        'organizers': jsonEncode(organizers),
      };
}

class OrganizerInfo {
  late String email;
  late String nafName;

  OrganizerInfo(this.email, this.nafName);

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
  }

  Map toJson() => {
        'email': email,
        'nafName': nafName,
      };
}
