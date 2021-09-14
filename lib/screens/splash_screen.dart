import 'package:bbnaf/screens/tournament_list_screen.dart';
import 'package:bbnaf/repos/TournamentRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // handleSplashscreen();
  }

  // void handleSplashscreen() async {
  //   // Wait for async to complete
  //   TournamentRepository.instance.refreshTournamentList(false);

  //   // Open Main page (wait for current build/render cycle to complete to avoid lock)
  //   SchedulerBinding.instance!.addPostFrameCallback((_) {
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (context) => TournamentListPage()));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('background/background_football_field.jpg'),
              fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(),
            ),
            //Image.asset('logos/amorical_logo.png'),
            // Text("Loading..."),
          ],
        ),
      ),
    );
  }
}
