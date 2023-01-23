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

  late double winPts = 5;
  late double tiePts = 3;
  late double lossPts = 1;

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
      this.dateTimeEnd = tEnd.toDate();
    } else {
      throw UnsupportedError('Invalid data: $json -> "DateTimeEnd" is missing');
    }

    final tOrganizers = json['organizers'] as List<dynamic>?;
    if (tOrganizers != null) {
      tOrganizers.forEach((tOrga) {
        organizers.add(OrganizerInfo.fromJson(tOrga as Map<String, dynamic>));
      });
    }

    final tWinPts = json['win_pts'] as double?;
    if (tWinPts != null) {
      this.winPts = tWinPts;
    }

    final tTiePts = json['tie_pts'] as double?;
    if (tTiePts != null) {
      this.tiePts = tTiePts;
    }

    final tLossPts = json['loss_pts'] as double?;
    if (tLossPts != null) {
      this.lossPts = tLossPts;
    }
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Location': location,
        'DateTimeStart': Timestamp.fromDate(dateTimeStart),
        'DateTimeEnd': Timestamp.fromDate(dateTimeEnd),
        'organizers': organizers.map((e) => e.toJson()).toList(),
        'win_pts': winPts,
        'tie_pts': tiePts,
        'loss_pts': lossPts,
      };
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
