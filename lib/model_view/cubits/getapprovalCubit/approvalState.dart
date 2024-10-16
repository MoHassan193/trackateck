
abstract class ApprovalState {}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class ApprovalLoaded extends ApprovalState {
  final List<dynamic> approvals;

  ApprovalLoaded(this.approvals);
}

class ApprovalError extends ApprovalState {
  final String message;

  ApprovalError(this.message);
}
