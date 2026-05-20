import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenLocalDatasource {
  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  const TokenLocalDatasource(this._storage);

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> getToken() => _storage.read(key: _key);

  Future<void> deleteToken() => _storage.delete(key: _key);
}
