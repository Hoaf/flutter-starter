import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/product/data/models/product_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProductRemoteDatasource {
  final Dio _dio;

  ProductRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<List<ProductModel>> getProducts() async {
    final response = await _dio.get('/product/');
    final list = response.data['data'] as List;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
