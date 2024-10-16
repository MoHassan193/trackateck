part of 'end_visit_cubit.dart';

@immutable
sealed class EndVisitState {}

final class EndVisitInitial extends EndVisitState {}

final class EndVisitSuccess extends EndVisitState {}

final class EndVisitLoading extends EndVisitState {}

final class EndVisitError extends EndVisitState {}

