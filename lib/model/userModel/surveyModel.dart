class SurveyModel {
  final int id;
  final String title;

  SurveyModel({required this.id, required this.title});

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'],
      title: json['title'],
    );
  }
}
