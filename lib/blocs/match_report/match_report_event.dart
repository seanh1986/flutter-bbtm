import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class MatchReportEvent extends Equatable {
  MatchReportEvent();

  @override
  List<Object> get props => [];
}

class AppStartMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'AppStartMatchReportEvent';
}

class SignInMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'SignInMatchReportEvent';
}

class SubmitMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'SubmitMatchReportEvent';
}

class ComfirmMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'ComfirmMatchReportEvent';
}

class ErrorMatchReportEvent extends MatchReportEvent {
  @override
  String toString() => 'ErrorMatchReportEvent';
}
