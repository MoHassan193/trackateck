abstract class PartnerVisitState {}

class PartnerVisitInitial extends PartnerVisitState {}

class PartnerVisitLoading extends PartnerVisitState {}

class PartnerVisitSuccess extends PartnerVisitState {
  final List<dynamic> visits;

  PartnerVisitSuccess(this.visits);
}

class PartnerNumberOfVisits extends PartnerVisitState {
  final int count;

  PartnerNumberOfVisits(this.count);
}


class PartnerVisitError extends PartnerVisitState {
  final String message;

  PartnerVisitError(this.message);
}
