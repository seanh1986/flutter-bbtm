import 'dart:async';
import 'package:bbnaf/blocs/tournament/tournament_event.dart';
import 'package:bbnaf/blocs/tournament/tournament_state.dart';
import 'package:bbnaf/models/coach.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bbnaf/screens/admin/edit_participants_widget.dart';
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
    } else if (event is SelectTournamentEvent) {
      yield* _mapToNewTournamentState(event);
    }
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

  Stream<TournamentState> _mapToNewTournamentState(
      SelectTournamentEvent event) async* {
    yield NewTournamentState(event.tournament);
  }

  Future<Tournament?> getRefreshedTournamentData(String tournamentId) async {
    print("TournamentBloc: getRefreshedTournamentData");

    try {
      Tournament? tournament = await _repo.getTournamentDataAsync(tournamentId);

      return tournament;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ---------------
  // Update DB
  // ---------------

  Future<bool> updateMatchEvent(UpdateMatchReportEvent event) async {
    print("TournamentBloc: updateMatchEvent");
    return _repo.updateCoachMatchReport(event);
  }

  Future<bool> updateMatchEvents(List<UpdateMatchReportEvent> events) async {
    print("TournamentBloc: updateMatchEvents");
    return _repo.updateCoachMatchReports(events);
  }

  Future<bool> overwriteTournamentInfo(TournamentInfo info) {
    return _repo.overwriteTournamentInfo(info);
  }

  Future<bool> overwriteCoaches(
      String tId, List<Coach> newCoaches, List<RenameNafName> renames) {
    return _repo.overwriteCoaches(tId, newCoaches, renames);
  }

  // Recovering backup
  Future<bool> recoverTournamentBackup(Tournament tournament) {
    return _repo.recoverTournamentBackup(tournament);
  }

  Future<bool> advanceRound(Tournament tournament) {
    return _repo.advanceRound(tournament);
  }

  Future<bool> discardCurrentRound(Tournament tournament) {
    return _repo.discardCurrentRound(tournament);
  }

  // ---------------
  // Download Files
  // ---------------

  Future<bool> downloadTournamentBackup(DownloadTournamentBackup event) async {
    return _repo.downloadBackupFile(event.tournament);
  }

  Future<bool> downloadNafUploadFile(Tournament tournament) async {
    return _repo.downloadNafUploadFile(tournament);
  }

  Future<bool> downloadGlamFile(Tournament tournament) async {
    return _repo.downloadGlamFile(tournament);
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
