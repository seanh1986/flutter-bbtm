import 'package:amorical_cup/screens/splash_screen.dart';
import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAF Tournament App',
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
}
