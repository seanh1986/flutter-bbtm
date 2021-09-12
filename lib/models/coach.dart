import 'package:bbnaf/models/i_matchup.dart';
import 'package:bbnaf/models/races.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'coach.g.dart';

// @JsonSerializable(nullable: false)
class Coach extends IMatchupParticipant {
  final String nafName; // Key

  final String squadName;

  final String coachName;

  final Race _race;

  final int _wins;
  final int _ties;
  final int _losses;

  final int _points;

  final int tds;
  final int cas;

  final bool stunty;

  Coach(this.nafName, this.squadName, this.coachName, this._race, this._wins,
      this._ties, this._losses, this._points, this.tds, this.cas, this.stunty);

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
  int points() {
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

  // factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
  // Map<String, dynamic> toJson() => _$CoachToJson(this);
}
