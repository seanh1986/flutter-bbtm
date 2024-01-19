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

// ignore: must_be_immutable
class TournamentState extends Equatable {
  TournamentState._(
      {required this.status,
      List<TournamentInfo>? tournamentList,
      Tournament? tournament})
      : tournamentList = tournamentList ?? const [],
        tournament = tournament ?? Tournament.empty();

  TournamentState.noTournamentList()
      : this._(status: TournamentStatus.no_tournament_list);

  TournamentState.tournamentList(List<TournamentInfo> tournamentList)
      : this._(
            status: TournamentStatus.tournament_list,
            tournamentList: tournamentList);

  TournamentState.createTournament()
      : this._(status: TournamentStatus.create_tournament);

  TournamentState.selectTournament(
      List<TournamentInfo> tournamentList, Tournament tournament)
      : this._(
            status: TournamentStatus.selected_tournament,
            tournamentList: tournamentList,
            tournament: tournament);

  final TournamentStatus status;
  final List<TournamentInfo> tournamentList;
  Tournament tournament;

  @override
  List<Object> get props => [status, tournamentList, tournament];
}

final class AppState extends Equatable {
  const AppState(
      {required this.authenticationState, required this.tournamentState});

  final AuthenticationState authenticationState;
  final TournamentState tournamentState;

  @override
  List<Object> get props => [authenticationState, tournamentState];
}
