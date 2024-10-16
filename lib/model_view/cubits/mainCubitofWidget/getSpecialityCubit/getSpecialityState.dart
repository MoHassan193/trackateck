
import '../../../../model/userModel/specialityModel.dart';

abstract class SpecialitiesState {}

class SpecialitiesInitial extends SpecialitiesState {}

class SpecialitiesLoading extends SpecialitiesState {}

class SpecialitiesLoaded extends SpecialitiesState {
  final List<SpecialityModel> specialities;

  SpecialitiesLoaded(this.specialities);
}

class SpecialitiesError extends SpecialitiesState {
  final String message;

  SpecialitiesError(this.message);
}
