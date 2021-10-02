import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository extends AuthRepository {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Future<void> signInWithCredentials(String email, String password) {
  //   return _firebaseAuth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  // }

  // Future<void> signUp(
  //     {required String nafName,
  //     required String email,
  //     required String password}) async {
  //   User? user = (await _firebaseAuth.signInWithEmailAndPassword(
  //           email: email, password: password))
  //       .user;

  //   return user!.updateDisplayName(nafName);
  // }

  void signIn(String nafName) {}

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  String? getUserDisplayName() {
    return _firebaseAuth.currentUser!.displayName;
  }
}
