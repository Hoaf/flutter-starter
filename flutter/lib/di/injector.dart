// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import 'package:nt_ft_core/nt_auth/nt_ft_auth.dart';
// import 'package:nt_ft_storage/nt_ft_storage.dart';
// import '../data/data_sources/unsecure_hive/unsecure_hive.dart';
// import '../data/data_sources/unsecure_local_datasource.dart';
// import 'injector.config.dart';
//
// final injector = GetIt.instance;
//
// @InjectableInit()
// Future<void> injectDependencies() async => injector.init();
//
// class AppDependency {
//   static void setup() async {}
//
//   static Future<void> inject() async {
//     final keyValueStorage = NTKeyValueStorageImpl();
//     await keyValueStorage.initialize();
//
//     ///Inject key-value storage
//     injector.registerLazySingleton<NTFTKeyValueStorage>(
//           () => keyValueStorage,
//     );
//
//     ///Inject biometric storage
//     injector.registerLazySingleton<NTFtBiometricStorageInterface>(
//           () => NTFtBiometricStorage(),
//     );
//
//     ///Inject auth plugin
//     injector.registerLazySingleton<NTFtAuth>(
//           () => NTFtAuth(),
//     );
//
//     ///Inject file storage
//     injector.registerLazySingleton<NTFtFileStorageInterface>(
//           () => NTFtFileStorage(),
//     );
//     //
//     // ///Inject secure storage
//     // injector.registerFactory<NTFTSecureStorage>(
//     //         () => NTSecureStorageImpl(injector<NTFTKeyValueStorage>()));
//
//     ///Inject unsecure storage
//     injector.registerFactory<UnSecureHiveStorage>(() => UnSecureHiveStorage());
//
//     ///Inject unsecure data source
//     injector.registerFactory<UnSecureLocalDataSource>(
//             () => UnSecureLocalDataSource(injector<UnSecureHiveStorage>()));
//
//     ///Inject other dependencies
//     await injectDependencies();
//   }
// }