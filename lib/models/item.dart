class Item {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? category;

  Item({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final priceVal = json['price'];
    return Item(
      id: idVal is num ? idVal.toInt() : (idVal is String ? int.tryParse(idVal) : null),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: priceVal is num ? priceVal.toDouble() : (double.tryParse('$priceVal') ?? 0.0),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}
