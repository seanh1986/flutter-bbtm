import 'package:bbnaf/models/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTournamentRepository extends TournamentRepository {
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
}
