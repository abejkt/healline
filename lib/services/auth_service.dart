import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/user_profile.dart';
import 'api_config.dart';

class AuthService {
  static UserProfile? currentUser;

  Future<UserProfile?> login(String email, String password) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles?email=eq.$email&password_hash=eq.$passwordHash&select=*,family_members(*)'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        currentUser = UserProfile.fromMap(data.first);
        return currentUser;
      }
      return null;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String nik,
    required String password,
  }) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user_profiles'),
      headers: {
        ...ApiConfig.headers,
        'Prefer': 'return=representation',
      },
      body: json.encode({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'phone_masked': phone,
        'nik_masked': nik,
        'password_hash': passwordHash,
        'initials': initials,
        'is_verified': false,
        'no_rm': 'PENDING',
      }),
    );

    return response.statusCode == 201;
  }
}
