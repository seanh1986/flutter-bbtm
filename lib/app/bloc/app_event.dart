part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

// Request user logout
final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

// Logged in user changed
final class _AppUserChanged extends AppEvent {
  const _AppUserChanged(this.user);

  final User user;
}

// Request tournament list refresh
final class AppTournamentListRequested extends AppEvent {
  const AppTournamentListRequested(this.user);

  final User user;
}

// Tournament list is loaded
final class AppTournamentListLoaded extends AppEvent {
  const AppTournamentListLoaded(this.user, this.tournamentList);

  final User user;
  final List<TournamentInfo> tournamentList;
}

// Tournament refresh is requested
final class AppTournamentRequested extends AppEvent {
  const AppTournamentRequested(this.user, this.tournamentInfo);

  final User user;
  final TournamentInfo tournamentInfo;
}

// Tournament loaded
final class AppTournamentLoaded extends AppEvent {
  const AppTournamentLoaded(this.user, this.tournament);

  final User user;
  final Tournament tournament;
}
