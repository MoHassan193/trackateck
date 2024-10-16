import 'package:equatable/equatable.dart';
import 'package:visit_man/model/userModel/surveyModel.dart';

abstract class SurveyState extends Equatable {
  const SurveyState();

  @override
  List<Object> get props => [];
}

class SurveyInitial extends SurveyState {}

class SurveyLoading extends SurveyState {}

class SurveyLoaded extends SurveyState {
  final List<SurveyModel> surveys;

  const SurveyLoaded(this.surveys);

  @override
  List<Object> get props => [surveys];
}

class SurveyError extends SurveyState {
  final String message;

  const SurveyError(this.message);

  @override
  List<Object> get props => [message];
}
