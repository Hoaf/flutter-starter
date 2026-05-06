import 'package:flutter_demo/data/services/apis/network_config.dart';
import 'package:flutter_demo/domain/usecases/auth_usecase.dart';
// import 'package:flutter_demo/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/networking/graphql/graphql_client.dart';
import 'package:flutter_demo/networking/graphql/graphql_client_interface.dart';
import 'package:flutter_demo/networking/restful/network_client.dart';
import 'package:flutter_demo/networking/restful/network_client_interface.dart';
import 'package:get_it/get_it.dart';

class NetworkServiceShared extends Config {
  NetworkServiceShared._internal();
  static final NetworkServiceShared _singleton =
      NetworkServiceShared._internal();
  factory NetworkServiceShared() => _singleton;

  late final IAuthUseCase _authUseCase = GetIt.I<IAuthUseCase>();
  // late final ILoginUseCase _loginUseCase = GetIt.I<ILoginUseCase>();

  INetworkClient? _abpNetworkClient;
  IGraphqlClient? _abpGraphglClient;

  IGraphqlClient get abpGraphqlClient {
    if(_abpGraphglClient != null) return _abpGraphglClient!;
    _abpGraphglClient = GraphqlClient(configGraphQL, getAccessToken: () => getOrRenewAccessToken());
    return _abpGraphglClient!;
  }

// MARK: NT NETWORK
  INetworkClient get abpNetworkClient {
    if (_abpNetworkClient != null) return _abpNetworkClient!;
    _abpNetworkClient = NetworkClient(config, renewTokenCallBack: () => getOrRenewAccessToken());
    /// TODO:
    // _authUseCase.getAccessToken().then((accessToken) => {
    //   _abpNetworkClient?.updateHeader(ApiKeys.authorizationKey, "${ApiKeys.previTokenStype} $accessToken")
    // });
    return _abpNetworkClient!;
  }

  Future<String> getOrRenewAccessToken() async {
    return "";
  }
}
