class ProductModel {
  final int id;
  final String name;
  final List<int> productTagIds; // إضافة الخاصية الجديدة

  ProductModel({
    required this.id,
    required this.name,
    required this.productTagIds, // إضافة الخاصية الجديدة في المُنشئ
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      productTagIds: List<int>.from(json['product_tag_ids']), // تحويل القائمة من json
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_tag_ids': productTagIds, // إضافة الخاصية الجديدة في تحويل json
    };
  }
}
