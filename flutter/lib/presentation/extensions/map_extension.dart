
import 'dart:convert';

extension MapX on Map {
  String mapToString() => jsonEncode(this);
}