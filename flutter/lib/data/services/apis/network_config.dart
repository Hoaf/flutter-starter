import 'package:flutter_demo/data/services/config/api_config.dart';
import 'package:flutter_demo/networking/graphql/graphql_config.dart';
import 'package:flutter_demo/networking/restful/network_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';


class ApiKeys {
  static const defaultConnectTimeout = Duration.millisecondsPerMinute;
  static const defaultReceiveTimeout = Duration.millisecondsPerMinute;
  static const contentTypeKey = 'Content-Type';
  static const contentTypeValue = 'application/json; charset=UTF-8';
  static const authorizationKey = 'Authorization';
  static const xAccessTokenKey = 'x-access-token';

  static const previTokenStype = 'Bearer';
  static const unAuthorizationCodes = [401, 403];
  static const List<int>? unAuthorizationCodesCoinbase = [];
}

@injectable
class Config {
  static List<String> get getCerts {
    //TODO: update dotenv.env['PEM_CERTS'] to the value of the path contain the pem file after refactor checkServerTrust
    // String cert = [dotenv.env['PEM_CERTS'] ?? ''].toString();
    // return [cert];
    return [];
  }

  NetworkConfig config = NetworkConfig(
    baseUrl: APIConfig.baseApiUrl,
    defaultConnectTimeout: ApiKeys.defaultConnectTimeout,
    defaultReceiveTimeout: ApiKeys.defaultReceiveTimeout,
    headers: {
      ApiKeys.contentTypeKey: ApiKeys.contentTypeValue,
      ApiKeys.authorizationKey: '${ApiKeys.previTokenStype} token'
    },
    unAuthorizationCodes: ApiKeys.unAuthorizationCodes,
    shaFingerprints: [dotenv.env['FINGER_PRINT_SHA256'] ?? ''],
    publicKeys: [dotenv.env['PUBLIC_KEY'] ?? ''],
    isAllowSelfSigning: "true" == dotenv.env['SELF_SIGNING'],
    pemCerts: Config.getCerts,
  );

  GraphqlConfig configGraphQL = GraphqlConfig(
    baseUrl: APIConfig.baseGraphQLApiUrl
  );
}
