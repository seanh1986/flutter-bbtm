abstract class AuthRepository {
  // Future<void> signInWithCredentials(String email, String password);

  // Future<void> signUp(
  //     {required String nafName,
  //     required String email,
  //     required String password});

  void signIn(String nafName);

  Future<void> signOut();

  Future<bool> isSignedIn();

  // Returns null if user not signed in
  String? getUserDisplayName();
}
