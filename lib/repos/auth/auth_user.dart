import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  User? user;
  String? _nafName;
  String? error;

  AuthUser({this.user, this.error}) {
    this._nafName = this.user?.displayName;
  }

  AuthUser.nafNameOnly(String nafName) {
    this._nafName = nafName;
  }

  String getNafName() {
    if (_nafName == null) {
      _nafName = user?.displayName;
    }

    return _nafName != null ? _nafName! : "";
  }
}
