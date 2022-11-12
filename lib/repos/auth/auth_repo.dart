import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithCredentials(String email, String password);

  Future<User?> signUp(
      {required String nafName,
      required String email,
      required String password});

  void signIn(String nafName);

  Future<void> signOut();

  Future<bool> isSignedIn();

  // Returns null if user not signed in
  String? getUserDisplayName();

  // Returns null if user not signed in
  String? getUserEmail();
}
