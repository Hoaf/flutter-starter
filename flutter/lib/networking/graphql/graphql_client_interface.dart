import 'package:dio/dio.dart';

abstract class IGraphqlClient {
  /// Handy method to make http POST request, which is a alias of  [dio.fetch(RequestOptions)].
  // Future<dynamic> post(
  //     String uri, {
  //       data,
  //       Map<String, dynamic>? queryParameters,
  //       Map<String, dynamic>? options,
  //       CancelToken? cancelToken,
  //       ProgressCallback? onSendProgress,
  //       ProgressCallback? onReceiveProgress,
  //     });

    Future<dynamic> get(String query, Map<String, dynamic> variables);
}