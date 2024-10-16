import '../../../../model/userModel/behaviorStyleModel.dart';


abstract class BehavioralStylesState {}

class BehavioralStylesInitial extends BehavioralStylesState {}

class BehavioralStylesLoading extends BehavioralStylesState {}

class BehavioralStylesLoaded extends BehavioralStylesState {
  final List<BehavioralStyleModel> styles;

  BehavioralStylesLoaded(this.styles);
}

class BehavioralStylesError extends BehavioralStylesState {
  final String message;

  BehavioralStylesError(this.message);
}
