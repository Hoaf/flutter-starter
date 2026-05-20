import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String name;
  final double price;
  final String priceUnit;
  final String? image;
  final int quantity;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.priceUnit,
    this.image,
    required this.quantity,
  });

  String get formattedPrice {
    final symbol = switch (priceUnit) {
      'euro' => '€',
      'inr' => '₹',
      _ => '\$',
    };
    return '$symbol${price.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'price_unit': priceUnit,
        'image': image,
        'quantity': quantity,
      };

  factory CartItemEntity.fromMap(Map<String, dynamic> map) => CartItemEntity(
        productId: map['product_id'] as int,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        priceUnit: map['price_unit'] as String,
        image: map['image'] as String?,
        quantity: map['quantity'] as int,
      );

  CartItemEntity copyWith({
    int? productId,
    String? name,
    double? price,
    String? priceUnit,
    String? image,
    int? quantity,
  }) =>
      CartItemEntity(
        productId: productId ?? this.productId,
        name: name ?? this.name,
        price: price ?? this.price,
        priceUnit: priceUnit ?? this.priceUnit,
        image: image ?? this.image,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props =>
      [productId, name, price, priceUnit, image, quantity];
}
