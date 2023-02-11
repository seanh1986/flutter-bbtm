import 'dart:async';
import 'package:bbnaf/blocs/tournament/tournament_event.dart';
import 'package:bbnaf/blocs/tournament/tournament_state.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _repo;
  // StreamSubscription? _subscription;

  TournamentBloc({required TournamentRepository tRepo})
      : _repo = tRepo,
        super(NoTournamentState());

  @override
  Stream<TournamentState> mapEventToState(TournamentEvent event) async* {
    if (event is NoTournamentEvent) {
      yield* _mapToNoTournamentState(event);
    } else if (event is LoadTournamentEvent) {
      yield* _mapToLoadTournamentState(event);
    }
    // else if (event is UpdateTournamentEvent) {
    //   yield* _mapToUpdateTournamentState(event);
    // }
    else if (event is SelectTournamentEvent) {
      yield* _mapToNewTournamentState(event);
    }
    // else if (event is UpdateMatchReportEvent) {
    //   yield* _mapToUpdateMatchReportState(event);
    // } else if (event is DownloadFile) {
    //   yield* _mapToDownloadFile(event);
    // } else if (event is DownloadTournamentBackup) {
    //   yield* _mapToDownloadBackup(event);
    // }
  }

  Future<String> getFileUrl(String filename) {
    return _repo.getFileUrl(filename);
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
  // Stream<TournamentState> _mapToUpdateTournamentState(
  //     UpdateTournamentEvent event) async* {
  //   print("TournamentBloc: _mapToUpdateTournamentState");

  //   _repo
  //       .updateTournamentData(event.tournament)
  //       .then((value) => _handleUpdatedTournamentData(event.tournament.info));
  // }

  // Stream<TournamentState> _mapToUpdateMatchReportState(
  //     UpdateMatchReportEvent event) async* {
  //   print("TournamentBloc: _mapToUpdateMatchReportState");

  //   try {
  //     _repo
  //         .updateCoachMatchReport(event)
  //         .then((value) => _handleUpdatedTournamentData(event.tournament.info));
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  Stream<TournamentState> _mapToNewTournamentState(
      SelectTournamentEvent event) async* {
    yield NewTournamentState(event.tournament);
  }

  Future<bool> refreshTournamentData(String tournamentId) async {
    print("TournamentBloc: refreshTournamentData");

    try {
      Tournament? tournament = await _repo.getTournamentDataAsync(tournamentId);
      bool success = tournament != null;

      if (success) {
        add(SelectTournamentEvent(tournament));
      }

      return success;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateMatchEvent(UpdateMatchReportEvent event) async {
    print("TournamentBloc: updateMatchEvent");

    try {
      _repo.updateCoachMatchReport(event);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateTournament(Tournament tournament) async {
    print("TournamentBloc: updateTournament");

    try {
      return _repo.updateTournamentData(tournament);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> downloadTournamentBackup(DownloadTournamentBackup event) async {
    return _repo.downloadBackupFile(event.tournament);
  }

  Future<bool> downloadFile(DownloadFile event) async {
    return _repo.downloadFile(event.fileName);
  }

  @override
  Future<void> close() {
    print("TournamentBloc: close");
    return super.close();
  }

  // void _handleUpdatedTournamentData(TournamentInfo info) {
  //   print("TournamentBloc: _handleUpdatedTournamentData: " +
  //       info.name +
  //       " (" +
  //       info.id.toString() +
  //       ")");
  //   _loadTournament(info);
  // }

  void _loadTournament(TournamentInfo info) {
    print("TournamentBloc: _loadTournament: " +
        info.name +
        " (" +
        info.id.toString() +
        ")");

    _repo.getTournamentData(info.id).listen((t) => _processLoadedTournament(t));
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
