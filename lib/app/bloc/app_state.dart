part of 'app_bloc.dart';

enum AppStatus {
  selected_tournament,
  create_tournament,
  tournament_list,
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  const AppState._(
      {required this.status,
      this.user = User.empty,
      List<TournamentInfo>? tournamentList,
      this.tournament})
      : tournamentList = tournamentList ?? const [];

  const AppState.authenticated(User user)
      : this._(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  const AppState.tournamentList(User user, List<TournamentInfo> tournamentList)
      : this._(
            status: AppStatus.tournament_list,
            user: user,
            tournamentList: tournamentList);

  const AppState.createTournament(User user)
      : this._(status: AppStatus.create_tournament, user: user);

  const AppState.selectedTournament(User user, Tournament tournament)
      : this._(
            status: AppStatus.create_tournament,
            user: user,
            tournament: tournament);

  final AppStatus status;
  final User user;
  final List<TournamentInfo> tournamentList;
  final Tournament? tournament;

  @override
  List<Object> get props => [status, user];
}
