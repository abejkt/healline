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

  Future<void> addFamilyMember(String userId, Map<String, dynamic> memberData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/family_members'),
      headers: ApiConfig.headers,
      body: json.encode({
        ...memberData,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add family member: ${response.statusCode}');
    }
  }

  Future<void> updateFamilyMember(String memberId, Map<String, dynamic> memberData) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/family_members?id=eq.$memberId'),
      headers: ApiConfig.headers,
      body: json.encode(memberData),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update family member: ${response.statusCode}');
    }
  }

  Future<void> deleteFamilyMember(String memberId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/family_members?id=eq.$memberId'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete family member: ${response.statusCode}');
    }
  }
}
