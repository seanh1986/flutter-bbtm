import 'dart:async';
import 'package:bbnaf/blocs/tournament_selection/tournament_selection.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

class TournamentSelectionBloc
    extends Bloc<TournamentSelectionEvent, TournamentSelectionState> {
  final TournamentRepository _tournamentRepository;
  StreamSubscription? _tournamentSelectionSubscription;

  TournamentSelectionBloc({required TournamentRepository tRepo})
      : _tournamentRepository = tRepo,
        super(NoSelectedTournamentState());

  @override
  Stream<TournamentSelectionState> mapEventToState(
      TournamentSelectionEvent event) async* {
    if (event is LoadingTournamentEvent) {
      yield* _mapLoadingTournamentState(event);
    } else if (event is SelectedTournamentEvent) {
      yield* _mapSelectedTournamentState(event);
    } else if (event is DeselectedTournamentEvent) {
      yield* _mapDeselectedTournamentState();
    }
  }

  // Trigger load of tournament
  Stream<TournamentSelectionState> _mapLoadingTournamentState(
      LoadingTournamentEvent event) async* {
    print("TournamentSelectionBloc: _mapLoadingTournamentState");
    _tournamentSelectionSubscription?.cancel();
    _tournamentSelectionSubscription =
        _tournamentRepository.downloadTournament(event.tournamentInfo).listen(
              (t) => add(SelectedTournamentEvent(event.tournamentInfo, t)),
            );
  }

  // Tournament is now selected
  Stream<TournamentSelectionState> _mapSelectedTournamentState(
      SelectedTournamentEvent event) async* {
    print("TournamentSelectionBloc: _mapSelectedTournamentState");
    yield SelectedTournamentState(event.tournamentInfo, event.tournament);
  }

  // Tournament is now deselected
  Stream<TournamentSelectionState> _mapDeselectedTournamentState() async* {
    print("TournamentSelectionBloc: _mapDeselectedTournamentState");
    yield NoSelectedTournamentState();
  }

  @override
  Future<void> close() {
    print("TournamentSelectionBloc: close");
    _tournamentSelectionSubscription?.cancel();
    return super.close();
  }
}
