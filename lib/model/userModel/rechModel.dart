class RescheduleVisitModel {
  final String state;
  final String rescheduleDate;

  RescheduleVisitModel({required this.state, required this.rescheduleDate});

  factory RescheduleVisitModel.fromJson(Map<String, dynamic> json) {
    return RescheduleVisitModel(
      state: json['state'],
      rescheduleDate: json['reschedule_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'reschedule_date': rescheduleDate,
    };
  }
}
