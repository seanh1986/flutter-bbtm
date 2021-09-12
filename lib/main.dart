import 'package:bbnaf/screens/splash_screen.dart';
import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
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
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
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
      home: SplashScreen(), // HomePage(),
    );
  }

  Widget LaunchFailed() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('background/background_football_field.jpg'),
              fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('logos/amorical_logo.png'),
            Text("Failed to load..."),
          ],
        ),
      ),
    );
  }

  Widget LaunchLoading() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('background/background_football_field.jpg'),
              fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('logos/amorical_logo.png'),
            Text("Loading..."),
          ],
        ),
      ),
    );
  }
}
