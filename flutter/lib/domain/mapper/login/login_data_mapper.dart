// import 'package:flutter_demo/domain/entities/login/login_data.dart';
// import 'package:flutter_demo/domain/mapper/base_remote_data_mapper.dart';
// import 'package:injectable/injectable.dart';
//
// import '../../../data/services/models/login_data_api.dart';
//
// @injectable
// class LoginDataMapper extends BaseRemoteDataMapper<LoginResponse, LoginData> {
//   LoginDataMapper();
//
//   @override
//   LoginData mapToEntity(LoginResponse? data) {
//     return LoginData(
//       isSuccess: data?.isSuccess ?? false,
//       accessToken: data?.accessToken ?? '',
//       accessTokenLifetime: data?.accessTokenLifetime ?? 0,
//       identityToken: data?.identityToken ?? '',
//       errorMessage: data?.errorMessage ?? '',
//       errorCode: data?.errorCode ?? '',
//       refreshToken: data?.refreshToken ?? '',
//       scope: data?.scope ?? '',
//       profile: profileToProfileData(data?.profile)
//     );
//   }
//
//   ProfileData profileToProfileData(Profile? profile) {
//     return ProfileData(sub: profile?.sub ?? '', email: profile?.email ??'', preferredUsername: profile?.preferredUsername ?? '',
//         name: profile?.name ?? '', emailVerified: profile?.emailVerified ?? '', subjectId: profile?.subjectId ?? '',
//         producer: profile?.producer ?? '', sessionstamp: profile?.sessionstamp ?? '');
//   }
//
//   static LoginResponse convertLoginData(LoginData loginData) {
//     return LoginResponse(accessToken: loginData.accessToken)
//         ..isSuccess = loginData.isSuccess
//         ..refreshToken = loginData.refreshToken
//         ..scope = loginData.scope;
//   }
// }