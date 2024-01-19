part of 'guest_login_cubit.dart';

final class GuestLoginState extends Equatable {
  const GuestLoginState({
    this.nafName = "",
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final String nafName;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [nafName, status, isValid, errorMessage];

  GuestLoginState copyWith({
    String? nafName,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return GuestLoginState(
      nafName: nafName ?? this.nafName,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
