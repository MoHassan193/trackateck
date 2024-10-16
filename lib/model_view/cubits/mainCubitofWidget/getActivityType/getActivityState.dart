import 'package:equatable/equatable.dart';

import '../../../../model/userModel/activityTypeModel.dart';

abstract class ActivityTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActivityTypeInitial extends ActivityTypeState {}

class ActivityTypeLoading extends ActivityTypeState {}

class ActivityTypeLoaded extends ActivityTypeState {
  final List<dynamic> activityTypes;

  ActivityTypeLoaded(this.activityTypes);

  @override
  List<Object?> get props => [activityTypes];
}

class ActivityTypeError extends ActivityTypeState {
  final String message;

  ActivityTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
