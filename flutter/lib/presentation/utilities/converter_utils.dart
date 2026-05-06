import 'dart:convert';

class ConverterUtils {
  static double getValueFromString(String? value) {
    if(value == null || value.isEmpty == true) {
      return 0;
    }
    return double.parse(value);
  }

  static int? parseIntOrNullFromString(String? value) {
    if(value == null || value.isEmpty == true) {
      return null;
    }
    return int.tryParse(value);
  }


  static String average(String? _total, String? _count) {
    double count = getValueFromString(_count);
    if(count == 0) {
      return "0";
    }
    return (getValueFromString(_total) / count).toStringAsFixed(2);
  }

  static String getTotalPayment(String? _sumOfAnimalValue, String? _sumOfLotChargeValue) {
    double sumOfAnimalValue = getValueFromString(_sumOfAnimalValue);
    double sumOfLotChargeValue = getValueFromString(_sumOfLotChargeValue);
    return (sumOfAnimalValue - sumOfLotChargeValue).toStringAsFixed(2);
  }

  static Map<String, dynamic> decodeJwtManual(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    // Add padding if necessary for the base64 library
    // Normalize base64 string to be divisible by 4
    var normalizedSource = base64Url.normalize(payload);

    // Decode
    final decodedBytes = base64Url.decode(normalizedSource);
    final decodedString = utf8.decode(decodedBytes);

    // Convert to Map
    return json.decode(decodedString);
  }

  static String? decodeJwtManualToProducerId(String token) {
    Map<String, dynamic> jwt = decodeJwtManual(token);

    return jwt['producer'] as String?;
  }
}