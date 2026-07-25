import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_config.dart';

class UserService {
  Future<UserProfile> fetchUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles?id=eq.$userId&select=*,family_members(*)'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return UserProfile.fromMap(data.first);
      } else {
        throw Exception('User profile not found');
      }
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Future<void> updatePhoneNumber(String userId, String newPhone) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles?id=eq.$userId'),
      headers: ApiConfig.headers,
      body: json.encode({
        'phone_masked': newPhone,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update phone number: ${response.statusCode}');
    }
  }

  Future<void> updateEmail(String userId, String newEmail) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles?id=eq.$userId'),
      headers: ApiConfig.headers,
      body: json.encode({
        'email': newEmail,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update email: ${response.statusCode}');
    }
  }
}
