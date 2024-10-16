import 'package:equatable/equatable.dart';
import 'package:visit_man/model/userModel/monthlyPlanModel.dart';

abstract class MonthlyPlanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MonthlyPlanInitial extends MonthlyPlanState {}

class MonthlyPlanLoading extends MonthlyPlanState {}

class MonthlyPlanLoaded extends MonthlyPlanState {
  final List<dynamic> monthlyPlans;

  MonthlyPlanLoaded(this.monthlyPlans);

  @override
  List<Object?> get props => [monthlyPlans];
}

class MonthlyPlanError extends MonthlyPlanState {
  final String message;

  MonthlyPlanError(this.message);

  @override
  List<Object?> get props => [message];
}
