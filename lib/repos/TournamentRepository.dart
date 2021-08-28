import 'package:amorical_cup/models/tournament.dart';

// TODO: Add ScopedModel

class TournamentRepository /* extends Model */ {
  late Duration _cacheValidDuration;
  late DateTime _lastFetchTime;

  List<Tournament> _tournamentList = [];

  static final TournamentRepository instance =
      TournamentRepository._privateConstructor();

  TournamentRepository._privateConstructor() {
    _cacheValidDuration = Duration(minutes: 30);
    _lastFetchTime = DateTime.fromMicrosecondsSinceEpoch(0);
  }

  /// Refreshes all records from the API, replacing the ones that are in the cache.
  /// Notifies listeners if notifyListeners is true.
  Future<void> refreshTournamentList(bool notifyListeners) async {
    _tournamentList =
        await _fakeApiCall(); // This makes the actual HTTP request
    _lastFetchTime = DateTime.now();

    /*
      if(notifyListeners) {
        this.notifyListeners();
      }
      */
  }

  Future<List<Tournament>> getTournamentList(
      {bool forceRefresh = false}) async {
    bool shouldRefreshFromApi = (_tournamentList == null ||
        _tournamentList.isEmpty ||
        _lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)) ||
        forceRefresh);

    if (shouldRefreshFromApi) await refreshTournamentList(false);

    return _tournamentList;
  }

  Future<List<Tournament>> _fakeApiCall() {
    return Future.delayed(
      const Duration(seconds: 3),
      () {
        List<Tournament> tournamentList = [];

        tournamentList.add(Tournament.getExampleTournament(
            "Amorical Cup", "Ottawa, Ontario, Canada", "2022-06-22"));

        tournamentList.add(Tournament.getExampleTournament(
            "Underworld Cup", "Franklin, Michigan, USA", "2022-11-09"));

        tournamentList.add(Tournament.getExampleTournament(
            "Canadian Open", "Toronto, Ontario, Canada", "2023-02-04"));

        tournamentList.add(Tournament.getExampleTournament(
            "Brewhouse Bowl", "Waterloo, Ontario, Canada", "2023-05-25"));

        return tournamentList;
      },
    );
  }
}
