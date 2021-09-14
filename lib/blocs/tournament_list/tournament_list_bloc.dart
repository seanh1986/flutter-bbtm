import 'dart:async';
import 'package:bbnaf/blocs/tournament_list/tournament_list.dart';
import 'package:bbnaf/repos/tournament/tournament_repo.dart';
import 'package:bloc/bloc.dart';

class TournamentListsBloc
    extends Bloc<TournamentListEvent, TournamentListState> {
  final TournamentRepository _tournamentRepository;
  StreamSubscription? _tournamentSubscription;

  TournamentListsBloc({required TournamentRepository tRepo})
      : _tournamentRepository = tRepo,
        super(TournamentListLoading());

  @override
  Stream<TournamentListState> mapEventToState(
      TournamentListEvent event) async* {
    if (event is LoadTournamentLists) {
      yield* _mapLoadTournamentListsToState();
    } else if (event is TournamentListUpdated) {
      yield* _mapTournamentListUpdateToState(event);
    }
  }

  // Trigger load
  Stream<TournamentListState> _mapLoadTournamentListsToState() async* {
    print("TournamentListsBloc: _mapLoadTournamentListsToState");
    _tournamentSubscription?.cancel();
    _tournamentSubscription = _tournamentRepository.getTournamentInfos().listen(
          (t) => add(TournamentListUpdated(t)),
        );
  }

  // State is updated
  Stream<TournamentListState> _mapTournamentListUpdateToState(
      TournamentListUpdated event) async* {
    print("TournamentListsBloc: _mapTournamentListUpdateToState");
    yield TournamentListLoaded(event.tournaments);
  }

  @override
  Future<void> close() {
    print("TournamentListsBloc: close");
    _tournamentSubscription?.cancel();
    return super.close();
  }
}
