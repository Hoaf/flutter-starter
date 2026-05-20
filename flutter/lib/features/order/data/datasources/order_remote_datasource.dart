import 'package:dio/dio.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/features/order/data/models/order_model.dart';
import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OrderRemoteDatasource {
  final Dio _dio;

  OrderRemoteDatasource(ApiClient client) : _dio = client.dio;

  Future<OrderModel> placeOrder({
    required List<CartItemEntity> items,
    required double totalAmount,
  }) async {
    final response = await _dio.post('/order/', data: {
      'items': items
          .map((e) => {
                'productId': e.productId,
                'quantity': e.quantity,
                'price': e.price,
              })
          .toList(),
      'totalAmount': totalAmount,
      'shippingAddress': 'Default Address',
      'paymentMethod': 'cash_on_delivery',
    });
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get('/order/');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
