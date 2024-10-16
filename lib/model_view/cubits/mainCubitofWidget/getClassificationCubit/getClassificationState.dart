
import '../../../../model/userModel/calssificationModel.dart';

abstract class ClassificationsState {}

class ClassificationsInitial extends ClassificationsState {}

class ClassificationsLoading extends ClassificationsState {}

class ClassificationsLoaded extends ClassificationsState {
  final List<ClassificationModel> classifications;

  ClassificationsLoaded(this.classifications);
}

class ClassificationsError extends ClassificationsState {
  final String message;

  ClassificationsError(this.message);
}
