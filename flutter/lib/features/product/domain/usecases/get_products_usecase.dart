import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProductsUseCase {
  final IProductRepository _repo;
  const GetProductsUseCase(this._repo);

  Future<Result<List<ProductEntity>, String>> call() => _repo.getProducts();
}
