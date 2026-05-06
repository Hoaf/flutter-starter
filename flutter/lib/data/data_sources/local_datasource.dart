import 'package:flutter_demo/presentation/utilities/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:async/async.dart';

abstract class LocalDataSource {
  Future<void> init();
  Future<void> removeAll();
// Future<void> openNTBox();
  // Future<void> saveUserProfile(ProfileLocalDBModel userProfile);
  // Future<ProfileLocalDBModel> getUserProfile(String key);
}

@Injectable(as: LocalDataSource)
class LocalDataSourceImpl implements LocalDataSource {
  // final NTFTSecureStorage _ntSecureStorage;
  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer<void>();

  // LocalDataSourceImpl(this._ntSecureStorage);

  @override
  Future<void> init() => _asyncMemoizer.runOnce(initialize);

  Future<void> initialize() async {
    try {
      // await _ntSecureStorage.init();
      await openNTBox();
    } catch (e) {
      AppLogger.e(e);
    }
  }

  @override
  Future<void> openNTBox() async {
    await Future.wait([
      // _ntSecureStorage.openNTBox<String>(name: HistoryOrderModel.boxKey),
    ]);
  }

  @override
  Future<void> removeAll() async {
    await Future.wait([
      // _ntSecureStorage.deleteBox(name: HistoryOrderModel.boxKey),
    ]);
  }
}
