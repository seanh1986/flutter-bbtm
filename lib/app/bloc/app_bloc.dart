import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
    // on<AppTournamentListRequested>(_onTournamentListRequested);
    on<AppTournamentListLoaded>(_onTournamentListLoaded);
    _tournamentListSubscription = _tournamentRepository
        .getTournamentList()
        .listen(
            (tournamentList) => add(AppTournamentListLoaded(tournamentList)));
    // Tournament Related
    on<AppTournamentRequested>(_appTournamentRequested);
    // on<AppTournamentLoaded>(_AppTournamentLoaded);
    // _tournamentSubscription = _tournamentRepository.getTournamentData(tournamentId)
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  final TournamentRepository _tournamentRepository;
  late final StreamSubscription<List<TournamentInfo>>
      _tournamentListSubscription;
  // late final StreamSubscription<Tournament> _tournamentSubscription;

  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    emit(AppState(
        authenticationState: event.user.isNotEmpty
            ? AuthenticationState.authenticated(event.user)
            : const AuthenticationState.unauthenticated(),
        tournamentState: state.tournamentState));
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  // Download tournament list & refresh
  // void _onTournamentListRequested(
  //     AppTournamentListRequested event, Emitter<AppState> emit) async {
  //   Stream<List<TournamentInfo>> tournamentList =
  //       _tournamentRepository.getTournamentList();

  //   tournamentList.User user = _authenticationRepository.currentUser;
  //   List<TournamentInfo> tournamentList =
  //       _tournamentRepository.currentTournamentList;

  //   if (tournamentList.isNotEmpty) {
  //     AppTournamentListLoaded loadedEvent =
  //         AppTournamentListLoaded(user, tournamentList);
  //     add(loadedEvent);
  //   }
  // }

  // Refresh app due to tournament list refresh
  void _onTournamentListLoaded(
      AppTournamentListLoaded event, Emitter<AppState> emit) {
    emit(AppState(
        authenticationState: state.authenticationState,
        tournamentState: TournamentState.tournamentList(event.tournamentList)));
  }

  void _appTournamentRequested(
      AppTournamentRequested event, Emitter<AppState> emit) async {
    Tournament tournament =
        await _tournamentRepository.requestTournament(event.tournamentInfo.id);

    if (tournament.isEmpty()) {
      return;
    }

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
}
