import 'package:equatable/equatable.dart';

abstract class MatchReportState extends Equatable {
  const MatchReportState();

  @override
  List<Object> get props => [];
}

class NotAuthorizedMatchReportState extends MatchReportState {}

class EditingMatchReportState extends MatchReportState {
  // list of naf names that the logged in user has access to edit
  final List<String> nafNames;

  EditingMatchReportState(this.nafNames);

  @override
  List<Object> get props => [nafNames];

  @override
  String toString() => 'EditingMatchReport { nafNames: $nafNames }';
}

class UploadedAwaitingMatchReportState extends MatchReportState {
  // list of naf names that the logged in user has access to edit
  final List<String> nafNames;

  UploadedAwaitingMatchReportState(this.nafNames);

  @override
  List<Object> get props => [nafNames];

  @override
  String toString() => 'UploadedAwaitingMatchReport { nafNames: $nafNames }';
}

class UploadedConfirmedMatchReportState extends MatchReportState {
  // list of naf names that the logged in user has access to edit
  final List<String> nafNames;

  UploadedConfirmedMatchReportState(this.nafNames);

  @override
  List<Object> get props => [nafNames];

  @override
  String toString() => 'UploadedConfirmedMatchReport { nafNames: $nafNames }';
}

class ErrorMatchReportState extends MatchReportState {
  // list of naf names that the logged in user has access to edit
  final List<String> nafNames;

  ErrorMatchReportState(this.nafNames);

  @override
  List<Object> get props => [nafNames];

  @override
  String toString() => 'ErrorMatchReport { nafNames: $nafNames }';
}
