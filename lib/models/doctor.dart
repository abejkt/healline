import 'package:flutter/material.dart';

enum DoctorAvailability { tersedia, penuh }

extension DoctorAvailabilityLabel on DoctorAvailability {
  String get label {
    switch (this) {
      case DoctorAvailability.tersedia:
        return 'Tersedia';
      case DoctorAvailability.penuh:
        return 'Penuh';
    }
  }

  static DoctorAvailability fromString(String status) {
    return DoctorAvailability.values.firstWhere(
      (e) => e.name == status,
      orElse: () => DoctorAvailability.tersedia,
    );
  }
}

class Doctor {
  final String id;
  final String poliId;
  final String name;
  final String initials;
  final Color avatarColor;
  final int? quotaRemaining;
  final DoctorAvailability availability;

  const Doctor({
    required this.id,
    required this.poliId,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.quotaRemaining,
    required this.availability,
  });

  bool get isAvailable => availability == DoctorAvailability.tersedia;

  String get quotaLabel =>
      isAvailable ? 'Kuota tersisa: $quotaRemaining' : 'Kuota penuh';

  factory Doctor.fromMap(Map<String, dynamic> map) {
    // Helper to parse color safely from int or string
    Color parseColor(dynamic value) {
      if (value == null) return Colors.grey;
      if (value is int) return Color(value);
      if (value is String) {
        // Handle hex string like "#FF..." or "0xFF..." or just "428..."
        String cleanHex = value.replaceAll('#', '').replaceAll('0x', '');
        if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
        return Color(int.parse(cleanHex, radix: 16));
      }
      return Colors.grey;
    }

    return Doctor(
      id: map['id']?.toString() ?? '',
      poliId: map['poli_id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Tanpa Nama',
      initials: map['initials']?.toString() ?? '?',
      avatarColor: parseColor(map['avatar_color']),
      quotaRemaining: map['quota_remaining'] is int
          ? map['quota_remaining']
          : int.tryParse(map['quota_remaining']?.toString() ?? ''),
      availability: DoctorAvailabilityLabel.fromString(
          map['availability']?.toString() ?? 'tersedia'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poli_id': poliId,
      'name': name,
      'initials': initials,
      'avatar_color': avatarColor.toARGB32().toString(),
      'quota_remaining': quotaRemaining,
      'availability': availability.name,
    };
  }
}
