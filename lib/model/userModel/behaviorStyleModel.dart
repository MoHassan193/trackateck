class BehavioralStyleModel {
  final int id;
  final String name;

  BehavioralStyleModel({required this.id, required this.name});

  factory BehavioralStyleModel.fromJson(Map<String, dynamic> json) {
    return BehavioralStyleModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
