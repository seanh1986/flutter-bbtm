import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc_observer.dart';
import 'package:bbnaf/app/view/app.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  print("main started!");

  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  print("Before Firebase Init!");

  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB-TUGMpvec35ON6FPU7U0OIwZtZ4bnERE",
          authDomain: "bbtournaments-eaa1e.firebaseapp.com",
          projectId: "bbtournaments-eaa1e",
          storageBucket: "bbtournaments-eaa1e.appspot.com",
          messagingSenderId: "432579212807",
          appId: "1:432579212807:web:f1b596fdecf5ea67dddca2",
          measurementId: "G-S8H1Y9BMZ5"));

  print("Firebase initialized!");

  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  final tournamentRepository = TournamentRepository();

  runApp(App(
    authenticationRepository: authenticationRepository,
    tournamentRepository: tournamentRepository,
  ));
}
