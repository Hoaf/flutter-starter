import 'package:dio/dio.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_demo/features/product/domain/entities/product_entity.dart';
import 'package:flutter_demo/features/product/domain/repositories/i_product_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDatasource _remote;

  const ProductRepositoryImpl(this._remote);

  @override
  Future<Result<List<ProductEntity>, String>> getProducts() async {
    try {
      final models = await _remote.getProducts();
      return Success(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Failure('No network connection');
      }
      return Failure('Failed to load products');
    } catch (e) {
      return Failure('An unexpected error occurred');
    }
  }
}
