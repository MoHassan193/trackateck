class ActivityModel {
  final String id;
  final String resName;
  final int activityTypeId;
  final String userId;
  final String resId;
  final String resModel;
  final String dateDeadline;
  final String summary;
  final String note;

  ActivityModel({
    required this.id,
    required this.resName,
    required this.activityTypeId,
    required this.userId,
    required this.resId,
    required this.resModel,
    required this.dateDeadline,
    required this.summary,
    required this.note,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'].toString(),
      resName: json['res_name'] as String,
      activityTypeId: json['activity_type_id'] as int,
      userId: json['user_id'] as String,
      resId: json['res_id'].toString(),
      resModel: json['res_model'] as String,
      dateDeadline: json['date_deadline'] as String,
      summary: json['summary'] as String,
      note: json['note'] as String,
    );
  }

Map<String, dynamic> toJson() {
    return {
      'id': id,
      'res_name': resName,
      'activity_type_id': activityTypeId,
      'summary': summary,
      'date_deadline': dateDeadline,
      'user_id': userId,
      'note': note,
      'res_model': resModel,
      'res_id': resId,
    };
  }
}
