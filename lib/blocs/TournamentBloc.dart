import 'dart:async';
import 'package:amorical_cup/blocs/Bloc.dart';
import 'package:amorical_cup/models/tournament.dart';

class TournamentBloc implements Bloc {
  Tournament? _tournament;
  Tournament? get selectedTournament => _tournament;

  final _tournamentController = StreamController<Tournament>();

  Stream<Tournament> get locationStream => _tournamentController.stream;

  void selectTournament(Tournament tournament) {
    _tournament = tournament;
    _tournamentController.sink.add(tournament);
  }

  @override
  void dispose() {
    _tournamentController.close();
  }
}
