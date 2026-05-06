import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hive/hive.dart';

class UnSecureHiveStorage {
  UnSecureHiveStorage();

  // MARK: - init
  /// 1. Creates the directory [subDir] to store data
  ///   a. If directory [subDir] already exists, nothing will happen.
  ///   b. If directory [subDir] doesn't exist and initialize Hive by giving it [subDir] directory.
  /// 2. Generate secret key
  ///   a. If the secret key was already in the KeyChain/KeyStore, nothing will happen.
  ///   b. If the secret key does not exist in the KeyChain/KeyStore, generate new secret key and save in the KeyChain/KeyStore with given [$name$_privateKey].
  ///
  /// - Parameters:
  ///   - name: `String` file name of box
  ///   - subDir: `String` directory name
  @override
  Future<void> init({String subDir = 'nt_hive'}) async {
    // try {
    //   final dir = await getApplicationSupportDirectory();
    //   final homePath = '${dir.path}/$subDir';
    //   await Directory(homePath).create();
    //   Hive.init(homePath);
    // } catch (_) {
    //   throw NTFTSecureStorageException(
    //       NTFTSecureStorageExceptionType.CreateFolderException);
    // }
  }

  // MARK: - deleteBox
  /// delete database
  ///
  /// 1. Removes the file which contains the box and closes the box.
  /// 2. Delete [secretKey] for the given [$name$_privateKey] in KeyChain/KeyStore.
  ///
  /// - Parameters:
  ///   - name: used to access the box and delete the box
  @override
  Future<void> deleteBox({required String name}) async {
    // try {
    //   final box = Hive.box<String>(name);
    //   await box.deleteFromDisk();
    // } on HiveError catch (e) {
    //   throw NTHiveSecureStorageException.fromHiveException(e);
    // } on Exception catch (_) {
    //   throw NTFTSecureStorageException(
    //       NTFTSecureStorageExceptionType.NTKeyValueSecureStorageException);
    // }
  }

  // MARK: - hasData
  /// Check if the box has any data.
  ///
  /// - Parameters:
  ///   - name: `String` file name of box
  ///   - onHasData: `CallBack` returns true if there is at least one entries in this box.
  @override
  Future<bool> hasData({required String name}) async {
    final box = Hive.box<String>(name);
    return box.length > 0;
  }

  @override
  Future<void> clearAll({required String name}) async {
    // try {
    //   final box = Hive.box<String>(name);
    //   await box.clear();
    // } on HiveError catch (e) {
    //   throw NTHiveSecureStorageException.fromHiveException(e);
    // } on Exception catch (_) {
    //   throw NTFTSecureStorageException(
    //       NTFTSecureStorageExceptionType.NTKeyValueSecureStorageException);
    // }
  }

  // MARK: - getAllData
  /// Get all data persisted in this box.
  ///
  ///  Reads List<String> in this box, mapping and decodes it to list<JSON>.
  ///
  /// - Parameters:
  ///   - name: `String` file name of box
  ///   - onGetAllDataSuccess: `CallBack` returns all data in this box.
  @override
  Future<List<dynamic>> getAllData({required String name}) async {
    final box = Hive.box<String>(name);
    final data = List.generate(box.length, (box).getAt)
        .map((e) => json.decode(e ?? ''))
        .toList();
    return data;
  }

  // MARK: - getData
  /// Get the value associated with the given [key]. If the key does not exist, `null` is returned
  ///
  /// - Parameters:
  ///   - name: `String` file name of box
  ///   - key: `String`
  ///   - onGetDataSuccess: `CallBack` Returns the value associated with the given [key].
  @override
  Future<dynamic> getData(String key, {required String name}) async {
    final box = Hive.box<String>(name);
    final valueEncode = box.get(key);
    final value = json.decode(valueEncode ?? '');
    return value;
  }

  // MARK: - getListData
  /// get list data persisted in this box.
  ///
  ///  Reads List<String> in this box, mapping and decodes it to list<JSON>.
  ///
  /// - Parameters:
  ///   - name: `String` file name of box
  ///   - page: `int`
  ///   - limit: `int`
  ///   - onGetListDataSuccess: `CallBack` returns list data in this box.
  @override
  Future<List<dynamic>> getListData(
      {required String name, required int page, required int limit}) async {
    final box = Hive.box<String>(name);
    final total = box.length;
    final start = (page - 1) * limit;
    final newDataCount = min(total - start, limit);

    final data = List.generate(newDataCount, (index) {
      final value = box.getAt(start + index);
      return json.decode(value ?? '');
    }).toList();
    return data;
  }
}
