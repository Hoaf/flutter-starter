import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String priceUnit;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.priceUnit,
  });

  String get formattedPrice {
    final symbol = switch (priceUnit) {
      'euro' => '€',
      'inr' => '₹',
      _ => '\$',
    };
    return '$symbol${price.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [id, name, description, price, image, priceUnit];
}
