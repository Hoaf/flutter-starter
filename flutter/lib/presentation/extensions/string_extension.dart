
import 'dart:convert';

extension StringX on String {
  Map<String, dynamic> toMap() => isNotEmpty == true ? jsonDecode(this) as Map<String, dynamic> : {};

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String toCamelCaseFromVariable() {
    if (isEmpty) return this;

    return this[0].toLowerCase() + substring(1);
  }

  String toCamelCase() {
    if (isEmpty) return this;

    // Replace separators (underscore, dash, multiple spaces) with a single space
    var input = replaceAll(RegExp(r'[_\-\s]+'), ' ').trim();

    // Split into words
    final parts = input.split(' ');

    // First word lowercase
    final first = parts.first.toLowerCase();

    // Capitalize the rest
    final rest = parts.skip(1).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    return ([first, ...rest]).join('');
  }

  String toPascalCase() {
    if (isEmpty) return this;

    var input = replaceAll(RegExp(r'[_\-\s]+'), ' ').trim();
    final parts = input.split(' ');

    return parts.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
  }

  String removeAndTrimPathBy(String text) {
    return replaceAll(text, '')
      .replaceAll(RegExp(r'[\\/]+$'), '');
  }
}