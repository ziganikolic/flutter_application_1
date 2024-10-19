import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/barcode_model.dart';
import '../storage/local_storage.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  List<BarcodeModel> scannedCodes = [];
  bool isScanning = false;
  bool showDuplicateScanMessage = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;

    qrController.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && isScanning) {
        bool isDuplicate = await _checkIfCodeIsDuplicate(scanData.code!);

        if (isDuplicate) {
          setState(() {
            showDuplicateScanMessage = true;
          });
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              showDuplicateScanMessage = false;
            });
          });
          return;
        }

        var barcodeModel = BarcodeModel(
          code: scanData.code!,
          scannedAt: DateTime.now(),
        );

        await LocalStorage().saveBarcode(barcodeModel);

        setState(() {
          scannedCodes.insert(0, barcodeModel);
          if (scannedCodes.length > 5) {
            scannedCodes.removeLast();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code scanned: ${scanData.code}')),
        );
      }
    });
  }

  Future<bool> _checkIfCodeIsDuplicate(String scannedCode) async {
    if (scannedCodes.any((code) => code.code == scannedCode)) {
      return true;
    }

    var savedCodes = await LocalStorage().getBarcodes();
    return savedCodes.any((code) => code.code == scannedCode);
  }

  void startScanning() {
    controller?.resumeCamera();
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    controller?.pauseCamera();
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Continuous Scanning'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (isScanning)
                Expanded(
                  flex: 2,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutWidth: MediaQuery.of(context).size.width * 0.8,
                      cutOutHeight: 200,
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (isScanning)
                          ElevatedButton.icon(
                            onPressed: stopScanning,
                            icon: Icon(Icons.stop),
                            label: Text('Stop Scanning'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: startScanning,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Start Scanning'),
                          ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
          if (showDuplicateScanMessage)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.all(10),
                color: Colors.redAccent,
                child: Text(
                  'This code was just scanned. Try a different one.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
