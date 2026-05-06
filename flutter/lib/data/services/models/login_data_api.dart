// import 'package:json_annotation/json_annotation.dart';
//
// @JsonSerializable()
// class LoginResponse {
//   @JsonKey(name: 'isSuccess')
//   bool? isSuccess;
//
//   @JsonKey(name: 'errorMessage')
//   String? errorMessage;
//
//   @JsonKey(name: 'accessToken')
//   String? accessToken;
//
//   @JsonKey(name: 'scope')
//   String? scope;
//
//   @JsonKey(name: 'accessTokenLifetime')
//   int? accessTokenLifetime;
//
//   @JsonKey(name: 'identityToken')
//   String? identityToken;
//
//   @JsonKey(name: 'refreshToken')
//   String? refreshToken;
//
//   @JsonKey(name: 'errorCode')
//   String? errorCode;
//
//   Profile? profile;
//
//   LoginResponse({required this.accessToken});
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       accessToken: json['accessToken'] as String?,
//     )
//     ..scope = json['scope'] as String?
//     ..refreshToken = json['refreshToken'] as String?
//     ..errorMessage = json['errorMessage'] as String?
//     ..identityToken = json['identifyToken'] as String?
//     ..errorCode = json['errorCode'] as String?
//     ..accessTokenLifetime = json['accessTokenLifetime'] as int
//     ..isSuccess = json['isSuccess'] as bool
//         ..profile = json['profile'] == null ? null : Profile.fromJson(json['profile']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return <String, dynamic> {
//       'accessToken': accessToken,
//       'scope': scope,
//       'refreshToken': refreshToken,
//       'errorMessage': errorMessage,
//       'identityToken': identityToken,
//       'accessTokenLifetime': accessTokenLifetime,
//       'isSuccess': isSuccess,
//       'errorCode': errorCode
//     };
//   }
//
//   @override
//   String toString() {
//     return 'LoginResponse(isSuccess: $isSuccess ,errorMessage: $errorMessage, accessToken: $accessToken, '
//         'scope: $scope, accessTokenLifetime: $accessTokenLifetime, identityToken: $identityToken, refreshToken: $refreshToken)';
//   }
// }
//
// class Profile {
//   @JsonKey(name: 'sub')
//   String? sub;
//
//   @JsonKey(name: 'email')
//   String? email;
//
//   @JsonKey(name: 'preferred_username')
//   String? preferredUsername;
//
//   @JsonKey(name: 'name')
//   String? name;
//
//   @JsonKey(name: 'email_verified')
//   String? emailVerified;
//
//   @JsonKey(name: 'subjectId')
//   String? subjectId;
//
//   @JsonKey(name: 'producer')
//   String? producer;
//
//   @JsonKey(name: 'sessionstamp')
//   String? sessionstamp;
//
//   Profile({required this.name});
//
//   factory Profile.fromJson(Map<String, dynamic> json) {
//     return Profile(name: json['name'] as String)
//       ..sub = json['sub'] as String?
//       ..email = json['email'] as String?
//       ..preferredUsername = json['preferred_username'] as String?
//       ..emailVerified = json['emailVerified'] as String?
//       ..subjectId = json['subjectId'] as String?
//       ..producer = json['producer'] as String?
//       ..sessionstamp = json['sessionstamp'] as String?;
//   }
// }