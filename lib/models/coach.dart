import 'package:bbnaf/models/matchup/coach_matchup.dart';
import 'package:bbnaf/models/matchup/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
import 'package:bbnaf/models/tournament/tournament_info.dart';

class Coach extends IMatchupParticipant {
  // late int teamId;

  late String nafName; // Key

  late String squadName;

  late String coachName;

  late String teamName;

  late int nafNumber;

  late Race _race;

  bool active = true;

  int _wins = 0;
  int _ties = 0;
  int _losses = 0;

  double _points = 0;

  int tds = 0;
  int cas = 0;

  List<double> _tieBreakers = <double>[];

  List<String> _opponents = <String>[];

  List<CoachMatchup> matches = [];

  Coach(
    // this.teamId,
    this.nafName,
    this.squadName,
    this.coachName,
    this._race,
    this.teamName,
    this.nafNumber,
  );

  @override
  OrgType type() {
    return OrgType.Coach;
  }

  @override
  String name() {
    return nafName;
  }

  @override
  String parentName() {
    return squadName;
  }

  @override
  Race race() {
    return _race;
  }

  @override
  double points() {
    return _points;
  }

  @override
  int wins() {
    return _wins;
  }

  @override
  int ties() {
    return _ties;
  }

  @override
  int losses() {
    return _losses;
  }

  @override
  List<double> tiebreakers() {
    return _tieBreakers;
  }

  @override
  List<String> opponents() {
    return _opponents;
  }

  void setRace(Race r) {
    this._race = r;
  }

  void overwriteRecord(TournamentInfo t) {
    _wins = 0;
    _ties = 0;
    _losses = 0;
    _points = 0;
    tds = 0;
    cas = 0;
    _opponents.clear();

    matches.forEach((m) {
      ReportedMatchResultWithStatus matchStats = m.getReportedMatchStatus();
      MatchResult matchResult = m.getResult();

      if (nafName == m.homeNafName) {
        switch (matchResult) {
          case MatchResult.HomeWon:
            _wins++;
            break;
          case MatchResult.AwayWon:
            _losses++;
            break;
          case MatchResult.Draw:
            _ties++;
            break;
          default:
            break;
        }

        tds += matchStats.homeTds;
        cas += matchStats.homeCas;
        _opponents.add(m.awayNafName);
      } else if (nafName == m.awayNafName) {
        switch (matchResult) {
          case MatchResult.HomeWon:
            _losses++;
            break;
          case MatchResult.AwayWon:
            _wins++;
            break;
          case MatchResult.Draw:
            _ties++;
            break;
          default:
            break;
        }

        tds += matchStats.awayTds;
        cas += matchStats.awayCas;
        _opponents.add(m.homeNafName);
      }
    });

    _points = _wins * t.scoringDetails.winPts +
        _ties * t.scoringDetails.tiePts +
        _losses * t.scoringDetails.lossPts;
  }

  Coach.fromJson(int id, Map<String, Object?> json) {
    // this.teamId = id;

    final tNafName = json['naf_name'] as String?;
    this.nafName = tNafName != null ? tNafName : "";

    final tCoachName = json['coach_name'] as String?;
    this.coachName = tCoachName != null ? tCoachName : "";

    final tTeamName = json['team_name'] as String?;
    this.teamName = tTeamName != null ? tTeamName : "";

    final tSquadName = json['squad_name'] as String?;
    this.squadName = tSquadName != null ? tSquadName : "";

    final tRace = json['race'] as String?;
    this._race = tRace != null ? RaceUtils.getRace(tRace) : Race.Unknown;

    final tNafNumber = json['naf_number'] as int?;
    this.nafNumber = tNafNumber != null ? tNafNumber : -1;
  }

  Map<String, dynamic> toJson() => {
        'naf_name': nafName,
        'coach_name': coachName,
        'team_name': teamName,
        'squad_name': squadName,
        'race': RaceUtils.getName(_race),
        'naf_number': nafNumber,
      };
}
