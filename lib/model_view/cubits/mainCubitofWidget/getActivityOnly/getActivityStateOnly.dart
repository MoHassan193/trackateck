import 'package:equatable/equatable.dart';

import '../../../../model/userModel/activityModel.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<dynamic> activities;

  const ActivityLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object> get props => [message];
}