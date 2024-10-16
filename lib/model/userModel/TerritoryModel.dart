
// Define the Territory model
class Territory {
  final int id;
  final String name;

  Territory({required this.id, required this.name});

  factory Territory.fromJson(Map<String, dynamic> json) {
    return Territory(
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
