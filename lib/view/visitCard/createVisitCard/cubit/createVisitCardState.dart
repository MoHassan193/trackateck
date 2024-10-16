abstract class CreateVisitCardState {}

class CreateVisitCardInitial extends CreateVisitCardState {}

class CreateVisitCardLoading extends CreateVisitCardState {}

class CreateVisitCardSuccess extends CreateVisitCardState {
  final dynamic data; // يمكن أن تحتوي أي نوع من البيانات

  CreateVisitCardSuccess(this.data);
}

class CreateVisitCardError extends CreateVisitCardState {
  final String message;

  CreateVisitCardError(this.message);
}
