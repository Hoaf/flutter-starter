import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String priceUnit;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.priceUnit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String?,
        priceUnit: json['priceUnit'] as String? ?? 'dollar',
      );

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        description: description,
        price: price,
        image: image,
        priceUnit: priceUnit,
      );
}
