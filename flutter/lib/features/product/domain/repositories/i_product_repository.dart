import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';

abstract class IProductRepository {
  Future<Result<List<ProductEntity>, String>> getProducts();
}
