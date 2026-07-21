import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poli.dart';
import 'api_config.dart';

class PoliService {
  Future<List<Poli>> fetchPolis() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/polis?select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Poli.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load polis: ${response.statusCode}');
    }
  }
}
