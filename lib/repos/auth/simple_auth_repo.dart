import 'package:bbnaf/repos/auth/auth_repo.dart';

class SimpleAuthRepository extends AuthRepository {
  String? _nafName;

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
}
