import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  User? user;
  String? nafName;
  String? error;

  AuthUser({this.user, this.error}) {
    this.nafName = this.user?.displayName;
  }

  AuthUser.nafNameOnly({this.nafName});
}
