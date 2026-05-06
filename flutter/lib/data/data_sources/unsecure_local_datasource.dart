import 'package:flutter_demo/data/data_sources/unsecure_hive/unsecure_hive.dart';
import 'package:flutter_demo/presentation/utilities/logger.dart';
import 'package:async/async.dart';
import 'package:injectable/injectable.dart';

import 'local_datasource.dart';

class UnSecureLocalDataSource implements LocalDataSource {
  final UnSecureHiveStorage _ntUnSecureStorage;
  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer<void>();

  UnSecureLocalDataSource(this._ntUnSecureStorage);

  @override
  Future<void> init() => _asyncMemoizer.runOnce(initialize);

  @override
  Future<void> initialize() async {
    try {
      await _ntUnSecureStorage.init();
      await openNTBox();
    } catch (e) {
      AppLogger.e(e);
    }
  }

  @override
  Future<void> openNTBox() async {
    // await _ntUnSecureStorage.openNTBox<String>(
    //     name: HistoryOrderModel.unsecureBoxKey);
  }

  @override
  Future<void> removeAll() async {
    await Future.wait([
      // _ntUnSecureStorage.clearAll(name: HistoryOrderModel.unsecureBoxKey),
    ]);
  }
}
