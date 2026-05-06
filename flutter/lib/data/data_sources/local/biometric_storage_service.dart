import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
// import 'package:nt_ft_core/nt_auth/nt_ft_auth.dart';
// import 'package:nt_ft_storage/nt_ft_storage.dart';

abstract class IBiometricStorageService {
  Future<bool> hasLocalAuth();
  Future<List<String>> getEnrolledBiometrics();
  Future<List<String>> getAvailableEnrollBiometrics();
  Future<bool> isBiometricEnableOnDevice();
  Future<bool?> authenticate();

}

@Injectable(as: IBiometricStorageService)
class BiometricStorageService implements IBiometricStorageService {
  // late final NTFtBiometricStorageInterface biometricStorage;
  // late final NTFtAuth authPlugin;

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  BiometricStorageService(/*{required this.authPlugin, required this.biometricStorage}*/);

  //Returns whether this device supports biometric/secure storage
  // return false if current device running on simulator ios
  @override
  Future<bool> hasLocalAuth() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return false;
      }
    } catch (_) {}
    return false;
    // return await authPlugin.hasLocalAuth() ?? false;
  }

  //Returns the list of biometric authentication are using on device
  @override
  Future<List<String>> getEnrolledBiometrics() async {
    return [];
    // var enrolledBiometrics = await authPlugin.getEnrollBiometrics();
    // // if (enrolledBiometrics == null) {
    // //   return null;
    // // }
    // return enrolledBiometrics?.cast<String>() ?? [];
  }

  //Returns the list of available biometric authentication are using on device
  @override
  Future<List<String>> getAvailableEnrollBiometrics() async {
    return [];
    // var enrolledBiometrics = await authPlugin.getAvailableEnrollBiometrics();
    // return enrolledBiometrics?.cast<String>() ?? [];
  }

  /// iOS: true if FaceID/TouchID permission is granted
  /// android: true if contains weak & strong
  @override
  Future<bool> isBiometricEnableOnDevice() async {
    return false;
    // List<dynamic>? enrolledBiometrics = await authPlugin.getEnrollBiometrics();
    // if(enrolledBiometrics != null && enrolledBiometrics.isNotEmpty == true) {
    //   return (enrolledBiometrics.contains("fingerprint") || enrolledBiometrics.contains("face"))
    //       || (Platform.isAndroid && (enrolledBiometrics.contains("weak") || enrolledBiometrics.contains("strong")));
    // } else {
    //   return false;
    // }
  }

  @override
  Future<bool?> authenticate() => Future.value(false);// biometricStorage.authenticate();

}