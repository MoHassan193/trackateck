class LeaveBehindModel {
  final int id;
  final String name;

  LeaveBehindModel({required this.id, required this.name});

  factory LeaveBehindModel.fromJson(Map<String, dynamic> json) {
    return LeaveBehindModel(
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
