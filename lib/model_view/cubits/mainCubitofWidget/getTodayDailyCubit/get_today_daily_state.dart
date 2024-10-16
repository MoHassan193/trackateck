import '../../../../model/userModel/visitAterorityModel.dart';

import 'package:equatable/equatable.dart';

abstract class TodayDailyState extends Equatable {
  const TodayDailyState();

  @override
  List<Object> get props => [];
}

class TodayDailyInitial extends TodayDailyState {}

class TodayDailyLoading extends TodayDailyState {}

class TodayDailyLoaded extends TodayDailyState {
  final List<dynamic> todayDailies;

  const TodayDailyLoaded({required this.todayDailies});

  @override
  List<Object> get props => [todayDailies];
}

class TodayDailyError extends TodayDailyState {
  final String message;

  const TodayDailyError({required this.message});

  @override
  List<Object> get props => [message];
}
