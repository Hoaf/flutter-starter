class LoginData {
  final bool isSuccess;
  final String errorMessage;
  final String errorCode;
  final String accessToken;
  final String scope;
  final int accessTokenLifetime;
  final String identityToken;
  final String refreshToken;
  final ProfileData profile;

  LoginData({
    required this.isSuccess,
    required this.accessToken,
    required this.errorMessage,
    required this.errorCode,
    required this.scope,
    required this.accessTokenLifetime,
    required this.identityToken,
    required this.refreshToken,
    required this.profile
  });

  @override
  String toString() {
    return 'LoginModel(isSuccess: $isSuccess, errorMessage: $errorMessage, isVerified: $accessToken, '
        'accessToken: $accessToken, scope: $scope, accessTokenLifetime: $accessTokenLifetime, '
        'identityToken: $identityToken, refreshToken: $refreshToken)';
  }
}

class ProfileData {
  final String sub;
  final String email;
  final String preferredUsername;
  final String name;
  final String emailVerified;
  final String subjectId;
  final String producer;
  final String sessionstamp;

  ProfileData({required this.sub, required this.email, required this.preferredUsername,
    required this.name, required this.emailVerified, required this.subjectId, required this.producer, required this.sessionstamp});
}
