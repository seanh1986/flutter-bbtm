import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [email, id, name, photo];

  String getNafName() {
    return name != null
        ? name!.trim()
        : (email != null && email!.contains("@naf.com")
            ? _extractBeforeAt(email!)
            : "");
  }

  String getEmail() {
    return email != null ? email as String : "";
  }

  bool isAccountUser() {
    return !isSpectator() &&
        !isNafNameLogin() &&
        email != null &&
        email!.isNotEmpty;
  }

  bool isSpectator() {
    return email == null ||
        email!.isEmpty ||
        email!.trim().toLowerCase() == createSpectatorLogin();
  }

  bool isNafNameLogin() {
    return email == null ||
        email!.isEmpty ||
        email!.trim().toLowerCase() == getNafName().toLowerCase() + "@naf.com";
  }

  // Fake email: nafname@naf.com
  static String createNafNameLogin(String nafName) {
    return nafName.trim().toLowerCase() + "@naf.com";
  }

  // Fake email for spectator
  static String createSpectatorLogin() {
    return "spectator@nafspec.com";
  }

  static String _extractBeforeAt(String input) {
    final regex = RegExp(r'^[^@]+');
    final match = regex.firstMatch(input);
    return match?.group(0) ?? '';
  }
}
