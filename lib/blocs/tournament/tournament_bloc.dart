import 'dart:async';
import 'package:bbnaf/blocs/tournament/tournament_event.dart';
import 'package:bbnaf/blocs/tournament/tournament_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _repo;
  StreamSubscription? _subscription;

  TournamentBloc({required TournamentRepository tRepo})
      : _repo = tRepo,
        super(NoTournamentState());

  @override
  Stream<TournamentState> mapEventToState(TournamentEvent event) async* {
    if (event is NoTournamentEvent) {
      yield* _mapToNoTournamentState(event);
    } else if (event is LoadTournamentEvent) {
      yield* _mapToLoadTournamentState(event);
    } else if (event is UpdateTournamentEvent) {
      yield* _mapToUpdateTournamentState(event);
    } else if (event is SelectTournamentEvent) {
      yield* _mapToNewTournamentState(event);
    }

    // yield NoTournamentState();
  }

  Stream<TournamentState> _mapToNoTournamentState(
      NoTournamentEvent event) async* {
    yield NoTournamentState();
  }

  // Tournament is now selected
  Stream<TournamentState> _mapToLoadTournamentState(
      LoadTournamentEvent event) async* {
    print("TournamentBloc: _mapToLoadTournamentState");

    _loadTournament(event.info);
  }

  // Trigger load of tournament
  Stream<TournamentState> _mapToUpdateTournamentState(
      UpdateTournamentEvent event) async* {
    print("TournamentBloc: _mapToUpdateTournamentState");

    _repo
        .updateTournamentData(event.tournament)
        .then((value) => _handleUpdatedTournamentData(event.tournament.info));
  }

  Stream<TournamentState> _mapToNewTournamentState(
      SelectTournamentEvent event) async* {
    yield NewTournamentState(event.tournament);
  }

  @override
  Future<void> close() {
    print("TournamentBloc: close");
    _subscription?.cancel();
    return super.close();
  }

  void _handleUpdatedTournamentData(TournamentInfo info) {
    print("TournamentBloc: _handleUpdatedTournamentData: " +
        info.name +
        " (" +
        info.id.toString() +
        ")");
    _loadTournament(info);
  }

  void _loadTournament(TournamentInfo info) {
    print("TournamentBloc: _loadTournament: " +
        info.name +
        " (" +
        info.id.toString() +
        ")");

    _subscription?.cancel();

    _subscription = _repo
        .getTournamentData(info.id)
        .listen((t) => _processLoadedTournament(t));
  }

  void _processLoadedTournament(Tournament t) {
    print("TournamentBloc: _processLoadedTournament: " +
        t.info.name +
        " (" +
        t.info.id.toString() +
        ")");

    add(SelectTournamentEvent(t));
  }
}
