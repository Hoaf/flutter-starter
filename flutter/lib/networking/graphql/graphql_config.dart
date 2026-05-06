class GraphqlConfig {
  String? baseUrl;
  int? defaultConnectTimeout;
  int? defaultReceiveTimeout;
  Map<String, dynamic>? headers;
  List<int>? unAuthorizationCodes;
  List<String>? shaFingerprints;
  List<String>? publicKeys;
  bool? isAllowSelfSigning;
  List<String>? pemCerts;

  GraphqlConfig({
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