import 'dart:async';
import 'package:amorical_cup/models/tournament.dart';
import 'package:http/http.dart' show Client;
import 'dart:convert';

class TournamentListApi {
  Client client = Client();

  Future<List<Tournament>> fetchTournamentList() async {
    print("fetchTournamentList");

    return Future.delayed(
      const Duration(seconds: 3),
      () {
        List<Tournament> tournamentList = [];

        tournamentList.add(Tournament.getExampleTournament(
            "Amorical Cup", "Ottawa, Ontario, Canada", "2022-06-22"));

        tournamentList.add(Tournament.getExampleTournament(
            "Underworld Cup", "Franklin, Michigan, USA", "2022-11-09"));

        tournamentList.add(Tournament.getExampleTournament(
            "Canadian Open", "Toronto, Ontario, Canada", "2023-02-04"));

        tournamentList.add(Tournament.getExampleTournament(
            "Brewhouse Bowl", "Waterloo, Ontario, Canada", "2023-05-25"));

        return tournamentList;
      },
    );

    // final response = await client
    //     .get("http://api.themoviedb.org/3/movie/popular?api_key=$_apiKey");

    // print(response.body.toString());

    // if (response.statusCode == 200) {
    //   // If the call to the server was successful, parse the JSON
    //   return ItemModel.fromJson(json.decode(response.body));
    // } else {
    //   // If that call was not successful, throw an error.
    //   throw Exception('Failed to load post');
    // }
  }
}
