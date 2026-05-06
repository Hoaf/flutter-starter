import 'package:dio/dio.dart';

abstract class INetworkClient {

  /// Allow to update http request header
  /// - Parameters:
  ///   - key: header key.
  ///   - value: header value.
  void updateHeader(String key, String value);

    /// Handy method to make http POST request, which is a alias of  [dio.fetch(RequestOptions)].
  Future<dynamic> post(
      String uri, {
        data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      });

  /// Handy method to make http GET request, which is a alias of [dio.fetch(RequestOptions)].
  Future<dynamic> downloadBytes(
      String uri, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      });
}