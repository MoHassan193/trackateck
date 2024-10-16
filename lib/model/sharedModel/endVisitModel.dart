class EndVisitDetails {
  String inDoom;
  String state;
  int rankId;
  int behaveStyleId;
  int segmentId;
  int classificationId;
  int noPatient;
  String clientAttitude;

  EndVisitDetails({
    required this.inDoom,
    required this.state,
    required this.rankId,
    required this.behaveStyleId,
    required this.segmentId,
    required this.classificationId,
    required this.noPatient,
    required this.clientAttitude,
  });

  // Convert a VisitDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      'in_doom': inDoom,
      'state': state,
      'rank_id': rankId,
      'behave_style_id': behaveStyleId,
      'segment_id': segmentId,
      'classification_id': classificationId,
      'no_patient': noPatient,
      'client_attitude': clientAttitude,
    };
  }

  // Create a VisitDetails object from JSON
  factory EndVisitDetails.fromJson(Map<String, dynamic> json) {
    return EndVisitDetails(
      inDoom: json['in_doom'],
      state: json['state'],
      rankId: json['rank_id'],
      behaveStyleId: json['behave_style_id'],
      segmentId: json['segment_id'],
      classificationId: json['classification_id'],
      noPatient: json['no_patient'],
      clientAttitude: json['client_attitude'],
    );
  }
}
