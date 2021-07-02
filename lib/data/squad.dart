import 'package:json_annotation/json_annotation.dart';

part 'squad.g.dart';

@JsonSerializable(nullable: false)
class Squad {
  final String name; // Key

  final List<String> coaches; // nafNames

  final int wins;
  final int ties;
  final int losses;

  final int points;

  final bool stunty;

  Squad(this.name, this.coaches, this.wins, this.ties, this.losses, this.points,
      this.stunty);

  factory Squad.fromJson(Map<String, dynamic> json) => _$SquadFromJson(json);
  Map<String, dynamic> toJson() => _$SquadToJson(this);
}
