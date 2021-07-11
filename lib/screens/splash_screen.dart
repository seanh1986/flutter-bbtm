import 'package:amorical_cup/data/tournament.dart';
import 'package:amorical_cup/screens/tournament_list_screen.dart';
import 'package:amorical_cup/services/TournamentRepository.dart';
import 'package:flutter/material.dart';
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
    handleSplashscreen();
  }

  void handleSplashscreen() async {
    // Wait for async to complete
    TournamentRepository.instance.refreshTournamentList(false);

    // Open Main page (avoid lock)
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => TournamentListPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  "../../assets/images/background_football_field.jpg"),
              fit: BoxFit.cover)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("../../assets/images/amorical_logo.png"),
            Text("Loading..."),
          ],
        ),
      ),
    );
  }
}
