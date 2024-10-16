class SegmentationModel {
  final int id;
  final String name;

  SegmentationModel({required this.id, required this.name});

  factory SegmentationModel.fromJson(Map<String, dynamic> json) {
    return SegmentationModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
