import 'package:equatable/equatable.dart';

import '../../../../model/userModel/visitObjectiveModel.dart';

abstract class VisitObjectiveState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitObjectiveInitial extends VisitObjectiveState {}

class VisitObjectiveLoading extends VisitObjectiveState {}

class VisitObjectiveLoaded extends VisitObjectiveState {
  final List<VisitObjectiveModel> visitObjectives;

  VisitObjectiveLoaded(this.visitObjectives);

  @override
  List<Object?> get props => [visitObjectives];
}

class VisitObjectiveError extends VisitObjectiveState {
  final String message;

  VisitObjectiveError(this.message);

  @override
  List<Object?> get props => [message];
}
