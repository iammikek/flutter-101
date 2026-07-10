class CategoryItemStats {
  const CategoryItemStats({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    required this.averagePrice,
  });

  final int categoryId;
  final String categoryName;
  final int itemCount;
  final double averagePrice;

  factory CategoryItemStats.fromJson(Map<String, dynamic> json) {
    return CategoryItemStats(
      categoryId: _asInt(json['category_id']) ?? 0,
      categoryName: (json['category_name'] ?? '').toString(),
      itemCount: _asInt(json['item_count']) ?? 0,
      averagePrice: _asDouble(json['average_price']),
    );
  }
}

class ItemStats {
  const ItemStats({
    required this.totalItems,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.uncategorizedCount,
    required this.byCategory,
  });

  final int totalItems;
  final double averagePrice;
  final double? minPrice;
  final double? maxPrice;
  final int uncategorizedCount;
  final List<CategoryItemStats> byCategory;

  factory ItemStats.fromJson(Map<String, dynamic> json) {
    final byCategory = json['by_category'];
    return ItemStats(
      totalItems: _asInt(json['total_items']) ?? 0,
      averagePrice: _asDouble(json['average_price']),
      minPrice: _asNullableDouble(json['min_price']),
      maxPrice: _asNullableDouble(json['max_price']),
      uncategorizedCount: _asInt(json['uncategorized_count']) ?? 0,
      byCategory: byCategory is List
          ? byCategory
              .map((e) => CategoryItemStats.fromJson(e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList()
          : const [],
    );
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

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}
