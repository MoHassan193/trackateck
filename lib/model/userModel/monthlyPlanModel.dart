class MonthlyPlanModel {
  final int id;
  final String title;
  final String user;
  final int userId;
  final String teamleadName;
  final int teamleadId;
  final String startDate;
  final String endDate;
  final String state;

  MonthlyPlanModel({
    required this.id,
    required this.title,
    required this.user,
    required this.userId,
    required this.teamleadName,
    required this.teamleadId,
    required this.startDate,
    required this.endDate,
    required this.state,
  });

  factory MonthlyPlanModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPlanModel(
      id: json['id'],
      title: json['title'],
      user: json['user'],
      userId: json['user_id'],
      teamleadName: json['teamlead_name'],
      teamleadId: json['teamlead_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user': user,
      'user_id': userId,
      'teamlead_name': teamleadName,
      'teamlead_id': teamleadId,
      'start_date': startDate,
      'end_date': endDate,
      'state': state,
    };
  }
}
