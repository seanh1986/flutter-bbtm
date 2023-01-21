import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/reported_match_result.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseTournamentRepository extends TournamentRepository {
  firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  // FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to tournament info list
  // Converter guarantees type safety
  final _tournamentInfoRef =
      FirebaseFirestore.instance.collection("tournaments");
  // .withConverter<TournamentInfo>(
  //   fromFirestore: (snapshots, _) =>
  //       TournamentInfo.fromJson(snapshots.data()!),
  //   toFirestore: (tournamentInfo, _) => tournamentInfo.toJson(),
  // );

  @override
  Stream<List<TournamentInfo>> getTournamentInfos() {
    print("FirebaseTournamentRepository: getTournamentInfos");
    return _tournamentInfoRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TournamentInfo.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Stream<Tournament> getTournamentData(String tournamentId) async* {
    print("FirebaseTournamentRepository: getTournamentData");

    Tournament t = await _tournamentInfoRef
        .doc(tournamentId)
        .get()
        .then((value) => _parseTournamentResponse(value));

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

  @override
  Future<void> updateTournamentInfo(TournamentInfo tournamentInfo) async {
    Map<String, Object?> json =
        tournamentInfo.toJson().map((key, value) => value);
    return _tournamentInfoRef.doc(tournamentInfo.id).set(json);
  }

  @override
  Future<void> updateTournamentData(Tournament tournament) async {
    Map<String, dynamic> jsonA = tournament.info.toJson();

    jsonA.putIfAbsent("data", () => tournament.toJson());

    Map<String, Object?> json =
        jsonA.map((key, value) => MapEntry<String, Object?>(key, value));

    return _tournamentInfoRef.doc(tournament.info.id).set(json);
  }

  @override
  Future<void> updateCoachMatchReport(
      Tournament tournament, CoachMatchup matchup, bool isHome) async {
    Tournament dbTournament = await _tournamentInfoRef
        .doc(tournament.info.id)
        .get()
        .then((value) => _parseTournamentResponse(value));

    if (dbTournament.coachRounds.length != tournament.coachRounds.length) {
      return;
    }

    int roundIdx = dbTournament.coachRounds.length - 1;

    int matchIdx = dbTournament.coachRounds.last.matches.indexWhere((e) =>
        e.awayNafName == matchup.awayNafName &&
        e.homeNafName == matchup.homeNafName);

    if (roundIdx < 0 || matchIdx < 0) {
      return;
    }

    if (isHome) {
      dbTournament.coachRounds[roundIdx].matches[matchIdx].homeReportedResults =
          matchup.homeReportedResults;
    } else {
      dbTournament.coachRounds[roundIdx].matches[matchIdx].homeReportedResults =
          matchup.awayReportedResults;
    }

    updateTournamentData(dbTournament);
  }

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
  //   if (kIsWeb) {
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
  //   if (kIsWeb) {
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
}
