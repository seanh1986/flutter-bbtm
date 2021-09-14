import 'package:bbnaf/models/tournament_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to tournament info list
  // Converter guarantees type safety
  final _tournamentInfoRef = FirebaseFirestore.instance
      .collection("tournaments")
      .withConverter<TournamentInfo>(
        fromFirestore: (snapshots, _) =>
            TournamentInfo.fromJson(snapshots.data()!),
        toFirestore: (tournamentInfo, _) => tournamentInfo.toJson(),
      );

  Stream<QuerySnapshot<TournamentInfo>> tournamentList() {
    return _tournamentInfoRef.snapshots();
  }

  // Stream<QuerySnapshot> othersGoalList() {
  //   return _firestore
  //       .collection("users")
  //       .where('goalAdded', isEqualTo: true)
  //       .snapshots();
  // }
}
