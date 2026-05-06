import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/networking/graphql/graphql_client_interface.dart';
import 'package:flutter_demo/networking/graphql/graphql_config.dart';
import 'package:flutter_demo/presentation/extensions/exception_message_extension.dart';
import 'package:flutter_demo/presentation/utilities/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';

class GraphqlClient implements IGraphqlClient {
  GraphqlConfig config;
  Function()? renewTokenCallBack;
  Function()? getAccessToken;

  late GraphQLClient client;
  late Link link;

  final Duration _timeoutSeconds = const Duration(seconds: 30);

  GraphqlClient(this.config, {required this.getAccessToken, this.renewTokenCallBack}) {
    _initNetworkWithConfig(config);
  }

  void _initNetworkWithConfig(GraphqlConfig config) {
    final httpLink = HttpLink(
      config.baseUrl ?? ""
    );
    final authLink = AuthLink(
        getToken: () async {
          return getAccessToken?.call() ?? "";
        }
    );
    link = authLink.concat(httpLink);
    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      queryRequestTimeout: _timeoutSeconds
    );
  }

  @override
  Future<dynamic> get(String query, Map<String, dynamic> variables) async {
    // print("=====>*${variables["getRemittanceListInput"]["producerId"]}" );
    client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
        queryRequestTimeout: _timeoutSeconds
    );
    final QueryOptions options = QueryOptions(
        document: gql(query),
        variables: variables
    );
    final QueryResult result = await client.query(options);
    if(result.hasException) {
      if (kDebugMode) {
        print("Has exception: $result");
      }
      ApiError apiError = ApiError("EXCEPTION");

      final exception = result.exception;
      final linkException = exception?.linkException;

      if (linkException is ServerException) {
        final response = linkException.parsedResponse;

        final responseCode = response?.response["ResponseCode"];
        final errorMessage = response?.response["ErrorMessage"];

        if (responseCode == AppConstants.kCode401
            && errorMessage == AppConstants.kMsgInvalidAuthTime) {
          throw SessionExpiredException();
        }
      }

      return Failure(apiError, data: result.data);
    }
    if (kDebugMode) {
      print("GraphQL Response Data: ${result.data}");
    }
    return Success(result.data);
  }

}