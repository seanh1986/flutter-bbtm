import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/admin/admin.dart';
import 'package:bbnaf/home/home.dart';
import 'package:bbnaf/login/view/login_landing_page.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:bbnaf/utils/loading_indicator.dart';
import 'package:bbnaf/utils/swiss/round_matching.dart';
import 'package:bbnaf/utils/toast.dart';
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
            tournamentState: TournamentState.noTournamentList(),
            screenState: ScreenState(mainScreen: LoginLandingPage.tag))) {
    // Authentication Related
    on<_AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user)),
    );
    // App Navigation Related
    on<ScreenChange>(_onScreenChange);
    on<SearchScreenChange>(_onSearchScreen);
    on<AppRequestNavToTournamentList>(_onAppRequestNavToTournamentList);
    // Tournament List Related
    // on<AppRequestNavToTournamentList>(_requestNavToTournamentList);
    on<AppTournamentListLoaded>(_onTournamentListLoaded);
    on<AppCreateTournament>(_createTournament);
    // Tournament Related
    on<AppTournamentRequested>(_appTournamentRequested);
    on<AppTournamentLoaded>(_appTournamentLoaded);
    // Update Related
    on<UpdateMatchEvent>(_updateMatchEvent);
    on<UpdateMatchEvents>(_updateMatchEvents);
    on<UpdateSquadBonusPts>(_updateSquadBonusPts);
    on<UpdateTournamentInfo>(_updateTournamentInfo);
    on<LockOrUnlockTournament>(_lockOrUnlockTournament);
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

    // Subscriptions
    _tournamentListSubscription =
        _tournamentRepository.getTournamentList().listen((tournamentList) {
      if (_selectedTournamentId == null) {
        return add(AppTournamentListLoaded(tournamentList));
      } else {
        return add(AppTournamentRequested(_selectedTournamentId!));
      }
    });
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  final TournamentRepository _tournamentRepository;

  late final StreamSubscription<List<TournamentInfo>>
      _tournamentListSubscription;

  String? _selectedTournamentId;
  StreamSubscription<Tournament>? _tournamentSubscription;

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

    AuthenticationState authState = event.user.isNotEmpty
        ? AuthenticationState.authenticated(event.user)
        : const AuthenticationState.unauthenticated();
    TournamentState tournamentState =
        TournamentState.tournamentList(state.tournamentState.tournamentList);

    ScreenState screenState = state.screenState;
    if (screenState.mainScreen == LoginLandingPage.tag &&
        authState.status == AuthenticationStatus.authenticated) {
      screenState = ScreenState(mainScreen: TournamentSelectionPage.tag);
    } else if (authState.status == AuthenticationStatus.unauthenticated) {
      screenState = ScreenState(mainScreen: LoginLandingPage.tag);
    }

    emit(AppState(
        authenticationState: authState,
        tournamentState: tournamentState,
        screenState: screenState));
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  // Screen change
  void _onScreenChange(ScreenChange event, Emitter<AppState> emit) {
    print("AppBloc: ScreenChange: " +
        event.mainScreen +
        (event.screenDetailsJson.isNotEmpty
            ? " -> " + event.screenDetailsJson.toString()
            : ""));

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: state.tournamentState,
        screenState: ScreenState(
            mainScreen: event.mainScreen,
            screenDetailsJson: event.screenDetailsJson)));
  }

  // Search change
  void _onSearchScreen(SearchScreenChange event, Emitter<AppState> emit) {
    print("AppBloc: SearchScreenChange: " + event.search);

    ScreenState screenState = ScreenState(
        mainScreen: state.screenState.mainScreen,
        screenDetailsJson: state.screenState.screenDetailsJson,
        searchValue: event.search.toLowerCase()); // Ensure lower-case

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: state.tournamentState,
        screenState: screenState));
  }

  // Refresh app due to tournament list refresh
  void _onTournamentListLoaded(
      AppTournamentListLoaded event, Emitter<AppState> emit) {
    print("AppBloc: TournamentList Loaded: Size: " +
        event.tournamentList.length.toString());

    ScreenState screenState = state.screenState;
    if (screenState.mainScreen.isEmpty) {
      screenState = ScreenState(mainScreen: TournamentSelectionPage.tag);
    }

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.tournamentList(event.tournamentList),
        screenState: screenState));
  }

  // Create new tournament
  void _createTournament(AppCreateTournament event, Emitter<AppState> emit) {
    print("AppBloc: CreateTournament");

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.createTournament(),
        screenState: state.screenState));
  }

  void _onAppRequestNavToTournamentList(
      AppRequestNavToTournamentList event, Emitter<AppState> emit) {
    print("AppBloc: AppRequestNavToTournament");

    List<TournamentInfo>? tournamentList =
        _tournamentRepository.getCurrentTournamentList();
    if (tournamentList == null) {
      return;
    }

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.tournamentList(tournamentList),
        screenState: ScreenState(mainScreen: TournamentSelectionPage.tag)));
  }

  void _appTournamentRequested(
      AppTournamentRequested event, Emitter<AppState> emit) async {
    print("AppBloc: Request Tournament Download: " + event.tournamentId);

    // Setup tournament subscription
    _setupTournamentSubscription(event.tournamentId);
  }

  void _setupTournamentSubscription(String? tournamentId) {
    _tournamentSubscription?.cancel();

    if (tournamentId == null) {
      _selectedTournamentId = null;
      _tournamentSubscription = null;
    } else {
      _tournamentSubscription = _tournamentRepository
          .getTournamentData(tournamentId)
          .listen((tournament) {
        return add(AppTournamentLoaded(tournament));
      });
    }
  }

  void _appTournamentLoaded(AppTournamentLoaded event, Emitter<AppState> emit) {
    // Maintain same screen, unless:
    // 1. Tournament Selectin Screen
    // 2. Login Screen
    ScreenState screenState = state.screenState;
    if (screenState.mainScreen == TournamentSelectionPage.tag ||
        screenState.mainScreen == LoginLandingPage.tag) {
      screenState = ScreenState(mainScreen: HomePage.tag);
    }

    // If round change --> Reset to Home Screen
    if (state.screenState.mainScreen == HomePage.tag &&
        state.tournamentState.status == TournamentStatus.selected_tournament &&
        state.tournamentState.tournament.curRoundIdx() !=
            event.tournament.curRoundIdx()) {
      screenState = ScreenState(mainScreen: HomePage.tag);
    }

    // Update current selected tournament Id
    _selectedTournamentId = event.tournament.info.id;

    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.selectTournament(
            state.tournamentState.tournamentList, event.tournament),
        screenState: screenState));
  }

  @override
  Future<void> close() {
    _tournamentSubscription?.cancel();
    _tournamentListSubscription.cancel();
    _userSubscription.cancel();
    return super.close();
  }

  // ---------------
  // Update DB
  // ---------------

  void _updateMatchEvent(UpdateMatchEvent event, Emitter<AppState> emit) {
    print("AppBloc: updateMatchEvent");
    ToastUtils.show(event.context, "Uploading Match Report!");
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository
        .updateCoachMatchReport(event.matchEvent)
        .then((value) {
      print("AppBloc: updateMatchEvent finished -> " + value.toString());
      LoadingIndicatorDialog().dismiss();
      _showSuccessFailToast(event.context, value);
      // Refresh tournament UI
      if (value) {
        add(AppTournamentRequested(event.matchEvent.tournament.info.id));
      }
    });
  }

  void _updateMatchEvents(UpdateMatchEvents event, Emitter<AppState> emit) {
    print("AppBloc: updateMatchEvents");

    if (event.newRoundMatchups != null) {
      print("AppBloc: updateMatchEvents -> swap matches");
      _tournamentRepository
          .swapCoachMatchups(event.tournamentId, event.newRoundMatchups!)
          .then((value) {
        _processUpdateMatches(
            event.context, event.tournamentId, event.matchEvents);
      });
    } else {
      _processUpdateMatches(
          event.context, event.tournamentId, event.matchEvents);
    }
  }

  void _processUpdateMatches(BuildContext context, String tournamentId,
      List<UpdateMatchReportEvent> matchEvents) {
    if (matchEvents.isEmpty) {
      return;
    }

    print("AppBloc: updateMatchEvents -> update matches");
    LoadingIndicatorDialog().show(context);

    _tournamentRepository.updateCoachMatchReports(matchEvents).then((value) {
      print("AppBloc: UpdateMatchEvents finished (size: " +
          matchEvents.length.toString() +
          ") -> " +
          value.toString());
      LoadingIndicatorDialog().dismiss();

      _showSuccessFailToast(context, value);

      if (value && matchEvents.isNotEmpty) {
        add(AppTournamentRequested(tournamentId));
      }
      return value;
    });
  }

  void _updateSquadBonusPts(UpdateSquadBonusPts event, Emitter<AppState> emit) {
    print("AppBloc: UpdateSquadBonusPts");
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository.updateSquadBonusPts(event).then((value) {
      print("AppBloc: UpdateSquadBonusPts finished");
      LoadingIndicatorDialog().dismiss();
      _showSuccessFailToast(event.context, value);
      if (value) {
        add(AppTournamentRequested(event.tournament.info.id));
      }
      return value;
    });
  }

  void _updateTournamentInfo(
      UpdateTournamentInfo event, Emitter<AppState> emit) {
    BuildContext context = event.context;
    TournamentInfo info = event.tournamentInfo;
    print("AppBloc: updateTournamentInfo: " + info.name + "(" + info.id + ")");
    _processUpdateTournamentInfo(context, info, false);
  }

  void _lockOrUnlockTournament(
      LockOrUnlockTournament event, Emitter<AppState> emit) {
    BuildContext context = event.context;
    TournamentInfo info = event.tournamentInfo;
    info.locked = event.lock; // Make sure lock states align

    print("AppBloc: _lockOrUnlockTournament: " +
        info.name +
        "(" +
        info.id +
        ") -> Lock: " +
        event.lock.toString());
    _processUpdateTournamentInfo(context, info, true);
  }

  void _processUpdateTournamentInfo(
      BuildContext context, TournamentInfo info, bool allowOverwriteLock) {
    print("AppBloc: _processUpdateTournamentInfo: " +
        info.name +
        "(" +
        info.id +
        ") -> AllowOverwriteLock: " +
        allowOverwriteLock.toString());

    LoadingIndicatorDialog().show(context);

    _tournamentRepository
        .overwriteTournamentInfo(info, allowOverwriteLock)
        .then((value) {
      print("AppBloc: _processUpdateTournamentInfo " +
          info.name +
          "(" +
          info.id +
          ") Finished -> " +
          value.toString());
      LoadingIndicatorDialog().dismiss();
      _showSuccessFailToast(context, value);
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
        newCoaches.length.toString());
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository
        .overwriteCoaches(info.id, newCoaches, renames)
        .then((value) {
      print("AppBloc: UpdateCoaches: Finished -> " + value.toString());
      LoadingIndicatorDialog().dismiss();
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
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository.recoverTournamentBackup(tournament).then((value) {
      print("AppBloc: RecoverBackup: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      LoadingIndicatorDialog().dismiss();
      if (value) {
        add(AppTournamentRequested(tournament.info.id));
      }
      return value;
    });
  }

  void _advanceRound(AdvanceRound event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: AdvanceRound: " + tournament.info.name);
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository.advanceRound(tournament).then((value) {
      print("AppBloc: AdvanceRound: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      LoadingIndicatorDialog().dismiss();
      if (value) {
        add(AppTournamentRequested(tournament.info.id));
      }
      return value;
    });
  }

  void _discardCurrentRound(DiscardCurrentRound event, Emitter<AppState> emit) {
    Tournament tournament = event.tournament;
    print("AppBloc: DiscardCurrentRound: " + tournament.info.name);
    LoadingIndicatorDialog().show(event.context);
    _tournamentRepository.discardCurrentRound(tournament).then((value) {
      print("AppBloc: DiscardCurrentRound: " +
          tournament.info.name +
          " Finished ->" +
          value.toString());
      LoadingIndicatorDialog().dismiss();
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

  // ---------------
  // Utility Methods
  // ---------------

  void _showSuccessFailToast(BuildContext context, bool success) {
    if (success) {
      ToastUtils.show(context, "Update successful.");
    } else {
      ToastUtils.show(context, "Update failed.");
    }
  }
}
