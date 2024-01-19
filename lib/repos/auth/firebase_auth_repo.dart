// import 'package:bbnaf/repos/auth/auth_repo.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:bbnaf/repos/auth/auth_user.dart';

// class FirebaseAuthRepository extends AuthRepository {
//   FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   FirebaseAuthRepository() {
//     _firebaseAuth.setPersistence(Persistence.LOCAL);
//   }

//   Future<AuthUser> signInWithCredentials(String email, String password) async {
//     AuthUser authUser = AuthUser();

//     try {
//       UserCredential userCredential =
//           await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       authUser.user = userCredential.user;

//       debugPrint('Sign In Successful. Email: ${authUser.user?.email}');
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         authUser.error = 'No user found for email: $email.';
//         print(authUser.error);
//       } else if (e.code == 'wrong-password') {
//         authUser.error = 'Wrong password provided for email: $email';
//         print(authUser.error);
//       }
//     }

//     return authUser;
//   }

//   Future<AuthUser> signUp(
//       {required String nafName,
//       required String email,
//       required String password}) async {
//     AuthUser authUser = AuthUser();

//     try {
//       UserCredential userCredential =
//           await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       authUser.user = userCredential.user;
//       await authUser.user!.updateDisplayName(nafName);
//       await authUser.user!.reload();
//       authUser.user = _firebaseAuth.currentUser;

//       debugPrint('Sign Up Successful. Email: ${authUser.user?.email}');
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         authUser.error = 'The password provided is too weak.';
//         print(authUser.error);
//       } else if (e.code == 'email-already-in-use') {
//         authUser.error =
//             'Account already exists for email: ${authUser.user?.email}';
//         print(authUser.error);
//       }
//     } catch (e) {
//       authUser.error = e.toString();
//       print(e);
//     }

//     return authUser;
//   }

//   void signIn(String nafName) {}

//   Future<void> signOut() async {
//     return await _firebaseAuth.signOut();
//   }

//   Future<bool> isSignedIn() async {
//     return _firebaseAuth.currentUser != null;
//   }

//   String? getUserDisplayName() {
//     return _firebaseAuth.currentUser!.displayName;
//   }

//   String? getUserEmail() {
//     return _firebaseAuth.currentUser!.email;
//   }

//   AuthUser getAuthUser() {
//     return AuthUser(user: _firebaseAuth.currentUser, error: "");
//   }
// }
