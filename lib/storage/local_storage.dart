import 'package:hive/hive.dart';
import '../models/barcode_model.dart';

class LocalStorage {
  final String boxName = 'barcodes';

  Future<void> saveBarcode(BarcodeModel barcode) async {
    var box = await Hive.openBox(boxName);
    await box.add(barcode.toJson());
  }

  Future<List<BarcodeModel>> getBarcodes() async {
    var box = await Hive.openBox(boxName);
    return box.values.map((data) {
      var barcodeMap = Map<String, dynamic>.from(data);
      return BarcodeModel(
        code: barcodeMap['code'],
        scannedAt: DateTime.parse(barcodeMap['scannedAt']),
      );
    }).toList();
  }

  Future<void> clearBarcodes() async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }
}
