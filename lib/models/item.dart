import 'category.dart';

class Item {
  const Item({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.category,
  });

  final int? id;
  final String name;
  final String? description;
  final double price;
  final int? categoryId;
  final Category? category;

  String get categoryLabel => category?.name ?? (categoryId == null ? 'Uncategorized' : 'Category #$categoryId');

  factory Item.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    return Item(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: _asDouble(json['price']),
      categoryId: _asInt(json['category_id']),
      category: categoryJson is Map<String, dynamic> ? Category.fromJson(categoryJson) : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
      'price': price,
      if (categoryId != null) 'category_id': categoryId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
    };
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
