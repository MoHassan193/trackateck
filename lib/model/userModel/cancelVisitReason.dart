class VisitCancelReasonModel {
  final int id;
  final String name;

  VisitCancelReasonModel({required this.id, required this.name});

  factory VisitCancelReasonModel.fromJson(Map<String, dynamic> json) {
    return VisitCancelReasonModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
