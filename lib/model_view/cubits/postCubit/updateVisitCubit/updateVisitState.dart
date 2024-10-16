import 'package:equatable/equatable.dart';

abstract class UpdateVisitState extends Equatable {
  const UpdateVisitState();

  @override
  List<Object> get props => [];
}

class UpdateVisitInitial extends UpdateVisitState {}

class UpdateVisitLoading extends UpdateVisitState {}

class UpdateVisitSuccess extends UpdateVisitState {
  final Map<String, dynamic> data;

  const UpdateVisitSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class UpdateVisitFailure extends UpdateVisitState {
  final String error;

  const UpdateVisitFailure(this.error);

  @override
  List<Object> get props => [error];
}
