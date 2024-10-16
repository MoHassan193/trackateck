abstract class GetTodayVisitState {}

class GetTodayVisitInitial extends GetTodayVisitState {}

class GetTodayVisitLoading extends GetTodayVisitState {}

class GetTodayVisitSuccess extends GetTodayVisitState {
  final List<dynamic> visits;

  GetTodayVisitSuccess(this.visits);
}

class GetTodayNumberOfVisits extends GetTodayVisitState {
  final int count;

  GetTodayNumberOfVisits(this.count);
}


class GetTodayVisitError extends GetTodayVisitState {
  final String message;

  GetTodayVisitError(this.message);
}
