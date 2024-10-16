class VisitObjectiveModel {
  final int id;
  final String name;
  final String type;

  VisitObjectiveModel({required this.id, required this.name, required this.type});

  factory VisitObjectiveModel.fromJson(Map<String, dynamic> json) {
    return VisitObjectiveModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
