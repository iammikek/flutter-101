class Item {
  final int? id;
  final String name;
  final double? price;

  Item({this.id, required this.name, this.price});

  factory Item.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final priceVal = json['price'];
    return Item(
      id: idVal is num ? idVal.toInt() : (idVal is String ? int.tryParse(idVal) : null),
      name: (json['name'] ?? '').toString(),
      price: priceVal is num
          ? priceVal.toDouble()
          : (priceVal is String ? double.tryParse(priceVal) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (price != null) 'price': price,
    };
  }
}
