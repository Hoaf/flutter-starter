
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

abstract class IFileStorageService {
  Future<bool> writeFile(String fileName, Uint8List content);
}

@Injectable(as: IFileStorageService)
class FileStorageService implements IFileStorageService {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  FileStorageService();

  Future<String> get _localPath async {
    late String dir;
    if(Platform.isAndroid) {
      const downloadsFolderPath = '/storage/emulated/0/Download/';
      Directory directory = Directory(downloadsFolderPath);
      dir = directory.path;
    } else if(Platform.isIOS) {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    return dir;
  }

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  @override
  Future<bool> writeFile(String fileName, Uint8List content) async {
    try {
      final file = await _localFile(fileName);
      // if (await file.exists()) {
      //   await file.delete();
      // }
      // await file.create();
      await file.writeAsBytes(content);
      return true;
    } catch (e) {
      return false;
    }
  }

}