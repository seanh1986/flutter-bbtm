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

// Request Navigation to a new page
final class ScreenChange extends AppEvent {
  const ScreenChange(this.mainScreen, {this.screenDetailsJson = const {}});

  final String mainScreen;
  final Map<String, dynamic> screenDetailsJson;
}

final class SearchScreenChange extends AppEvent {
  const SearchScreenChange(this.search);

  final String search;
}

// // Request navigation to tournament selection page
// final class AppRequestNavToTournamentList extends AppEvent {
//   const AppRequestNavToTournamentList();
// }

// Tournament list is loaded / Navigate to tournament selection page
final class AppTournamentListLoaded extends AppEvent {
  const AppTournamentListLoaded(this.tournamentList);

  final List<TournamentInfo> tournamentList;
}

// Trigger creation of new tournament
final class AppCreateTournament extends AppEvent {
  const AppCreateTournament();
}

// Tournament refresh is requested
final class AppTournamentRequested extends AppEvent {
  const AppTournamentRequested(this.tournamentId);

  final String tournamentId;
}

// Tournament loaded
final class AppTournamentLoaded extends AppEvent {
  const AppTournamentLoaded(this.tournament);

  final Tournament tournament;
}

// Update Match
final class UpdateMatchEvent extends AppEvent {
  const UpdateMatchEvent(this.matchEvent);

  final UpdateMatchReportEvent matchEvent;
}

// Update Multiple Match Events
final class UpdateMatchEvents extends AppEvent {
  const UpdateMatchEvents(
      {required this.tournamentId,
      this.newRoundMatchups,
      this.matchEvents = const []});

  final String tournamentId;
  final CoachRound? newRoundMatchups;
  final List<UpdateMatchReportEvent> matchEvents;
}

// Update Tournament Info
final class UpdateTournamentInfo extends AppEvent {
  const UpdateTournamentInfo(this.context, this.tournamentInfo);

  final TournamentInfo tournamentInfo;
  final BuildContext context;
}

// Update Coaches
final class UpdateCoaches extends AppEvent {
  const UpdateCoaches(this.tournamentInfo, this.newCoaches, this.renames);

  final TournamentInfo tournamentInfo;
  final List<Coach> newCoaches;
  final List<RenameNafName> renames;
}

// Recover backup by overwriting the current tournament with the supplied
final class RecoverBackup extends AppEvent {
  const RecoverBackup(this.tournament);

  final Tournament tournament;
}

// Advance to next round
final class AdvanceRound extends AppEvent {
  const AdvanceRound(this.tournament);

  final Tournament tournament;
}

// Discard the current round
final class DiscardCurrentRound extends AppEvent {
  const DiscardCurrentRound(this.tournament);

  final Tournament tournament;
}

// Download backup file for the tournament
final class DownloadBackup extends AppEvent {
  const DownloadBackup(this.tournament);

  final Tournament tournament;
}

// Download the NAF upload file
final class DownloadNafUploadFile extends AppEvent {
  const DownloadNafUploadFile(this.tournament);

  final Tournament tournament;
}

// Download the GLAM file
final class DownloadGlamFile extends AppEvent {
  const DownloadGlamFile(this.tournament);

  final Tournament tournament;
}

// Download file from firebase storage
final class DownloadFile extends AppEvent {
  const DownloadFile(this.fileName);

  final String fileName;
}
