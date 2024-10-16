import 'ProductTagModel.dart';
import 'TerritoryModel.dart';

class DetailsUser {
  final String name;
  final String email;
  final String? phone;
  final String tz;
  final String image;
  final String representativeType;
  final List<Territory> territories;
  final List<ProductTag> productTags;
  final int rank;

  DetailsUser({
    required this.name,
    required this.email,
    this.phone,
    required this.tz,
    required this.image,
    required this.representativeType,
    required this.territories,
    required this.productTags,
    required this.rank,
  });

  factory DetailsUser.fromJson(Map<String, dynamic> json) {
    var territoriesList = json['territory_ids'] as List? ?? [];
    var productTagsList = json['product_tags'] as List? ?? [];

    return DetailsUser(
      name: json['name'] ?? 'No Name Available',
      email: json['email'] ?? 'No Email Available',
      phone: json['phone'],
      tz: json['tz'] ?? 'No Timezone Available',
      image: json['image'] ?? 'default_image_url', // URL افتراضي
      representativeType: json['representative_type'] ?? 'No Type Available',
      territories: territoriesList.map((i) => Territory.fromJson(i)).toList(),
      productTags: productTagsList.map((i) => ProductTag.fromJson(i)).toList(),
      rank: json['rank'] ?? 0, // قيمة افتراضية للرتبة
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'tz': tz,
      'image': image,
      'representative_type': representativeType,
      'territories': territories.map((i) => i.toJson()).toList(),
      'product_tags': productTags.map((i) => i.toJson()).toList(),
      'rank': rank,
    };
  }
}
