import 'package:bbnaf/models/tournament.dart';
import 'package:bbnaf/models/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bbnaf/utils/save_as/save_as.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

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
  Stream<Tournament> downloadTournament(TournamentInfo tournamentInfo) async* {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref(tournamentInfo.id + '.bbd');

    await _download(ref);

    Tournament t = Tournament.getExampleTournament(tournamentInfo.name,
        tournamentInfo.location, tournamentInfo.dateTimeStart.toString());

    yield t;
  }

  Future<void> _download(firebase_storage.Reference ref) async {
    if (kIsWeb) {
      return _downloadBytes(ref);
    } else {
      return _downloadFile(ref);
    }
  }

  Future<void> _downloadBytes(firebase_storage.Reference ref) async {
    final bytes = await ref.getData();
    // Download...

    print(
        'Success!\n Downloaded BYTES: ${ref.name} \n from bucket: ${ref.bucket}\n '
        'at path: ${ref.fullPath}');

    await saveAsBytes(bytes!, ref.name);

    print('Success!\n Wrote "${ref.fullPath}" to ${ref.name}');
  }

  Future<void> _downloadLink(firebase_storage.Reference ref) async {
    final link = await ref.getDownloadURL();

    print('Success!\n download URL: $link');
  }

  Future<void> _downloadFile(firebase_storage.Reference ref) async {
    final io.Directory systemTempDir = io.Directory.systemTemp;
    final io.File tempFile = io.File('${systemTempDir.path}/${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    print(
        'Success!\n Downloaded FILE: ${ref.name} \n from bucket: ${ref.bucket}\n '
        'at path: ${ref.fullPath} \n'
        'Wrote "${ref.fullPath}" to ref.name');
  }
}
