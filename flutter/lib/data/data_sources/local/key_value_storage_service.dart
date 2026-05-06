
// import 'package:nt_ft_cryptography/nt_ft_cryptography_plugin.dart';
// import 'package:nt_ft_cryptography/password_hash_algorithm.dart';
// import 'package:nt_ft_storage/nt_ft_storage.dart';

class SharedPreferencesKey {
  static const secretKey = 'secretKey';
}

class KeyValueStorageService {
  // final NTFTKeyValueStorage _keyValueStorage;

  KeyValueStorageService(/*this._keyValueStorage*/);

  // Future<String> _generateSecretKeyIfNeeded() async {
  //   String? secretKey = await _keyValueStorage
  //       .getValue<String?>(SharedPreferencesKey.secretKey);
  //
  //   if (secretKey == null) {
  //     secretKey = await NTFtCryptographyPlugin().generateSecureRandomKey(
  //       password: SharedPreferencesKey.secretKey,
  //       keyLength: 256,
  //       algorithm: PasswordAlgorithm.SHA256,
  //     );
  //     return secretKey;
  //   } else {
  //     return secretKey;
  //   }
  // }

  void setSecretKey(String secretKey) {}
      // _keyValueStorage.setSecureValue(SharedPreferencesKey.secretKey, secretKey);

  Future<String?> getSecretKey() => Future.value("");
      // _keyValueStorage.getSecureValue(SharedPreferencesKey.secretKey);
}
