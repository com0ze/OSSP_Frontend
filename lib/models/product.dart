class Product {
  final String name;
  final String category;

  Product({
    required this.name,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
    };
  }

  Product copyWith({
    String? name,
    String? category,
  }) {
    return Product(
      name: name ?? this.name,
      category: category ?? this.category,
    );
  }
}
