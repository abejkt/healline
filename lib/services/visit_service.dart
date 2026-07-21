import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visit.dart';
import 'api_config.dart';

class VisitService {
  Future<List<Visit>> fetchVisits() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/visits?select=*&order=date.desc'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Visit.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load visits: ${response.statusCode}');
    }
  }
}
