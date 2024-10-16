
import 'package:equatable/equatable.dart';

import '../../../../model/userModel/cancelVisitReason.dart';

abstract class VisitCancelReasonState extends Equatable {
  const VisitCancelReasonState();

  @override
  List<Object> get props => [];
}

class VisitCancelReasonInitial extends VisitCancelReasonState {}

class VisitCancelReasonLoading extends VisitCancelReasonState {}

class VisitCancelReasonLoaded extends VisitCancelReasonState {
  final List<dynamic> reasons;

  const VisitCancelReasonLoaded(this.reasons);

  @override
  List<Object> get props => [reasons];
}

class VisitCancelReasonError extends VisitCancelReasonState {
  final String message;

  const VisitCancelReasonError(this.message);

  @override
  List<Object> get props => [message];
}
