import 'dart:async';
import 'package:bbnaf/blocs/tournament_update/tournament_update.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

class TournamentUpdateBloc
    extends Bloc<TournamentUpdateEvent, TournamentUpdateState> {
  final TournamentRepository _repo;
  StreamSubscription? _tournamentSubscription;

  TournamentUpdateBloc({required TournamentRepository tRepo})
      : _repo = tRepo,
        super(NoTournamentState());

  @override
  Stream<TournamentUpdateState> mapEventToState(
      TournamentUpdateEvent event) async* {
    if (event is NewRoundEvent) {
      yield* _mapNewRoundEventToState(event);
    } else if (event is UpdateTournamentInfoEvent) {
      yield* _mapUpdateTournamentInfoEventToState(event);
    } else if (event is UpdateTournamentParticipantEvent) {
      yield* _mapUpdateTournamentParticipantEventToState();
    }
  }

  // Update new round available
  Stream<TournamentUpdateState> _mapNewRoundEventToState(
      NewRoundEvent event) async* {
    print("TournamentUpdateBloc: _mapNewRoundEventState");
  }

  // Update tournament info
  Stream<TournamentUpdateState> _mapUpdateTournamentInfoEventToState(
      UpdateTournamentInfoEvent event) async* {
    print("TournamentUpdateBloc: _mapUpdateTournamentInfoEventToState");
    // yield SelectedTournamentState(event.tournamentInfo, event.tournament);
  }

  // Tournament is now deselected
  Stream<TournamentUpdateState>
      _mapUpdateTournamentParticipantEventToState() async* {
    print("TournamentUpdateBloc: _mapUpdateTournamentParticipantEventToState");
    // yield NoSelectedTournamentState();
  }

  @override
  Future<void> close() {
    print("TournamentUpdateBloc: close");
    _tournamentSubscription?.cancel();
    return super.close();
  }
}
