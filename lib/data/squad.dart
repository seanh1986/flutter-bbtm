import 'package:amorical_cup/data/i_matchup.dart';
import 'package:amorical_cup/data/races.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'squad.g.dart';

// @JsonSerializable(nullable: false)
class Squad extends IMatchupParticipant {
  final String _name; // Key

  final List<String> coaches; // nafNames

  final int _wins;
  final int _ties;
  final int _losses;

  final int _points;

  final bool stunty;

  Squad(this._name, this.coaches, this._wins, this._ties, this._losses,
      this._points, this.stunty);

  @override
  String name() {
    return _name;
  }

  @override
  Race race() {
    return Race.Unknown;
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

  // factory Squad.fromJson(Map<String, dynamic> json) => _$SquadFromJson(json);
  // Map<String, dynamic> toJson() => _$SquadToJson(this);
}
