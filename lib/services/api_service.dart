import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String apiUrl = 'https://api.example.com/sync';

  Future<void> syncBarcodes(List<Map<String, dynamic>> barcodes) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'barcodes': barcodes}),
    );

    if (response.statusCode == 200) {
      print('Podatki uspešno sinhronizirani.');
    } else {
      print('Napaka pri sinhronizaciji podatkov.');
    }
  }
}
