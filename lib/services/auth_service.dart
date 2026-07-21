import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/user_profile.dart';
import 'api_config.dart';

class AuthService {
  Future<UserProfile?> login(String email, String password) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles?email=eq.$email&password_hash=eq.$passwordHash&select=*,family_members(*)'),
      headers: ApiConfig.headers,
    );

    debugPrint('SERVER RESPONSE CODE: ${response.statusCode}');
    debugPrint('SERVER BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return UserProfile.fromMap(data.first);
      }
      return null;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }
}
