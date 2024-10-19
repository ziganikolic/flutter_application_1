import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../storage/local_storage.dart';
import '../models/barcode_model.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> syncLocalData() async {
    var localBarcodes = await LocalStorage().getBarcodes();

    if (localBarcodes.isNotEmpty) {
      List<Map<String, dynamic>> barcodesJson = localBarcodes.map((barcode) {
        return {
          'code': barcode.code,
          'scannedAt': barcode.scannedAt.toIso8601String(),
        };
      }).toList();

      await ApiService().syncBarcodes(barcodesJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await syncLocalData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data synchronized to API')),
            );
          },
          child: Text('Sync Local Data to API'),
        ),
      ),
    );
  }
}
