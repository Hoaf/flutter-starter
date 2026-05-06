// import 'package:flutter_demo/data/data_sources/auth_datasource.dart';
// import 'package:flutter_demo/domain/repositories/auth_repository_interface.dart';
// import 'package:injectable/injectable.dart';
//
// @Injectable(as: IAuthRepository)
// class AuthRepository extends IAuthRepository {
//   final IAuthDataSource authDataSource;
//
//   AuthRepository(this.authDataSource);
//
//   @override
//   void setSecretKey(String secretKey) =>
//       authDataSource.setSecretKey(secretKey);
//
//   @override
//   Future<String?> getSecretKey() =>
//       authDataSource.getSecretKey();
//
// }