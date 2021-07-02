import 'package:json_annotation/json_annotation.dart';

part 'coach.g.dart';

@JsonSerializable(nullable: false)
class Coach {
  final String nafName; // Key

  final String squadName;

  final String name;

  final String race;

  final int wins;
  final int ties;
  final int losses;

  final int points;

  final int tds;
  final int cas;

  final bool stunty;

  Coach(this.nafName, this.squadName, this.name, this.race, this.wins,
      this.ties, this.losses, this.points, this.tds, this.cas, this.stunty);

  factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
  Map<String, dynamic> toJson() => _$CoachToJson(this);
}
