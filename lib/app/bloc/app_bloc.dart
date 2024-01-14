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
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    // Authentication Related
    on<_AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user)),
    );
    // Tournament List Related
    on<AppTournamentListRequested>(_onTournamentListRequested);
    on<AppTournamentListLoaded>(_onTournamentListLoaded);
    _tournamentListSubscription = _tournamentRepository.tournamentList.listen(
        (tournamentList) => add(AppTournamentListLoaded(
            _authenticationRepository.currentUser, tournamentList)));
    // Tournament Related
    // on<AppTournamentRequested>(_AppTournamentRequested);
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
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  // Download tournament list & refresh
  void _onTournamentListRequested(
      AppTournamentListRequested event, Emitter<AppState> emit) {
    unawaited(_tournamentRepository.requestTournamentList());
  }

  // Refresh app due to tournament list refresh
  void _onTournamentListLoaded(
      AppTournamentListLoaded event, Emitter<AppState> emit) {
    emit(
      event.user.isNotEmpty
          ? AppState.tournamentList(event.user, event.tournamentList)
          : const AppState.unauthenticated(),
    );
  }

  @override
  Future<void> close() {
    // _tournamentSubscription.cancel();
    _tournamentListSubscription.cancel();
    _userSubscription.cancel();
    return super.close();
  }
}
