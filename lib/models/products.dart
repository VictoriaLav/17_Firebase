const kName = 'name';
const kIsBought = 'isBought';

class Product {
  String name;
  bool isBought;

  Product({required this.name, required this.isBought});

  factory Product.fromJson(Map<String, Object?> json) => Product(
    name: json[kName]! as String,
    isBought: json[kIsBought]! as bool,
  );

  Map<String, Object?> toJson() => {kName: name, kIsBought: isBought};
}
