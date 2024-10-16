import 'package:equatable/equatable.dart';

import '../../../../model/userModel/rechModel.dart';

abstract class RescheduleVisitState extends Equatable {
  const RescheduleVisitState();

  @override
  List<Object> get props => [];
}

class RescheduleVisitInitial extends RescheduleVisitState {}

class RescheduleVisitLoading extends RescheduleVisitState {}

class RescheduleVisitSuccess extends RescheduleVisitState {
  final RescheduleVisitModel visit;

  const RescheduleVisitSuccess(this.visit);

  @override
  List<Object> get props => [visit];
}

class RescheduleVisitFailure extends RescheduleVisitState {
  final String error;

  const RescheduleVisitFailure(this.error);

  @override
  List<Object> get props => [error];
}
