class ClassificationModel {
  final int id;
  final String name;
  final String clientType;

  ClassificationModel({
    required this.id,
    required this.name,
    required this.clientType,
  });

  factory ClassificationModel.fromJson(Map<String, dynamic> json) {
    return ClassificationModel(
      id: json['id'],
      name: json['name'],
      clientType: json['client_type'],
    );
  }
}
