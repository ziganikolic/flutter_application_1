class BarcodeModel {
  final String code;
  final DateTime scannedAt;

  BarcodeModel({required this.code, required this.scannedAt});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }
}
