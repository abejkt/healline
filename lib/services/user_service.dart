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
}
