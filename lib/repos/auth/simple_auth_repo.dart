// import 'package:bbnaf/repos/auth/auth_repo.dart';
// import 'package:bbnaf/repos/auth/auth_user.dart';

// class SimpleAuthRepository extends AuthRepository {
//   String? _nafName;

//   Future<AuthUser> signInWithCredentials(String email, String password) async {
//     return AuthUser();
//   }

//   Future<AuthUser> signUp(
//       {required String nafName,
//       required String email,
//       required String password}) async {
//     return AuthUser();
//   }

//   void signIn(String nafName) {
//     _nafName = nafName;
//   }

//   Future<void> signOut() async {
//     _nafName = null;
//   }

//   Future<bool> isSignedIn() async {
//     return _nafName != null;
//   }

//   String? getUserDisplayName() {
//     return _nafName;
//   }

//   String? getUserEmail() {
//     return null;
//   }

//   AuthUser getAuthUser() {
//     return new AuthUser();
//   }
// }
