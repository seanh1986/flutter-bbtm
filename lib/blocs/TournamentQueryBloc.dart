import 'dart:async';

import 'package:bbnaf/blocs/Bloc.dart';
import 'package:bbnaf/models/tournament/tournament.dart';

class TournamentQueryBloc implements Bloc {
  final _controller = StreamController<List<Tournament>>();
  // final _client = ZomatoClient();
  Stream<List<Tournament>> get tournamentStream => _controller.stream;

  void submitQuery(String query) async {
    // final results = await _client.fetchLocations(query);
    // _controller.sink.add(results);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
