class PartnerInfoModel {
  final int id;
  final String name;
  final String image;
  final String clientType;
  final String companyType;
  final String city;
  final String countryId;
  final String territoryId;
  final String speciality;
  final String clientAttitude;
  final List<ProductTag> productTags;
  final int noPotential;
  final int targetVisit;
  final bool street;  // Changed to bool
  final bool street2; // Changed to bool
  final bool? stateId; // Optional bool
  final bool? function; // Optional bool
  final bool? mobile; // Optional bool
  final bool? email; // Optional bool
  final double? latitude; // Optional field for latitude
  final double? longitude; // Optional field for longitude

  PartnerInfoModel({
    required this.id,
    required this.name,
    required this.image,
    required this.clientType,
    required this.companyType,
    required this.city,
    required this.countryId,
    required this.territoryId,
    required this.speciality,
    required this.clientAttitude,
    required this.productTags,
    required this.noPotential,
    required this.targetVisit,
    required this.street,
    required this.street2,
    this.stateId,
    this.function,
    this.mobile,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory PartnerInfoModel.fromJson(Map<String, dynamic> json) {
    return PartnerInfoModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      clientType: json['client_type'],
      companyType: json['company_type'],
      city: json['city'] ?? '',
      countryId: json['country_id'] ?? '',
      territoryId: json['territory_id'] ?? '',
      speciality: json['speciality'] ?? '',
      clientAttitude: json['client_attitude'] ?? '',
      productTags: (json['product_tags'] as List)
          .map((tag) => ProductTag.fromJson(tag))
          .toList(),
      noPotential: json['no_potential'] ?? 0,
      targetVisit: json['target_visit'] ?? 0,
      street: json['street'] ?? false,  // Default to false if null
      street2: json['street2'] ?? false, // Default to false if null
      stateId: json['state_id'] as bool?, // Optional
      function: json['function'] as bool?, // Optional
      mobile: json['mobile'] as bool?, // Optional
      email: json['email'] as bool?, // Optional
      latitude: json['partner_latitude'] != null
          ? json['partner_latitude'].toDouble()
          : null,
      longitude: json['partner_longitude'] != null
          ? json['partner_longitude'].toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'client_type': clientType,
      'company_type': companyType,
      'city': city,
      'country_id': countryId,
      'territory_id': territoryId,
      'speciality': speciality,
      'client_attitude': clientAttitude,
      'product_tags': productTags.map((tag) => tag.toJson()).toList(),
      'no_potential': noPotential,
      'target_visit': targetVisit,
      'street': street,
      'street2': street2,
      'state_id': stateId,
      'function': function,
      'mobile': mobile,
      'email': email,
      'partner_latitude': latitude,
      'partner_longitude': longitude,
    };
  }
}

class ProductTag {
  final int id;
  final String name;

  ProductTag({required this.id, required this.name});

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
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
