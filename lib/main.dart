
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:bbnaf/app/bloc_observer.dart';
import 'package:bbnaf/app/view/app.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';

// Conditional imports based on environment
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

Future<void> main() async {
  print("main started!");

  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  print("Before Firebase Init!");

  const String environment =
      String.fromEnvironment('ENV', defaultValue: 'prod');

  FirebaseOptions options;
  if (environment == 'dev') {
    options = dev.firebaseOptions;
  } else {
    options = prod.firebaseOptions;
  }

  await Firebase.initializeApp(options: options);

  print("Firebase initialized!");

  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  final tournamentRepository = TournamentRepository();

  runApp(App(
    authenticationRepository: authenticationRepository,
    tournamentRepository: tournamentRepository,
  ));
}
