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
        super(TournamentStateUninitialized()) {
    on<TournamentEventUninitialized>(
        (event, emit) => _mapToNoTournamentState(event));
    on<TournamentEventFetchData>(
        (event, emit) => _mapToLoadTournamentState(event));
    on<TournamentEventSelectedTourny>(
        (event, emit) => _mapToNewTournamentState(event));
    on<TournamentEventRefreshData>(
        (event, emit) => _mapToRefreshTournamentState(event));
  }

  // @override
  // Stream<TournamentState> mapEventToState(TournamentEvent event) async* {
  //   if (event is TournamentEventUninitialized) {
  //     yield* _mapToNoTournamentState(event);
  //   } else if (event is TournamentEventFetchData) {
  //     yield* _mapToLoadTournamentState(event);
  //   } else if (event is TournamentEventSelectedTourny) {
  //     yield* _mapToNewTournamentState(event);
  //   } else if (event is TournamentEventRefreshData) {
  //     yield* _mapToRefreshTournamentState(event);
  //   }
  // }

  Future<String> getFileUrl(String filename) {
    return _repo.getFileUrl(filename);
  }

  Stream<TournamentState> _mapToNoTournamentState(
      TournamentEventUninitialized event) async* {
    print("TournamentBloc: yield TournamentState Uninitialized");
    yield TournamentStateUninitialized();
  }

  // Tournament is now selected
  Stream<TournamentState> _mapToLoadTournamentState(
      TournamentEventFetchData event) async* {
    print("TournamentBloc: yield TournamentState Loading");
    yield TournamentStateLoading(event.tournamentId);

    _loadTournament(event.tournamentId);
  }

  Stream<TournamentState> _mapToNewTournamentState(
      TournamentEventSelectedTourny event) async* {
    print("TournamentBloc: yield TournamentState Loaded");
    yield TournamentStateLoaded(event.tournament);
  }

  Stream<TournamentState> _mapToRefreshTournamentState(
      TournamentEventRefreshData event) async* {
    print("TournamentBloc: yield TournamentState Refreshing");
    yield TournamentStateRefreshing(event.tournamentId);

    _loadTournament(event.tournamentId);
  }

  // ---------------
  // Update DB
  // ---------------

  Future<bool> updateMatchEvent(UpdateMatchReportEvent event) {
    print("TournamentBloc: updateMatchEvent");
    return _repo.updateCoachMatchReport(event);
    // .then((value) {
    //   if (value) {
    //     add(TournamentEventRefreshData(event.tournament.info.id));
    //   }
    //   return value;
    // });
  }

  Future<bool> updateMatchEvents(List<UpdateMatchReportEvent> events) {
    print("TournamentBloc: updateMatchEvents");
    return _repo.updateCoachMatchReports(events);
    // .then((value) {
    //   if (value && events.isNotEmpty) {
    //     add(TournamentEventRefreshData(events.first.tournament.info.id));
    //   }
    //   return value;
    // });
  }

  Future<bool> overwriteTournamentInfo(TournamentInfo info) {
    return _repo.overwriteTournamentInfo(info);
    // .then((value) async {
    //   if (value) {
    //     add(TournamentEventRefreshData(info.id));
    //   }
    //   return value;
    // });
  }

  Future<bool> overwriteCoaches(TournamentInfo info, List<Coach> newCoaches,
      List<RenameNafName> renames) {
    return _repo.overwriteCoaches(info.id, newCoaches, renames);
    //     .then((value) async {
    //   if (value) {
    //     add(TournamentEventRefreshData(info.id));
    //   }
    //   return value;
    // });
  }

  // Recovering backup
  Future<bool> recoverTournamentBackup(Tournament tournament) {
    return _repo.recoverTournamentBackup(tournament);
    // .then((value) async {
    //   if (value) {
    //     add(TournamentEventRefreshData(tournament.info.id));
    //   }
    //   return value;
    // });
  }

  Future<bool> advanceRound(Tournament tournament) {
    return _repo.advanceRound(tournament);
    // .then((value) async {
    //   if (value) {
    //     add(TournamentEventRefreshData(tournament.info.id));
    //   }
    //   return value;
    // });
  }

  Future<bool> discardCurrentRound(Tournament tournament) {
    return _repo.discardCurrentRound(tournament);
    // .then((value) async {
    //   if (value) {
    //     add(TournamentEventRefreshData(tournament.info.id));
    //   }
    //   return value;
    // });
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

  void _loadTournament(String tournamentId) {
    _repo
        .getTournamentData(tournamentId)
        .listen((t) => _processLoadedTournament(t));
  }

  void _processLoadedTournament(Tournament t) {
    print("TournamentBloc: _processLoadedTournament: " +
        t.info.name +
        " (" +
        t.info.id.toString() +
        ")");

    add(TournamentEventSelectedTourny(t));
  }
}
