import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/screens/admin/edit_participants_widget.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(
      {required AuthenticationRepository authenticationRepository,
      required TournamentRepository tournamentRepository})
      : _authenticationRepository = authenticationRepository,
        _tournamentRepository = tournamentRepository,
        super(AppState(
            authenticationState:
                (authenticationRepository.currentUser.isNotEmpty
                    ? AuthenticationState.authenticated(
                        authenticationRepository.currentUser)
                    : const AuthenticationState.unauthenticated()),
            tournamentState: TournamentState.noTournamentList())) {
    // Authentication Related
    on<_AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user)),
    );
    // Tournament List Related
    on<AppRequestNavToTournamentList>(_requestNavToTournamentList);
    on<AppTournamentListLoaded>(_onTournamentListLoaded);
    _tournamentListSubscription = _tournamentRepository
        .getTournamentList()
        .listen(
            (tournamentList) => add(AppTournamentListLoaded(tournamentList)));
    on<AppCreateTournament>(_createTournament);
    // Tournament Related
    on<AppTournamentRequested>(_appTournamentRequested);
    // Update Related
    on<UpdateMatchEvent>(_updateMatchEvent);
    on<UpdateMatchEvents>(_updateMatchEvents);
    on<UpdateTournamentInfo>(_updateTournamentInfo);
    on<UpdateCoaches>(_updateCoaches);
    on<RecoverBackup>(_recoverBackup);
    // Round Management
    on<AdvanceRound>(_advanceRound);
    on<DiscardCurrentRound>(_discardCurrentRound);
    // Downloads
    on<DownloadBackup>(_downloadBackup);
    on<DownloadNafUploadFile>(_downloadNafUploadFile);
    on<DownloadGlamFile>(_downloadGlamFile);
    on<DownloadFile>(_downloadFile);
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  final TournamentRepository _tournamentRepository;
  late final StreamSubscription<List<TournamentInfo>>
      _tournamentListSubscription;
  // late final StreamSubscription<Tournament> _tournamentSubscription;

  // Do not maintain tournament state when user change occurs!
  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    if (event.user.isNotEmpty) {
      print("AppBloc: Autenticated user: " +
          event.user.getEmail() +
          " (" +
          event.user.getNafName() +
          ")");
    } else {
      print("AppBloc: Unauthenticated user");
    }

    emit(AppState(
        authenticationState: event.user.isNotEmpty
            ? AuthenticationState.authenticated(event.user)
            : const AuthenticationState.unauthenticated(),
        tournamentState: TournamentState.tournamentList(
            state.tournamentState.tournamentList)));
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  // Download tournament list & refresh
  void _requestNavToTournamentList(
      AppRequestNavToTournamentList event, Emitter<AppState> emit) {
    print("AppBloc: Request Navigation to Tournament List");

    List<TournamentInfo>? tournamentList =
        _tournamentRepository.getCurrentTournamentList();

    if (tournamentList != null) {
      add(AppTournamentListLoaded(tournamentList));
    }
  }

  // Refresh app due to tournament list refresh
  void _onTournamentListLoaded(
      AppTournamentListLoaded event, Emitter<AppState> emit) {
    print("AppBloc: TournamentList Loaded: Size: " +
        event.tournamentList.length.toString());

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.tournamentList(event.tournamentList)));
  }

  // Create new tournament
  void _createTournament(AppCreateTournament event, Emitter<AppState> emit) {
    print("AppBloc: CreateTournament");

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.createTournament()));
  }

  void _appTournamentRequested(
      AppTournamentRequested event, Emitter<AppState> emit) async {
    print("AppBloc: Request Tournament Download: " + event.tournamentId);

    Tournament tournament =
        await _tournamentRepository.requestTournament(event.tournamentId);

    if (tournament.isEmpty()) {
      return;
    }

    print("AppBloc: Tournament Loaded: " +
        tournament.info.name +
        " (" +
        tournament.info.id.toString() +
        ")");

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.selectTournament(
            state.tournamentState.tournamentList, tournament)));
  }

  @override
  Future<void> close() {
    // _tournamentSubscription.cancel();
    _tournamentListSubscription.cancel();
    _userSubscription.cancel();
    return super.close();
  }

  // ---------------
  // Update DB
  // ---------------

  void _updateMatchEvent(UpdateMatchEvent event, Emitter<AppState> emit) {
    print("AppBloc: updateMatchEvent");
    _tournamentRepository
        .updateCoachMatchReport(event.matchEvent)
        .then((value) {
      print("AppBloc: updateMatchEvent finished -> " + value.toString());
      if (value) {
        add(AppTournamentRequested(event.matchEvent.tournament.info.id));
      }
    });
  }

  void _updateMatchEvents(UpdateMatchEvents event, Emitter<AppState> emit) {
    print("AppBloc: updateMatchEvents");
    _tournamentRepository
        .updateCoachMatchReports(event.matchEvents)
        .then((value) {
      print("AppBloc: UpdateMatchEvents finished (size: " +
          event.matchEvents.length.toString() +
          ") -> " +
          value.toString());
      if (value && event.matchEvents.isNotEmpty) {
        add(AppTournamentRequested(event.matchEvents.first.tournament.info.id));
      }
      return value;
    });
  }

  void _updateTournamentInfo(
      UpdateTournamentInfo event, Emitter<AppState> emit) {
    BuildContext context = event.context;
    TournamentInfo info = event.tournamentInfo;
    LoadingIndicatorDialog().show(context);
    print("AppBloc: updateTournamentInfo: " + info.name + "(" + info.id + ")");
    _tournamentRepository.overwriteTournamentInfo(info).then((value) {
      print("AppBloc: updateTournamentInfo " +
          info.name +
          "(" +
          info.id +
          ") Finished -> " +
          value.toString());
      LoadingIndicatorDialog().dismiss();
      if (value) {
        add(AppTournamentRequested(info.id));
      }
      return value;
    });
  }

  void _updateCoaches(UpdateCoaches event, Emitter<AppState> emit) {
    TournamentInfo info = event.tournamentInfo;
    List<Coach> newCoaches = event.newCoaches;
    List<RenameNafName> renames = event.renames;
    print("AppBloc: UpdateCoaches: " +
        info.name +
        " -> NewCoaches: " +
        newCoaches.length.toString() +
        ")");
    _tournamentRepository
        .overwriteCoaches(info.id, newCoaches, renames)
        .then((value) {
      print("AppBloc: UpdateCoaches: Finished -> " + value.toString());
      if (value) {
        add(AppTournamentRequested(info.id));
      }
      return value;
    });
  }

  // Recovering backup
  void _recoverBackup(RecoverBackup event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: RecoverBackup: " + tournament.info.name);
    _tournamentRepository.recoverTournamentBackup(tournament).then((value) {
      print("AppBloc: RecoverBackup: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      if (value) {
        add(AppTournamentRequested(tournament.info.id));
      }
      return value;
    });
  }

  void _advanceRound(AdvanceRound event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: AdvanceRound: " + tournament.info.name);
    _tournamentRepository.advanceRound(tournament).then((value) {
      print("AppBloc: AdvanceRound: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      if (value) {
        add(AppTournamentRequested(tournament.info.id));
      }
      return value;
    });
  }

  void _discardCurrentRound(DiscardCurrentRound event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: DiscardCurrentRound: " + tournament.info.name);
    _tournamentRepository.discardCurrentRound(tournament).then((value) {
      print("AppBloc: DiscardCurrentRound: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      if (value) {
        add(AppTournamentRequested(tournament.info.id));
      }
      return value;
    });
  }

  // ---------------
  // Download Files
  // ---------------

  void _downloadBackup(DownloadBackup event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: DownloadBackup: " + tournament.info.name);
    _tournamentRepository.downloadBackupFile(event.tournament);
  }

  void _downloadNafUploadFile(
      DownloadNafUploadFile event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: DownloadNafUploadFile: " + tournament.info.name);
    _tournamentRepository.downloadNafUploadFile(tournament);
  }

  void _downloadGlamFile(DownloadGlamFile event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: DownloadGlamFile: " + tournament.info.name);
    _tournamentRepository.downloadGlamFile(tournament);
  }

  void _downloadFile(DownloadFile event, Emitter<AppState> emit) {
    print("AppBloc: _downloadFile: " + event.fileName);
    _tournamentRepository.downloadFile(event.fileName);
  }

  Future<String> getFileUrl(String filename) {
    return _tournamentRepository.getFileUrl(filename);
  }
}
