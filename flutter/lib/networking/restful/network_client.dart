import 'dart:io';

import 'package:flutter_demo/data/services/apis/network_config.dart';
import 'package:flutter_demo/networking/restful/network_client_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'network_config.dart';

class NetworkClient implements INetworkClient {
  NetworkConfig config;
  Function()? renewTokenCallBack;

  late Dio dio;

  NetworkClient(
      this.config, {
        this.renewTokenCallBack,
      }) {
    _initNetworkWithConfig(config);
  }


  /// Allow to add dio interceptors
  Future<void> _addInterceptors() async {
    dio.interceptors.addAll([
      InterceptorsWrapper(onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        if ((config.unAuthorizationCodes ?? []).contains(statusCode)) {
          // updateHeader(ApiKeys.authorizationKey, await renewTokenCallBack?.call());
          // Repeat the request with the updated header
          var options = error.requestOptions;
          options.headers[ApiKeys.authorizationKey] = await renewTokenCallBack?.call();

          return handler.resolve(await dio.fetch(options));
          // renewTokenCallBack?.call();
        } else {
          handler.next(error);
        }
      }
      )
    ]);
  }

  void _initNetworkWithConfig(NetworkConfig config) {
    dio = Dio();
    dio.interceptors.clear();
    addOptionsDio(config);
    _addInterceptors();
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
          request: false,
          requestBody: false));
    }
  }

  /// Allow to update request headers
  /// - Parameters:
  ///   - key: header key.
  ///   - value: header value.
  @override
  void updateHeader(String key, String value) {
    if (key.isNotEmpty) {
      config.headers?[key] = value;
      dio..options.headers = config.headers;
    }
  }

  Future<void> addOptionsDio(NetworkConfig config) async {
    dio
      ..options.baseUrl = config.baseUrl ?? ''
      ..options.connectTimeout = Duration(milliseconds: config.defaultConnectTimeout ?? 0)
      ..options.receiveTimeout = Duration(milliseconds: config.defaultReceiveTimeout ?? 0)
      ..httpClientAdapter
      ..options.headers = config.headers;
  }

  /// Handy method to make http POST request, which is a alias of [dio.fetch(RequestOptions)].
  @override
  Future<dynamic> post(
      String uri, {
        data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      var response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      _logInfo(uri, response);
      return response.data;
    } on FormatException catch (e) {
      _logError(uri, e.toString());
      throw const FormatException("Unable to process the data");
    } catch (e) {
      _logError(uri, e.toString());
      rethrow;
    }
  }


  /// Handy method to make http GET request, which is a alias of [dio.fetch(RequestOptions)].
  @override
  Future<dynamic> downloadBytes(
      String uri, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      var response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: Options(
            headers: options,
            // headers: {"authorization": await renewTokenCallBack?.call()},
            responseType: ResponseType.bytes,
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      _logInfo(uri, response);
      return response.data;
    } on SocketException catch (e) {
      _logError(uri, e.toString());
      throw SocketException(e.toString());
    } on FormatException catch (e) {
      _logError(uri, e.toString());
      throw const FormatException("Unable to process the data");
    } catch (e) {
      _logError(uri, e.toString());
      rethrow;
    }
  }

  /// Log response
  void _logInfo(String uri, Response<dynamic> response) {
    if (kDebugMode) {
      print("👍  $uri \nRESPONSE: $response");
    }
  }

  /// Log error
  void _logError(String uri, String error) {
    if (kDebugMode) {
      print("❌  $uri \nERROR: $error");
    }
  }
}