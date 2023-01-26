import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentInfo {
  late final String id;
  late final String name;
  late final String location;
  late final DateTime dateTimeStart;
  late final DateTime dateTimeEnd;
  List<OrganizerInfo> organizers = [];

  ScoringDetails scoringDetails = ScoringDetails();

  String detailsWeather = "";
  String detailsKickOff = "";
  String detailsSpecialRules = "";

  TournamentInfo(
      {required this.id,
      required this.name,
      required this.location,
      required this.dateTimeStart,
      required this.dateTimeEnd});

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

    final tScoringDetails = json['scoring_details'] as Map<String, dynamic>?;
    if (tScoringDetails != null) {
      this.scoringDetails = ScoringDetails.fromJson(tScoringDetails);
    }
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Location': location,
        'DateTimeStart': Timestamp.fromDate(dateTimeStart),
        'DateTimeEnd': Timestamp.fromDate(dateTimeEnd),
        'organizers': organizers.map((e) => e.toJson()).toList(),
        'scoring_details': scoringDetails.toJson(),
      };
}

// enum TieBreakers {
//   OpponentStrength,
//   TD,
// }

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

class ScoringDetails {
  double winPts = 5;
  double tiePts = 3;
  double lossPts = 1;

  CasualtyDetails casualtyDetails = CasualtyDetails();

  ScoringDetails();

  ScoringDetails.fromJson(Map<String, dynamic> json) {
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

    final tCasDetails = json['casualty_details'] as Map<String, dynamic>?;
    if (tCasDetails != null) {
      this.casualtyDetails = CasualtyDetails.fromJson(tCasDetails);
    }
  }

  Map<String, dynamic> toJson() => {
        'win_pts': winPts,
        'tie_pts': tiePts,
        'loss_pts': lossPts,
        'casualty_details': casualtyDetails.toJson(),
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
