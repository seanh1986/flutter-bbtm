import 'dart:convert';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/app/app.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:cache/cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class TournamentRepository {
  TournamentRepository({
    CacheClient? cache,
  }); // : _cache = cache ?? CacheClient();

  // final CacheClient _cache;

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// TournamentList cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const tournamentListCacheKey = '__tournament_list_cache_key__';

  /// Tournament cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const tournamentCacheKey = '__tournament_cache_key__';

  FirebaseStorage _storage = FirebaseStorage.instance;

  // Reference to tournament info list
  // Converter guarantees type safety
  final _tournyRef = FirebaseFirestore.instance.collection("tournaments");

  // ------------------
  // Read only operations
  // ------------------

  // Future<void> requestTournamentList() async {}

  Future<Tournament> requestTournament(String tournamentId) async {
    Tournament t = await _tournyRef
        .doc(tournamentId)
        .get()
        .then((value) => _parseTournamentResponse(value));

    return t;
  }

  List<TournamentInfo>? _tournamentList;

  List<TournamentInfo>? getCurrentTournamentList() {
    return _tournamentList;
  }

  Stream<List<TournamentInfo>> getTournamentList() {
    print("TournamentRepository: tournamentList");

    return _tournyRef.snapshots().map((snapshot) {
      List<TournamentInfo> tournies = [];

      snapshot.docs.forEach((doc) {
        try {
          TournamentInfo info = TournamentInfo.fromJson(doc.id, doc.data());
          tournies.add(info);
        } catch (_) {
          print("failed to parse tournamentId: " + doc.id.toString());
        }
      });

      _tournamentList = List.from(tournies);

      return tournies;
    });
  }

  Stream<Tournament> getTournamentData(String tournamentId) async* {
    print("TournamentRepository: getTournamentData");

    Tournament t = await requestTournament(tournamentId);

    yield t;
  }

  Tournament _parseTournamentResponse(
      DocumentSnapshot<Map<String, dynamic>> value) {
    String tournamentId = value.id;

    if (!value.exists || value.data() == null) {
      TournamentInfo tournamentInfo =
          TournamentInfo.fromJson(tournamentId, Map<String, dynamic>());
      return Tournament.fromJson(tournamentInfo, Map<String, dynamic>());
    }

    TournamentInfo tournamentInfo =
        TournamentInfo.fromJson(tournamentId, value.data()!);

    if (!value.data()!.containsKey("data")) {
      return Tournament.fromJson(tournamentInfo, Map<String, dynamic>());
    }

    Map<String, dynamic> json = value.data()!['data'];

    return Tournament.fromJson(tournamentInfo, json);
  }

  Future<Tournament?> getTournamentDataAsync(String tournamentId) async {
    try {
      Tournament t = await _tournyRef
          .doc(tournamentId)
          .get()
          .then((value) => _parseTournamentResponse(value));
      return t;
    } catch (_) {
      return null;
    }
  }

// @override
// Future<void> updateTournamentInfo(TournamentInfo tournamentInfo) async {
//   Map<String, Object?> json =
//       tournamentInfo.toJson().map((key, value) => value);
//   return _tournyRef.doc(tournamentInfo.id).set(json);
// }

  // ------------------
  // Update Operations
  // ------------------

  Future<bool> overwriteTournamentInfo(
      TournamentInfo info, bool allowOverwriteLock) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(info.id);

        var doc = await tRef.get();
        if (!doc.exists) {
          return false;
        }

        Tournament dbTournament = _parseTournamentResponse(doc);
        if (!allowOverwriteLock && info.locked && dbTournament.isLocked()) {
          // Then not allowed to overwrite
          return false;
        }

        bool force = dbTournament.info.locked != info.locked;

        dbTournament.info = info;

        await _overrwiteTournamentData(dbTournament, force: force);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> overwriteCoaches(String tournamentId, List<Coach> newCoaches,
      List<RenameNafName> renames) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(tournamentId);

        var doc = await tRef.get();
        if (!doc.exists) {
          return false;
        }

        Tournament dbTournament = _parseTournamentResponse(doc);
        if (dbTournament.isLocked()) {
          return false;
        }

        dbTournament.updateCoaches(newCoaches, renames);

        await _overrwiteTournamentData(dbTournament);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCoachMatchReport(UpdateMatchReportEvent event) async {
    return updateCoachMatchReports([event]);
  }

  Future<bool> swapCoachMatchups(
      String tournamentId, CoachRound newRoundMatchups) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(tournamentId);

        var doc = await tRef.get();
        if (!doc.exists) {
          return false;
        }

        Tournament dbTournament = _parseTournamentResponse(doc);

        if (dbTournament.coachRounds.last.round() == newRoundMatchups.round()) {
          dbTournament.coachRounds.last = newRoundMatchups;
        }

        await _overrwiteTournamentData(dbTournament);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCoachMatchReports(
      List<UpdateMatchReportEvent> events) async {
    Tournament tournament = events.first.tournament;
    if (tournament.isLocked()) {
      return false;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(tournament.info.id);

        var doc = await tRef.get();
        if (!doc.exists) {
          return false;
        }

        Tournament dbTournament = _parseTournamentResponse(doc);

        if (dbTournament.isLocked()) {
          return false;
        }

        if (dbTournament.coachRounds.length != tournament.coachRounds.length) {
          throw new Exception("Tournament lengths do not align");
        }

        events.forEach((event) {
          int roundIdx = dbTournament.coachRounds.length - 1;

          int matchIdx = dbTournament.coachRounds.last.matches.indexWhere((e) =>
              e.awayNafName.toLowerCase() ==
                  event.matchup.awayNafName.toLowerCase() &&
              e.homeNafName.toLowerCase() ==
                  event.matchup.homeNafName.toLowerCase());

          if (roundIdx < 0 || matchIdx < 0) {
            throw new Exception("Couldn't find index match");
          }

          if (event.isHome) {
            dbTournament.coachRounds[roundIdx].matches[matchIdx]
                .homeReportedResults = event.matchup.homeReportedResults;
          } else if (event.isAdmin) {
            dbTournament.coachRounds[roundIdx].matches[matchIdx]
                .homeReportedResults = event.matchup.homeReportedResults;
            dbTournament.coachRounds[roundIdx].matches[matchIdx]
                .awayReportedResults = event.matchup.awayReportedResults;
          } else {
            dbTournament.coachRounds[roundIdx].matches[matchIdx]
                .awayReportedResults = event.matchup.awayReportedResults;
          }
        });

        await _overrwiteTournamentData(dbTournament);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSquadBonusPts(UpdateSquadBonusPts event) async {
    Tournament tournament = event.tournament;
    if (tournament.isLocked()) {
      return false;
    }

    try {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(tournament.info.id);

        var doc = await tRef.get();
        if (!doc.exists) {
          return false;
        }

        Tournament dbTournament = _parseTournamentResponse(doc);
        if (dbTournament.isLocked()) {
          return false;
        }

        if (dbTournament.coachRounds.length != tournament.coachRounds.length) {
          throw new Exception("Tournament lengths do not align");
        }

        for (int i = 0; i < tournament.coachRounds.length; i++) {
          dbTournament.coachRounds[i].squadBonuses =
              Map.from(tournament.coachRounds[i].squadBonuses);
        }

        await _overrwiteTournamentData(dbTournament);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recoverTournamentBackup(Tournament t) async {
    if (t.isLocked()) {
      return false;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await _overrwiteTournamentData(t);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> advanceRound(Tournament t) async {
    if (t.isLocked()) {
      return false;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await _overrwiteTournamentData(t);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> discardCurrentRound(Tournament t) async {
    if (t.isLocked()) {
      return false;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var tRef = _tournyRef.doc(t.info.id);

        var doc = await tRef.get();

        Tournament dbTournament = _parseTournamentResponse(doc);

        if (dbTournament.isLocked()) {
          return false;
        }

        if (dbTournament.coachRounds.length != t.coachRounds.length) {
          throw new Exception("Tournament coach round lengths do not align");
        } else if (dbTournament.squadRounds.length != t.squadRounds.length) {
          throw new Exception("Tournament squad round lengths do not align");
        }

        if (dbTournament.squadRounds.isNotEmpty) {
          dbTournament.squadRounds.removeLast();
        }

        if (dbTournament.coachRounds.isNotEmpty) {
          dbTournament.coachRounds.removeLast();
        }

        await _overrwiteTournamentData(dbTournament);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _overrwiteTournamentData(Tournament tournament,
      {bool force = false}) async {
    if (tournament.isLocked() && !force) {
      return;
    }

    Map<String, dynamic> jsonA = tournament.info.toJson();

    jsonA.putIfAbsent("data", () => tournament.toJson());

    Map<String, Object?> json =
        jsonA.map((key, value) => MapEntry<String, Object?>(key, value));

    await _tournyRef.doc(tournament.info.id).set(json);
  }

  // ------------------
  // File Downloads
  // ------------------

  Future<String> getFileUrl(String filename) async {
    var url = await _storage.ref().child(filename).getDownloadURL();
    // print(url.toString());

    // final ref = _storage.ref().child(filename);

    // var url = await ref.getDownloadURL();
    // print(url);
    return url;
  }

  Future<bool> downloadFile(String filename) async {
    if (filename.isEmpty) {
      return false;
    }
    if (isWeb) {
      return _downloadFileWeb(filename);
    }
    // else {
    //   _downloadFileMobile(filename);
    // }

    return false;
  }

  Future<bool> _downloadFileWeb(String filename) async {
    try {
      Uint8List? data = await _storage.ref(filename).getData();
      if (data == null) {
        return false;
      }

      String encodedData = base64Encode(data);

      html.AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-8;base64,$encodedData')
        ..setAttribute('download', filename)
        ..click();

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> downloadBackupFile(Tournament tournament) async {
    try {
      TournamentBackup backup = TournamentBackup(tournament: tournament);
      String json = jsonEncode(backup);

      String time = DateFormat('yyyy_MM_dd_H_m_s').format(DateTime.now());
      String fileName = time +
          "_" +
          tournament.info.name.replaceAll(" ", "_") +
          "_" +
          "round_" +
          tournament.curRoundNumber().toString() +
          ".json";

      print(fileName);

      return _downloadFile(fileName, json);
    } catch (_) {
      return false;
    }
  }

  Future<bool> downloadNafUploadFile(Tournament tournament) async {
    try {
      XmlDocument xml = tournament.generateNafUploadFile();
      String contents = xml.toXmlString(pretty: true, indent: '\t');

      String time = DateFormat('yyyy_MM_dd_H_m_s').format(DateTime.now());
      String fileName = time +
          "_" +
          tournament.info.name.replaceAll(" ", "_") +
          "_" +
          "naf_upload" +
          ".xml";

      print(fileName);

      return _downloadFile(fileName, contents);
    } catch (_) {
      return false;
    }
  }

  Future<bool> downloadGlamFile(Tournament tournament) async {
    try {
      XmlDocument xml = tournament.generateGlamFile();
      String contents = xml.toXmlString(pretty: true, indent: '\t');

      String time = DateFormat('yyyy_MM_dd_H_m_s').format(DateTime.now());
      String fileName = time +
          "_" +
          tournament.info.name.replaceAll(" ", "_") +
          "_" +
          "glam" +
          ".xml";

      print(fileName);

      return _downloadFile(fileName, contents);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _downloadFile(String fileName, String contents) async {
    try {
      // prepare
      final bytes = utf8.encode(contents);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      return true;
    } catch (_) {
      return false;
    }
  }
}




// Future<void> _downloadFileMobile(String filename) async {
//   //First you get the documents folder location on the device...
//   Directory appDocDir = await getApplicationDocumentsDirectory();
//   File downloadToFile = File('${appDocDir.path}/' + filename);

//   //Now you can try to download the specified file, and write it to the downloadToFile.
//   try {
//     await _storage.ref(filename).writeToFile(downloadToFile);
//   } on firebase_core.FirebaseException catch (e) {
//     // e.g, e.code == 'canceled'
//     print('Download error: $e');
//   }
// }

  // Future<Widget> getImage(BuildContext context, String image) async {
  //   Image m;
  //   await FireStorageService.loadFromStorage(context, image)
  //       .then((downloadUrl) {
  //     m = Image.network(
  //       downloadUrl.toString(),
  //       fit: BoxFit.scaleDown,
  //     );
  //   });

  //   return m;
  // }

  // @override
  // Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo) async* {
  //   firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
  //       .ref(tournamentInfo.id + '.bbd');

  //   XmlDocument xml = await _downloadTournamentFile(ref);

  //   Tournament t = Tournament.fromXml(xml, tournamentInfo);

  //   yield t;
  // }

  // Future<XmlDocument> _downloadTournamentFile(
  //     firebase_storage.Reference ref) async {
  //   if (isWeb) {
  //     return _downloadTournamentFileWeb(ref);
  //   } else {
  //     return _downloadTournamentFileMobile(ref);
  //   }
  // }

  // Future<XmlDocument> _downloadTournamentFileWeb(
  //     firebase_storage.Reference ref) async {
  //   final bytes = await ref.getData();

  //   print(
  //       'Success!\n Downloaded BYTES: ${ref.name} \n from bucket: ${ref.bucket}\n '
  //       'at path: ${ref.fullPath}');

  //   String s = new String.fromCharCodes(bytes!);

  //   final document = XmlDocument.parse(s);

  //   print(document.toXmlString(pretty: true, indent: '\t'));

  //   return document;
  // }

  // // TO BE TESTED
  // Future<XmlDocument> _downloadTournamentFileMobile(
  //     firebase_storage.Reference ref) async {
  //   final io.Directory systemTempDir = io.Directory.systemTemp;
  //   final io.File tempFile = io.File('${systemTempDir.path}/${ref.name}');
  //   if (tempFile.existsSync()) await tempFile.delete();

  //   await ref.writeToFile(tempFile);

  //   print(
  //       'Success!\n Downloaded FILE: ${ref.name} \n from bucket: ${ref.bucket}\n '
  //       'at path: ${ref.fullPath} \n'
  //       'Wrote "${ref.fullPath}" to ref.name');

  //   final document = XmlDocument.parse(tempFile.readAsStringSync());

  //   print(document.toXmlString(pretty: true, indent: '\t'));

  //   return document;
  // }

  // Future<void> _download(firebase_storage.Reference ref) async {
  //   if (isWeb) {
  //     return _downloadBytes(ref);
  //   } else {
  //     return _downloadFile(ref);
  //   }
  // }

  // Future<void> _downloadBytes(firebase_storage.Reference ref) async {
  //   final bytes = await ref.getData();
  //   // Download...

  //   print(
  //       'Success!\n Downloaded BYTES: ${ref.name} \n from bucket: ${ref.bucket}\n '
  //       'at path: ${ref.fullPath}');

  //   String s = new String.fromCharCodes(bytes!);
  //   // var outputAsUint8List = new Uint8List.fromList(s.codeUnits);

  //   await saveAsBytes(bytes, ref.name);

  //   print('Success!\n Wrote "${ref.fullPath}" to ${ref.name}');
  // }

  // Future<void> _downloadLink(firebase_storage.Reference ref) async {
  //   final link = await ref.getDownloadURL();

  //   print('Success!\n download URL: $link');
  // }

  // Future<void> _downloadFile(firebase_storage.Reference ref) async {
  //   final io.Directory systemTempDir = io.Directory.systemTemp;
  //   final io.File tempFile = io.File('${systemTempDir.path}/${ref.name}');
  //   if (tempFile.existsSync()) await tempFile.delete();

  //   await ref.writeToFile(tempFile);

  //   print(
  //       'Success!\n Downloaded FILE: ${ref.name} \n from bucket: ${ref.bucket}\n '
  //       'at path: ${ref.fullPath} \n'
  //       'Wrote "${ref.fullPath}" to ref.name');
  // }
// }
