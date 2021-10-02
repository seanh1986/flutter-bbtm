import 'dart:async';
import 'package:bbnaf/blocs/tournament_selection/tournament_selection.dart';
import 'package:bbnaf/models/tournament_info.dart';
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
    if (event is SelectedTournamentEvent) {
      yield* _mapSelectedTournamentState(event.tournamentInfo);
    } else if (event is DeselectedTournamentEvent) {
      yield* _mapDeselectedTournamentState();
    }
  }

  // Trigger load
  Stream<TournamentSelectionState> _mapSelectedTournamentState(
      TournamentInfo tournamentInfo) async* {
    print("TournamentSelectionBloc: _mapSelectedTournamentState");
    _tournamentSelectionSubscription?.cancel();
    // _tournamentSubscription = _tournamentRepository.getTournamentInfos().listen(
    //       (t) => add(TournamentListUpdated(t)),
    //     );
  }

  // State is updated
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
