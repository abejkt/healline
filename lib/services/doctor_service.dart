import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';
import 'api_config.dart';

class DoctorService {
  Future<List<Doctor>> fetchDoctors(String poliId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/doctors?poli_id=eq.$poliId&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Doctor.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }
}
