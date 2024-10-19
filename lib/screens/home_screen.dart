import 'package:flutter/material.dart';
import '../storage/local_storage.dart';
import '../models/barcode_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BarcodeModel> scannedCodes = [];

  @override
  void initState() {
    super.initState();
    loadScannedCodes();
  }

  void loadScannedCodes() async {
    var codes = await LocalStorage().getBarcodes();
    setState(() {
      scannedCodes = codes;
    });
  }

  Future<void> clearStorage() async {
    await LocalStorage().clearBarcodes();
    setState(() {
      scannedCodes.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Storage cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: scannedCodes.isEmpty
                ? Center(child: Text('No scanned codes available.'))
                : ListView.builder(
                    itemCount: scannedCodes.length,
                    itemBuilder: (context, index) {
                      final barcode = scannedCodes[index];
                      return ListTile(
                        leading: Icon(Icons.qr_code),
                        title: Text('Code: ${barcode.code}'),
                        subtitle: Text('Scanned at: ${barcode.scannedAt}'),
                      );
                    },
                  ),
          ),
          ElevatedButton.icon(
            onPressed: clearStorage,
            icon: Icon(Icons.delete),
            label: Text('Clear Storage'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
