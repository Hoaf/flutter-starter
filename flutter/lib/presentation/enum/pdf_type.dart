enum PdfType { ahdb }

extension PdfTypeExtension on PdfType {
  String get subTitle {
    switch (this) {
      case PdfType.ahdb:
        return "Impact & How to avoid";
    }
  }

  String get aab {
    switch (this) {
      case PdfType.ahdb:
        return "AHDB";
    }
  }
}
