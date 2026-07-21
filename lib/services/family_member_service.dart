import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/family_member.dart';
import 'api_config.dart';

class FamilyMemberService {
  Future<List<FamilyMember>> fetchFamilyMembers(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/family_members?user_id=eq.$userId&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FamilyMember.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load family members: ${response.statusCode}');
    }
  }
}
