part of 'spectator_login_cubit.dart';

final class SpectatorLoginState extends Equatable {
  const SpectatorLoginState({
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final nafName = "Spectator";
  final FormzSubmissionStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];

  SpectatorLoginState copyWith({
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return SpectatorLoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
