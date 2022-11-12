import 'package:bbnaf/repos/auth/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimpleAuthRepository extends AuthRepository {
  String? _nafName;

  Future<User?> signInWithCredentials(String email, String password) async {
    return null;
  }

  Future<User?> signUp(
      {required String nafName,
      required String email,
      required String password}) async {
    return null;
  }

  void signIn(String nafName) {
    _nafName = nafName;
  }

  Future<void> signOut() async {
    _nafName = null;
  }

  Future<bool> isSignedIn() async {
    return _nafName != null;
  }

  String? getUserDisplayName() {
    return _nafName;
  }

  String? getUserEmail() {
    return null;
  }
}
