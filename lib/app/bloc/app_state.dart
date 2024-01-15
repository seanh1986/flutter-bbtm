part of 'app_bloc.dart';

enum TournamentStatus {
  selected_tournament,
  create_tournament,
  tournament_list,
  no_tournament_list,
}

enum AuthenticationStatus {
  authenticated,
  unauthenticated,
}

final class AuthenticationState extends Equatable {
  const AuthenticationState._({required this.status, this.user = User.empty});

  const AuthenticationState.authenticated(User user)
      : this._(
          status: AuthenticationStatus.authenticated,
          user: user,
        );

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final User user;

  @override
  List<Object> get props => [
        status,
        user,
      ];
}

final class TournamentState extends Equatable {
  const TournamentState._(
      {required this.status,
      List<TournamentInfo>? tournamentList,
      String? tournamentId})
      : tournamentList = tournamentList ?? const [],
        tournamentId = tournamentId ?? "";

  const TournamentState.noTournamentList()
      : this._(status: TournamentStatus.no_tournament_list);

  const TournamentState.tournamentList(List<TournamentInfo> tournamentList)
      : this._(
            status: TournamentStatus.tournament_list,
            tournamentList: tournamentList);

  const TournamentState.createTournament(List<TournamentInfo> tournamentList)
      : this._(
            status: TournamentStatus.create_tournament,
            tournamentList: tournamentList);

  const TournamentState.selectTournament(
      List<TournamentInfo> tournamentList, String tournamentId)
      : this._(
            status: TournamentStatus.selected_tournament,
            tournamentList: tournamentList,
            tournamentId: tournamentId);

  final TournamentStatus status;
  final List<TournamentInfo> tournamentList;
  final String tournamentId;

  @override
  List<Object> get props => [status, tournamentList, tournamentId];
}

final class AppState extends Equatable {
  const AppState(
      {required this.authenticationState, required this.tournamentState});

  final AuthenticationState authenticationState;
  final TournamentState tournamentState;

  @override
  List<Object> get props => [authenticationState, tournamentState];
}
