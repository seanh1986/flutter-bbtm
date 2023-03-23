import 'package:bbnaf/blocs/auth/auth.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/repos/auth/firebase_auth_repo.dart';
import 'package:bbnaf/repos/tournament/firebase_tournament_repo.dart';
import 'package:bbnaf/screens/tournament_list/tournament_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/tournament_list/tournament_list.dart';
import 'repos/auth/auth_repo.dart';
import 'repos/tournament/tournament_repo.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Ensure we only handle initial uri once
bool _initialUriIsHandled = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB-TUGMpvec35ON6FPU7U0OIwZtZ4bnERE",
          authDomain: "bbtournaments-eaa1e.firebaseapp.com",
          projectId: "bbtournaments-eaa1e",
          storageBucket: "bbtournaments-eaa1e.appspot.com",
          messagingSenderId: "432579212807",
          appId: "1:432579212807:web:f1b596fdecf5ea67dddca2",
          measurementId: "G-S8H1Y9BMZ5"));

  AuthRepository _authRepo = FirebaseAuthRepository();
  TournamentRepository _tournamentRepo = FirebaseTournamentRepository();

  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(aRepo: _authRepo)..add(AppStartedAuthEvent())),
    BlocProvider<TournamentListsBloc>(
        create: (context) => TournamentListsBloc(tRepo: _tournamentRepo)
          ..add(RequestLoadTournamentListEvent())),
    BlocProvider<TournamentBloc>(
        create: (context) => TournamentBloc(tRepo: _tournamentRepo)
          ..add(TournamentEventUninitialized())),
  ], child: App()));

  // _tournamentRepo.updateTournamentData(Tournament.fromIceBowl());
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
  Uri? _initialUri;

  @override
  void initState() {
    super.initState();

    _setupFirebaseMessaging();

    _handleInitialUri();
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (_) {
        if (!mounted) return;
        print('malformed initial uri');
        // setState(() => _err = err);
      }
    }
  }

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
          return _launchFailed();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return _launchSuccess();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return _launchLoading();
      },
    );
  }

  Widget _launchSuccess() {
    String? tId = _initialUri?.queryParameters['tid'];

    // Hardcode for testing (Canadian Open)
    // tId = "X0qh35qbzPhBQKBb6y6c";

    return MaterialApp(
        title: 'BloodBowl Tournament Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.redAccent,
            cardColor: Colors.lightBlueAccent,
          ),
          textTheme:
              const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        ),
        home: TournamentSelectionPage(
          tournamentId: tId,
        ),
        initialRoute: "/",
        builder: (context, child) => ResponsiveWrapper.builder(
              child,
              maxWidth: 1200,
              minWidth: 480,
              defaultScale: true,
              breakpoints: [
                ResponsiveBreakpoint.resize(480, name: MOBILE),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(2460, name: '4K'),
              ],
              background: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                image: AssetImage(
                    './assets/images/background/background_football_field.png'),
                fit: BoxFit.cover,
              ))),
            ));
  }

  Widget _launchFailed() {
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

  Widget _launchLoading() {
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

  void _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
      saveTokens(fcmToken);
    }).onError((err) {
      // Error getting token.
    });

    final fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BI23EBqN0hNqqa_fnFRokHQFqeA3uN9J32vNKnNQQtRtALIOcObQ0Pia_C0gNuaox-2u2qCddTZOTmTraaWubz8");

    saveTokens(fcmToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // FirebaseMessaging.onBackgroundMessage(
    //     (BackgroundMessageHandler message) {});
  }

  Future<void> saveTokens(var token) async {
    try {
      await FirebaseFirestore.instance.collection('tokens').add({
        'token': token,
      });
    } catch (e) {
      print(e);
    }
  }
}
