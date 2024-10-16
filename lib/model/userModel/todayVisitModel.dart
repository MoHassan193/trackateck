class VisitsResponse {
  final int count;
  final List<TodayVisitModel> data;

  VisitsResponse({required this.count, required this.data});

  factory VisitsResponse.fromJson(Map<String, dynamic> json) {
    return VisitsResponse(
      count: json['count'],
      data: (json['data'] as List).map((e) => TodayVisitModel.fromJson(e)).toList(),
    );
  }

}

class TodayVisitModel {
  final int visitId;
  final String title;
  final String representative;
  final String representativeImage;
  final String territoryId;
  final String? partnerId;
  final int? partnerRecId;
  final double partnerLatitude;
  final double partnerLongitude;
  final String partnerImage;
  final String? clientType;
  final String? rankId;
  final String? rankName;
  final String? specialityId;
  final String? specialityName;
  final String? classificationId;
  final String? classificationName;
  final String? behaveStyleId;
  final String? behaveStyleName;
  final String? segmentId;
  final String? segmentName;
  final int noPotential;
  final String? clientAttitude;
  final List<Objective> objectiveIds;
  final String objectiveInfo;
  final String state;
  final List<Product> products;
  final List<Product> optionalProducts;
  final List<dynamic> campaigns;
  final bool isDoubleVisit;
  final String? collaborativeId;
  final String collaborativeImage;
  final String? doubleVisitType;
  final String? surveyName;
  final int? surveyId;
  final String? surveyImage;
  final String? surveyLink;

  TodayVisitModel({
    required this.visitId,
    required this.title,
    required this.representative,
    required this.representativeImage,
    required this.territoryId,
    this.partnerId,
    this.partnerRecId,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.partnerImage,
    this.clientType,
    this.rankId,
    this.rankName,
    this.specialityId,
    this.specialityName,
    this.classificationId,
    this.classificationName,
    this.behaveStyleId,
    this.behaveStyleName,
    this.segmentId,
    this.segmentName,
    required this.noPotential,
    this.clientAttitude,
    required this.objectiveIds,
    required this.objectiveInfo,
    required this.state,
    required this.products,
    required this.optionalProducts,
    required this.campaigns,
    required this.isDoubleVisit,
    this.collaborativeId,
    required this.collaborativeImage,
    this.doubleVisitType,
    this.surveyName,
    this.surveyId,
    this.surveyImage,
    this.surveyLink,
  });

  factory TodayVisitModel.fromJson(Map<String, dynamic> json) {
    return TodayVisitModel(
      visitId: json['visit_id'],
      title: json['title'],
      representative: json['representative'],
      representativeImage: json['representative_image'],
      territoryId: json['territory_id'],
      partnerId: json['partner_id'],
      partnerRecId: json['partner_rec_id'],
      partnerLatitude: json['partner_latitude'].toDouble(),
      partnerLongitude: json['partner_longitude'].toDouble(),
      partnerImage: json['partner_image'],
      clientType: json['client_type'],
      rankId: json['rank_id'],
      rankName: json['rank_name'],
      specialityId: json['speciality_id'],
      specialityName: json['speciality_name'],
      classificationId: json['classification_id'],
      classificationName: json['classification_name'],
      behaveStyleId: json['behave_style_id'],
      behaveStyleName: json['behave_style_name'],
      segmentId: json['segment_id'],
      segmentName: json['segment_name'],
      noPotential: json['no_potential'],
      clientAttitude: json['client_attitude'],
      objectiveIds: (json['objective_ids'] as List).map((e) => Objective.fromJson(e)).toList(),
      objectiveInfo: json['objective_info'],
      state: json['state'],
      products: (json['products'] as List).map((e) => Product.fromJson(e)).toList(),
      optionalProducts: (json['optional_products'] as List).map((e) => Product.fromJson(e)).toList(),
      campaigns: json['campaigns'] ?? [],
      isDoubleVisit: json['is_double_visit'],
      collaborativeId: json['collaborative_id'],
      collaborativeImage: json['collaborative_image'],
      doubleVisitType: json['double_visit_type'],
      surveyName: json['survey_name'],
      surveyId: json['survey_id'],
      surveyImage: json['survey_image'],
      surveyLink: json['survey_link'],
    );
  }
}

class Objective {
  final int id;
  final String name;

  Objective({required this.id, required this.name});

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Product {
  final String productName;
  final String productImageUrl;
  final double salePrice;
  final int qty;

  Product({
    required this.productName,
    required this.productImageUrl,
    required this.salePrice,
    required this.qty,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'],
      productImageUrl: json['product_image_ur'],
      salePrice: json['sale_price'].toDouble(),
      qty: json['qty'],
    );
  }
}
