import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/login/login.dart';
import 'package:bbnaf/repos/auth/simple_auth_repo.dart';
import 'package:bbnaf/repos/tournament/firebase_tournament_repo.dart';
import 'package:bbnaf/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/tournament_list/tournament_list.dart';
import 'blocs/tournament_selection/tournament_selection.dart';
import 'repos/auth/auth_repo.dart';
import 'repos/tournament/tournament_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AuthRepository _authRepo = SimpleAuthRepository();
  TournamentRepository _tournamentRepo = FirebaseTournamentRepository();

  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(aRepo: _authRepo)..add(AppStartedAuthEvent())),
    BlocProvider<LoginBloc>(
        create: (context) =>
            LoginBloc(aRepo: _authRepo)..add(AppStartedLoginEvent())),
    BlocProvider<TournamentListsBloc>(
        create: (context) => TournamentListsBloc(tRepo: _tournamentRepo)
          ..add(RequestLoadTournamentListEvent())),
    BlocProvider<TournamentSelectionBloc>(
        create: (context) => TournamentSelectionBloc(tRepo: _tournamentRepo)
          ..add(DeselectedTournamentEvent())),
  ], child: App()));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    /// The future is part of the state of our widget. We should not call `initializeApp`
    /// directly inside [build].
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return LaunchFailed();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return LaunchSuccess();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return LaunchLoading();
      },
    );
  }

  Widget LaunchSuccess() {
    return MaterialApp(
      title: 'BloodBowl Tournament Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.redAccent,
          cardColor: Colors.lightBlueAccent,
        ),
        textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.black)),
      ),
      home: LoginPage(), // TournamentListPage(),
    ); // HomePage(),
  }

  Widget LaunchFailed() {
    return Container(
      // decoration: BoxDecoration(
      //     image: DecorationImage(
      //         image: AssetImage('background/background_football_field.jpg'),
      //         fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('logos/amorical_logo.png'),
            Text("Failed to load..."),
          ],
        ),
      ),
    );
  }

  Widget LaunchLoading() {
    return Container(
      // decoration: BoxDecoration(
      //     image: DecorationImage(
      //         image: AssetImage('background/background_football_field.jpg'),
      //         fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('logos/amorical_logo.png'),
            Text(
              "Loading...",
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
