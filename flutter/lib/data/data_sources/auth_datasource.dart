// // import 'package:flutter_demo/data/data_sources/local/biometric_storage_service.dart';
// import 'package:flutter_demo/data/data_sources/local/key_value_storage_service.dart';
// // import 'package:flutter_demo/data/data_sources/local_datasource.dart';
// import 'package:flutter_demo/di/injector.dart';
// import 'package:injectable/injectable.dart';
//
// import 'local/biometric_storage_service.dart';
// import 'local_datasource.dart';
//
// abstract class IAuthDataSource {
//   void setSecretKey(String secretKey);
//
//   Future<String?> getSecretKey();
// }
//
// @Injectable(as: IAuthDataSource)
// class AuthDataSource extends IAuthDataSource {
//   final _localDataSource = injector<LocalDataSource>();
//   final _keyValueStorageService = injector<KeyValueStorageService>();
//   late final IBiometricStorageService _biometricStorage;
//
//   AuthDataSource(this._biometricStorage);
//
//   @override
//   void setSecretKey(String password) =>
//       _keyValueStorageService.setSecretKey(password);
//
//   @override
//   Future<String?> getSecretKey() =>
//       _keyValueStorageService.getSecretKey();
// }
