class NetworkConfig {
  String? baseUrl;
  int? defaultConnectTimeout;
  int? defaultReceiveTimeout;
  Map<String, dynamic>? headers;
  List<int>? unAuthorizationCodes;
  List<String>? shaFingerprints;
  List<String>? publicKeys;
  bool? isAllowSelfSigning;
  List<String>? pemCerts;

  /// MARK: NetworkConfig
  /// This is the constructor of NetworkConfig
  /// - Parameters:
  ///   - baseUrl: Request base url, it can contain sub path, like: "https://www.google.com/api/".
  ///   - defaultConnectTimeout: Timeout in milliseconds for opening url. [Dio] will throw the [DioError] with [DioErrorType.connectTimeout] type when time out.
  ///   - defaultReceiveTimeout:  Timeout in milliseconds for receiving data.
  ///  Note: [receiveTimeout]  represents a timeout during data transfer! That is to say the
  ///  client has connected to the server, and the server starts to send data to the client.
  ///
  /// [0] meanings no timeout limit.
  ///   - headers: Http request headers. The keys of initial headers will be converted to lowercase, for example 'Content-Type' will be converted to 'content-type'. The key of Header Map is case-insensitive, eg: content-type and Content-Type are regard as the same key.
  ///   - unAuthorizationCodes: error codes to detect unauthentication.
  ///   - shaFingerprints: sha fingerprints to pinning
  ///   - publicKeys: public Keys  to pinning
  ///   - pemCerts: pemCerts to handle Self Signed Certificate
  NetworkConfig({
    this.baseUrl,
    this.defaultConnectTimeout,
    this.defaultReceiveTimeout,
    this.headers,
    this.unAuthorizationCodes,
    this.shaFingerprints,
    this.publicKeys,
    this.pemCerts,
    this.isAllowSelfSigning,
  });
}